-- RAMP (Rental Administration Management Platform) Supabase Database Schema
-- Execute this script in your Supabase Dashboard -> SQL Editor

-- 0. Automated Trigger Function for updated_at timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- 1. Create Users Table
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

-- 2. Create Units Table
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

-- 3. Create Tenants Table
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

-- 4. Create Payments Table
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

-- 5. Create Maintenance Tickets Table
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

-- 6. Create Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id TEXT PRIMARY KEY,
  landlord_id TEXT DEFAULT 'l1',
  action TEXT NOT NULL,
  details TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Create Expenses Table
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

-- 8. Create Tenant Documents Table
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

-- 9. Create Announcements Table
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

-- 10. Create Notifications Table
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

-- 11. Create Settings Table
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

-- Insert default app settings
INSERT INTO public.settings (id) VALUES ('app') ON CONFLICT DO NOTHING;

-- 12. Create Utility Rate Logs Table
CREATE TABLE IF NOT EXISTS public.utility_rate_logs (
  id TEXT PRIMARY KEY,
  utility TEXT DEFAULT 'Water',
  previous_rate NUMERIC DEFAULT 0,
  new_rate NUMERIC DEFAULT 0,
  effective_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);

-- 13. Create Events Table (Calendar Custom Events)
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

-- 14. Performance Indexing
CREATE INDEX IF NOT EXISTS idx_users_uid ON public.users(uid);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
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

-- 15. Automated Triggers for Updated Timestamp
CREATE OR REPLACE TRIGGER set_updated_at_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_units BEFORE UPDATE ON public.units FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_tenants BEFORE UPDATE ON public.tenants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_tickets BEFORE UPDATE ON public.maintenance_tickets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_expenses BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_settings BEFORE UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER set_updated_at_events BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 16. Enable Row Level Security (RLS) on all core tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
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

-- 17. Configure RLS Access Policies for Application Users (Idempotent)
-- Explicitly scopes policies TO authenticated users, resolving Supabase Security Advisor warnings
-- while preserving app connectivity for signed-in landlords and tenants.

DROP POLICY IF EXISTS "Allow access to users table" ON public.users;
DROP POLICY IF EXISTS "Allow authenticated read and write on users" ON public.users;
CREATE POLICY "Allow authenticated read and write on users"
  ON public.users FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on units" ON public.units;
CREATE POLICY "Allow authenticated read and write on units"
  ON public.units FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on tenants" ON public.tenants;
CREATE POLICY "Allow authenticated read and write on tenants"
  ON public.tenants FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on payments" ON public.payments;
CREATE POLICY "Allow authenticated read and write on payments"
  ON public.payments FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on maintenance_tickets" ON public.maintenance_tickets;
CREATE POLICY "Allow authenticated read and write on maintenance_tickets"
  ON public.maintenance_tickets FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on audit_logs" ON public.audit_logs;
CREATE POLICY "Allow authenticated read and write on audit_logs"
  ON public.audit_logs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on expenses" ON public.expenses;
DROP POLICY IF EXISTS "Deny client access" ON public.expenses;
CREATE POLICY "Allow authenticated read and write on expenses"
  ON public.expenses FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

/*
-- ALTERNATIVE 1: User/Owner-Owned Expenses (if adding user_id Auth UUID column)
-- CREATE POLICY "Owner-only access to expenses"
-- ON public.expenses FOR ALL TO authenticated
-- USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

-- ALTERNATIVE 2: Backend-Only Table (Deny all direct client SDK access)
-- CREATE POLICY "Deny client access"
-- ON public.expenses FOR ALL
-- USING (false) WITH CHECK (false);
*/

DROP POLICY IF EXISTS "Allow authenticated read and write on tenant_documents" ON public.tenant_documents;
CREATE POLICY "Allow authenticated read and write on tenant_documents"
  ON public.tenant_documents FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on announcements" ON public.announcements;
CREATE POLICY "Allow authenticated read and write on announcements"
  ON public.announcements FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on notifications" ON public.notifications;
CREATE POLICY "Allow authenticated read and write on notifications"
  ON public.notifications FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on settings" ON public.settings;
CREATE POLICY "Allow authenticated read and write on settings"
  ON public.settings FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on utility_rate_logs" ON public.utility_rate_logs;
CREATE POLICY "Allow authenticated read and write on utility_rate_logs"
  ON public.utility_rate_logs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated read and write on events" ON public.events;
CREATE POLICY "Allow authenticated read and write on events"
  ON public.events FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 18. Configure Storage Bucket 'ramp_media' & Storage Policies
INSERT INTO storage.buckets (id, name, public)
VALUES ('ramp_media', 'ramp_media', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public Read Access for ramp_media" ON storage.objects;
CREATE POLICY "Public Read Access for ramp_media"
ON storage.objects FOR SELECT
USING (bucket_id = 'ramp_media');

DROP POLICY IF EXISTS "Authenticated Insert Access for ramp_media" ON storage.objects;
CREATE POLICY "Authenticated Insert Access for ramp_media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'ramp_media');

DROP POLICY IF EXISTS "Authenticated Update Access for ramp_media" ON storage.objects;
CREATE POLICY "Authenticated Update Access for ramp_media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'ramp_media');

DROP POLICY IF EXISTS "Authenticated Delete Access for ramp_media" ON storage.objects;
CREATE POLICY "Authenticated Delete Access for ramp_media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'ramp_media');

-- 19. Enable Realtime Publications (Safely)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE
      public.users,
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
