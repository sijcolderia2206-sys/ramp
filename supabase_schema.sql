-- RAMP (Rental Administration Management Platform) Supabase Database Schema
-- Execute this script in your Supabase Dashboard -> SQL Editor

-- 1. Create Units Table
CREATE TABLE IF NOT EXISTS public.units (
  id TEXT PRIMARY KEY,
  landlord_id TEXT NOT NULL,
  name TEXT,
  title TEXT,
  unit_number TEXT,
  floor TEXT,
  location TEXT,
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
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Tenants Table
CREATE TABLE IF NOT EXISTS public.tenants (
  id TEXT PRIMARY KEY,
  landlord_id TEXT NOT NULL,
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
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  id TEXT PRIMARY KEY,
  landlord_id TEXT NOT NULL,
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
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create Maintenance Tickets Table
CREATE TABLE IF NOT EXISTS public.maintenance_tickets (
  id TEXT PRIMARY KEY,
  landlord_id TEXT NOT NULL,
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
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id TEXT PRIMARY KEY,
  landlord_id TEXT NOT NULL,
  action TEXT NOT NULL,
  details TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Initialize Public Storage Bucket 'ramp_media'
INSERT INTO storage.buckets (id, name, public)
VALUES ('ramp_media', 'ramp_media', true)
ON CONFLICT (id) DO NOTHING;

-- 7. Configure Public Storage Policies for ramp_media
CREATE POLICY "Public Read Access for ramp_media"
ON storage.objects FOR SELECT
USING (bucket_id = 'ramp_media');

-- 8. Create Expenses Table
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

-- 9. Create Tenant Documents Table
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

-- 10. Create Announcements Table
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

-- 11. Create Notifications Table
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

-- 12. Create Settings Table
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

-- 13. Create Utility Rate Logs Table
CREATE TABLE IF NOT EXISTS public.utility_rate_logs (
  id TEXT PRIMARY KEY,
  utility TEXT DEFAULT 'Water',
  previous_rate NUMERIC DEFAULT 0,
  new_rate NUMERIC DEFAULT 0,
  effective_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);


CREATE POLICY "Public Insert Access for ramp_media"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'ramp_media');

CREATE POLICY "Public Update Access for ramp_media"
ON storage.objects FOR UPDATE
USING (bucket_id = 'ramp_media');

-- 8. Create Expenses Table
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

-- 9. Create Tenant Documents Table
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

-- 10. Create Announcements Table
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

-- 11. Create Notifications Table
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

-- 12. Create Settings Table
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

-- 13. Create Utility Rate Logs Table
CREATE TABLE IF NOT EXISTS public.utility_rate_logs (
  id TEXT PRIMARY KEY,
  utility TEXT DEFAULT 'Water',
  previous_rate NUMERIC DEFAULT 0,
  new_rate NUMERIC DEFAULT 0,
  effective_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);


CREATE POLICY "Public Delete Access for ramp_media"
ON storage.objects FOR DELETE
USING (bucket_id = 'ramp_media');

-- 8. Create Expenses Table
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

-- 9. Create Tenant Documents Table
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

-- 10. Create Announcements Table
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

-- 11. Create Notifications Table
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

-- 12. Create Settings Table
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

-- 13. Create Utility Rate Logs Table
CREATE TABLE IF NOT EXISTS public.utility_rate_logs (
  id TEXT PRIMARY KEY,
  utility TEXT DEFAULT 'Water',
  previous_rate NUMERIC DEFAULT 0,
  new_rate NUMERIC DEFAULT 0,
  effective_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);

