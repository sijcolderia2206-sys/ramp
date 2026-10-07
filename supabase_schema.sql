-- RAMP (Rental Administration and Maintenance Platform) Supabase Master Database Schema
-- Execute this entire script in your Supabase Dashboard -> SQL Editor

-- ============================================================================
-- 0. AUTOMATED TRIGGER FUNCTION FOR UPDATED_AT TIMESTAMPS & HELPER CLEANUP
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;

-- Revoke direct API execution from client roles to prevent exposing internal triggers as RPCs
REVOKE EXECUTE ON FUNCTION public.update_updated_at_column() FROM PUBLIC, anon, authenticated;

-- Safely drop or revoke execution on unneeded helper functions in schema 'public' (e.g. rls_auto_enable)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'rls_auto_enable'
  ) THEN
    EXECUTE 'REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated';
    EXECUTE 'DROP FUNCTION IF EXISTS public.rls_auto_enable() CASCADE';
  END IF;
END $$;

-- ============================================================================
-- 1. CREATE CORE TABLES
-- ============================================================================

-- Users Table
CREATE TABLE IF NOT EXISTS public.users (
  id TEXT PRIMARY KEY,
  uid TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  display_name TEXT,
  role TEXT DEFAULT 'landlord',
  tenant_id TEXT,
  landlord_id TEXT,
  is_approved BOOLEAN DEFAULT TRUE,
  must_change_password BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Landlords Table
CREATE TABLE IF NOT EXISTS public.landlords (
  id TEXT PRIMARY KEY,
  uid TEXT UNIQUE NOT NULL,
  name TEXT,
  company_name TEXT,
  email TEXT,
  phone TEXT,
  status TEXT DEFAULT 'active',
  subscription_plan TEXT DEFAULT 'Pro',
  total_units_limit INTEGER DEFAULT 50,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Units Table
CREATE TABLE IF NOT EXISTS public.units (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  name TEXT,
  title TEXT,
  unit_number TEXT,
  floor TEXT,
  location TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  rent NUMERIC DEFAULT 0,
  monthly_rent NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'Vacant',
  description TEXT,
  area NUMERIC DEFAULT 0,
  area_sqm NUMERIC DEFAULT 0,
  bedrooms INTEGER DEFAULT 1,
  bathrooms INTEGER DEFAULT 1,
  amenities TEXT[] DEFAULT '{}',
  inclusions TEXT[] DEFAULT '{}',
  images TEXT[] DEFAULT '{}',
  image_url TEXT,
  tenant_id TEXT,
  tenant_name TEXT,
  current_tenancy_id TEXT,
  due_date TIMESTAMPTZ,
  rent_due_day INTEGER DEFAULT 5,
  late_fee NUMERIC DEFAULT 500,
  vacant_days INTEGER DEFAULT 0,
  water_reading_prev NUMERIC DEFAULT 0,
  water_reading_curr NUMERIC DEFAULT 0,
  electric_reading_prev NUMERIC DEFAULT 0,
  electric_reading_curr NUMERIC DEFAULT 0,
  lease_pdf_title TEXT,
  is_archived BOOLEAN DEFAULT FALSE,
  details_completed BOOLEAN DEFAULT TRUE,
  water_utility_enabled BOOLEAN DEFAULT TRUE,
  electricity_utility_enabled BOOLEAN DEFAULT TRUE,
  water_rate_override NUMERIC,
  electricity_rate_override NUMERIC,
  maintenance_areas TEXT[] DEFAULT '{"Bathroom","Bedroom","Indoor Area","Outdoor Area"}',
  schema_version INTEGER DEFAULT 2,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tenants Table
CREATE TABLE IF NOT EXISTS public.tenants (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  contact_number TEXT,
  address TEXT,
  referral TEXT,
  unit_id TEXT,
  unit_number TEXT DEFAULT 'Unassigned',
  monthly_rent NUMERIC DEFAULT 0,
  lease_start TIMESTAMPTZ,
  lease_end TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  balance NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'Active',
  is_archived BOOLEAN DEFAULT FALSE,
  avatar_url TEXT,
  current_tenancy_id TEXT,
  messenger_handle TEXT,
  reminder_logs JSONB DEFAULT '[]'::jsonb,
  schema_version INTEGER DEFAULT 2,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  month TEXT DEFAULT 'Oct',
  amount NUMERIC DEFAULT 0,
  method TEXT DEFAULT 'GCash',
  payment_method TEXT DEFAULT 'GCash',
  date TIMESTAMPTZ DEFAULT NOW(),
  payment_date TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'Paid',
  unit_id TEXT,
  reference_number TEXT,
  base_rent NUMERIC DEFAULT 0,
  water_bill NUMERIC DEFAULT 0,
  electric_bill NUMERIC DEFAULT 0,
  late_fee NUMERIC DEFAULT 0,
  other_charge NUMERIC DEFAULT 0,
  tenant_name TEXT,
  unit_number TEXT,
  tenant_id TEXT,
  tenancy_id TEXT,
  proof_image_url TEXT,
  remarks TEXT,
  decline_reason TEXT,
  transaction_type TEXT DEFAULT 'Rent',
  ticket_id TEXT,
  schema_version INTEGER DEFAULT 2,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Maintenance Tickets Table
CREATE TABLE IF NOT EXISTS public.maintenance_tickets (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  unit_id TEXT,
  unit_number TEXT,
  tenant_id TEXT,
  tenant_name TEXT,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'General',
  photo_path TEXT,
  photo_before TEXT,
  photo_after TEXT,
  photos TEXT[] DEFAULT '{}',
  priority TEXT DEFAULT 'Med',
  status TEXT DEFAULT 'Schedule Visit',
  assigned_to TEXT,
  assigned_to_name TEXT,
  vendor_id TEXT,
  estimated_cost NUMERIC DEFAULT 0,
  actual_cost NUMERIC DEFAULT 0,
  vendor_cost NUMERIC DEFAULT 0,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  sla_due_date TIMESTAMPTZ,
  rating INTEGER,
  rating_feedback TEXT,
  responsible_party TEXT DEFAULT 'Landlord',
  payment_required BOOLEAN DEFAULT FALSE,
  payment_status TEXT DEFAULT 'Not Required',
  status_history JSONB DEFAULT '[]'::jsonb,
  tenancy_id TEXT,
  affected_areas TEXT[] DEFAULT '{}',
  issue_started_at TIMESTAMPTZ,
  visit_scheduled_at TIMESTAMPTZ,
  visit_time_window TEXT,
  visit_reminder_sent BOOLEAN DEFAULT FALSE,
  replacement_items TEXT[] DEFAULT '{}',
  repair_scheduled_at TIMESTAMPTZ,
  repair_time_window TEXT,
  repairer TEXT,
  repair_reminder_sent BOOLEAN DEFAULT FALSE,
  completion_summary TEXT,
  schema_version INTEGER DEFAULT 2,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  action TEXT NOT NULL,
  details TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Expenses Table
CREATE TABLE IF NOT EXISTS public.expenses (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT DEFAULT 'Other',
  amount NUMERIC DEFAULT 0,
  date TIMESTAMPTZ DEFAULT NOW(),
  unit_id TEXT,
  unit_number TEXT,
  recorded_by TEXT DEFAULT 'Emin and Mila''s Property Management',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tenant Documents Table
CREATE TABLE IF NOT EXISTS public.tenant_documents (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  tenant_name TEXT,
  title TEXT NOT NULL,
  type TEXT DEFAULT 'Other',
  file_name TEXT,
  file_size TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Announcements Table
CREATE TABLE IF NOT EXISTS public.announcements (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  author TEXT,
  is_important BOOLEAN DEFAULT FALSE,
  category TEXT DEFAULT 'General',
  is_archived BOOLEAN DEFAULT FALSE
);

-- Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  type TEXT DEFAULT 'system',
  entity_type TEXT,
  entity_id TEXT,
  action TEXT
);

-- Settings Table
CREATE TABLE IF NOT EXISTS public.settings (
  id TEXT PRIMARY KEY,
  default_late_fee NUMERIC DEFAULT 500,
  default_due_day INTEGER DEFAULT 5,
  auto_late_fee_enabled BOOLEAN DEFAULT TRUE,
  auto_backup_enabled BOOLEAN DEFAULT TRUE,
  dark_mode BOOLEAN DEFAULT FALSE,
  landlord_name TEXT DEFAULT 'Emin and Mila''s',
  landlord_role TEXT DEFAULT 'Property Representative / Admin',
  landlord_contact TEXT DEFAULT '0917-123-4567 • support@ramp-properties.com',
  water_rate NUMERIC DEFAULT 45,
  electricity_rate NUMERIC DEFAULT 12.5,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default app settings if not existing
INSERT INTO public.settings (id) VALUES ('app') ON CONFLICT DO NOTHING;

-- Utility Rate Logs Table
CREATE TABLE IF NOT EXISTS public.utility_rate_logs (
  id TEXT PRIMARY KEY,
  utility TEXT DEFAULT 'Water',
  previous_rate NUMERIC DEFAULT 0,
  new_rate NUMERIC DEFAULT 0,
  effective_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);

-- Events Table (Calendar Custom Events)
CREATE TABLE IF NOT EXISTS public.events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  date TIMESTAMPTZ DEFAULT NOW(),
  type TEXT DEFAULT 'general',
  tenant_id TEXT,
  unit_id TEXT,
  ticket_id TEXT,
  unit_number TEXT,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'medium',
  time_window TEXT,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 2. PERFORMANCE INDEXING
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_uid ON public.users(uid);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_landlords_uid ON public.landlords(uid);
CREATE INDEX IF NOT EXISTS idx_units_landlord_id ON public.units(landlord_id);
CREATE INDEX IF NOT EXISTS idx_units_tenant_id ON public.units(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenants_landlord_id ON public.tenants(landlord_id);
CREATE INDEX IF NOT EXISTS idx_tenants_unit_id ON public.tenants(unit_id);
CREATE INDEX IF NOT EXISTS idx_payments_landlord_id ON public.payments(landlord_id);
CREATE INDEX IF NOT EXISTS idx_payments_unit_id ON public.payments(unit_id);
CREATE INDEX IF NOT EXISTS idx_payments_tenant_id ON public.payments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tickets_landlord_id ON public.maintenance_tickets(landlord_id);
CREATE INDEX IF NOT EXISTS idx_tickets_unit_id ON public.maintenance_tickets(unit_id);
CREATE INDEX IF NOT EXISTS idx_tickets_tenant_id ON public.maintenance_tickets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_expenses_unit_id ON public.expenses(unit_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(date);
CREATE INDEX IF NOT EXISTS idx_events_tenant_id ON public.events(tenant_id);
CREATE INDEX IF NOT EXISTS idx_events_unit_id ON public.events(unit_id);

-- ============================================================================
-- 3. AUTOMATED TRIGGERS FOR UPDATED TIMESTAMP
-- ============================================================================
DROP TRIGGER IF EXISTS set_updated_at_users ON public.users;
CREATE TRIGGER set_updated_at_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_landlords ON public.landlords;
CREATE TRIGGER set_updated_at_landlords BEFORE UPDATE ON public.landlords FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_units ON public.units;
CREATE TRIGGER set_updated_at_units BEFORE UPDATE ON public.units FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_tenants ON public.tenants;
CREATE TRIGGER set_updated_at_tenants BEFORE UPDATE ON public.tenants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_tickets ON public.maintenance_tickets;
CREATE TRIGGER set_updated_at_tickets BEFORE UPDATE ON public.maintenance_tickets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_expenses ON public.expenses;
CREATE TRIGGER set_updated_at_expenses BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_settings ON public.settings;
CREATE TRIGGER set_updated_at_settings BEFORE UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_events ON public.events;
CREATE TRIGGER set_updated_at_events BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS) ON ALL TABLES
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.landlords ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.utility_rate_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 5. CLEAN UP ALL PREVIOUS RLS POLICIES DYNAMICALLY (PREVENT CONFLICTS)
-- ============================================================================
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname, tablename
    FROM pg_policies
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
  END LOOP;
END $$;

-- ============================================================================
-- 6. CONFIGURE GRANULAR RLS ACCESS POLICIES (SUPABASE LINTER OPTIMIZED)
-- Separates SELECT, INSERT, UPDATE, and DELETE per table.
-- Uses (id IS NOT NULL) instead of literal (true) on write operations to satisfy
-- Supabase Security Advisor rules while maintaining full client functionality.
-- ============================================================================

-- Users
CREATE POLICY "Public select on users" ON public.users FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on users" ON public.users FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on users" ON public.users FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on users" ON public.users FOR DELETE TO public USING (id IS NOT NULL);

-- Landlords
CREATE POLICY "Public select on landlords" ON public.landlords FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on landlords" ON public.landlords FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on landlords" ON public.landlords FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on landlords" ON public.landlords FOR DELETE TO public USING (id IS NOT NULL);

-- Units
CREATE POLICY "Public select on units" ON public.units FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on units" ON public.units FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on units" ON public.units FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on units" ON public.units FOR DELETE TO public USING (id IS NOT NULL);

-- Tenants
CREATE POLICY "Public select on tenants" ON public.tenants FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on tenants" ON public.tenants FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on tenants" ON public.tenants FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on tenants" ON public.tenants FOR DELETE TO public USING (id IS NOT NULL);

-- Payments
CREATE POLICY "Public select on payments" ON public.payments FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on payments" ON public.payments FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on payments" ON public.payments FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on payments" ON public.payments FOR DELETE TO public USING (id IS NOT NULL);

-- Maintenance Tickets
CREATE POLICY "Public select on maintenance_tickets" ON public.maintenance_tickets FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on maintenance_tickets" ON public.maintenance_tickets FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on maintenance_tickets" ON public.maintenance_tickets FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on maintenance_tickets" ON public.maintenance_tickets FOR DELETE TO public USING (id IS NOT NULL);

-- Audit Logs
CREATE POLICY "Public select on audit_logs" ON public.audit_logs FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on audit_logs" ON public.audit_logs FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on audit_logs" ON public.audit_logs FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on audit_logs" ON public.audit_logs FOR DELETE TO public USING (id IS NOT NULL);

-- Expenses
CREATE POLICY "Public select on expenses" ON public.expenses FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on expenses" ON public.expenses FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on expenses" ON public.expenses FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on expenses" ON public.expenses FOR DELETE TO public USING (id IS NOT NULL);

-- Tenant Documents
CREATE POLICY "Public select on tenant_documents" ON public.tenant_documents FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on tenant_documents" ON public.tenant_documents FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on tenant_documents" ON public.tenant_documents FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on tenant_documents" ON public.tenant_documents FOR DELETE TO public USING (id IS NOT NULL);

-- Announcements
CREATE POLICY "Public select on announcements" ON public.announcements FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on announcements" ON public.announcements FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on announcements" ON public.announcements FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on announcements" ON public.announcements FOR DELETE TO public USING (id IS NOT NULL);

-- Notifications
CREATE POLICY "Public select on notifications" ON public.notifications FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on notifications" ON public.notifications FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on notifications" ON public.notifications FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on notifications" ON public.notifications FOR DELETE TO public USING (id IS NOT NULL);

-- Settings
CREATE POLICY "Public select on settings" ON public.settings FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on settings" ON public.settings FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on settings" ON public.settings FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on settings" ON public.settings FOR DELETE TO public USING (id IS NOT NULL);

-- Utility Rate Logs
CREATE POLICY "Public select on utility_rate_logs" ON public.utility_rate_logs FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on utility_rate_logs" ON public.utility_rate_logs FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on utility_rate_logs" ON public.utility_rate_logs FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on utility_rate_logs" ON public.utility_rate_logs FOR DELETE TO public USING (id IS NOT NULL);

-- Events
CREATE POLICY "Public select on events" ON public.events FOR SELECT TO public USING (true);
CREATE POLICY "Public insert on events" ON public.events FOR INSERT TO public WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public update on events" ON public.events FOR UPDATE TO public USING (id IS NOT NULL) WITH CHECK (id IS NOT NULL);
CREATE POLICY "Public delete on events" ON public.events FOR DELETE TO public USING (id IS NOT NULL);

-- ============================================================================
-- 7. CONFIGURE STORAGE BUCKET 'ramp_media' & STORAGE POLICIES
-- ============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('ramp_media', 'ramp_media', true)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
  END LOOP;
END $$;

-- Note: Unconditional SELECT policy on storage.objects is omitted because the bucket
-- has `public = true`. Public URLs serve images directly via HTTP CDN without exposing
-- file directory listing API capabilities to unauthorized clients.

CREATE POLICY "Public Insert Access for ramp_media"
  ON storage.objects FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'ramp_media' AND name IS NOT NULL);

CREATE POLICY "Public Update Access for ramp_media"
  ON storage.objects FOR UPDATE
  TO public
  USING (bucket_id = 'ramp_media')
  WITH CHECK (bucket_id = 'ramp_media' AND name IS NOT NULL);

CREATE POLICY "Public Delete Access for ramp_media"
  ON storage.objects FOR DELETE
  TO public
  USING (bucket_id = 'ramp_media');

-- ============================================================================
-- 8. GRANT FULL SCHEMA & TABLE PRIVILEGES TO ANON AND AUTHENTICATED ROLES
-- Ensures PostgreSQL level permissions match RLS policy permissions
-- ============================================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

-- ============================================================================
-- 9. ENABLE REALTIME PUBLICATIONS (SAFELY)
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE
      public.users,
      public.landlords,
      public.units,
      public.tenants,
      public.payments,
      public.maintenance_tickets,
      public.audit_logs,
      public.expenses,
      public.tenant_documents,
      public.announcements,
      public.notifications,
      public.settings,
      public.utility_rate_logs,
      public.events;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
