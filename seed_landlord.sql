-- ============================================================================
-- RAMP Platform - Complete Landlord Account Seed Script
-- Includes auth.users + auth.identities + public.users + public.landlords
-- Execute this script in your Supabase Dashboard -> SQL Editor
-- ============================================================================

-- Ensure pgcrypto extension is enabled for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- Safely update private.enforce_user_role_changes if present to permit initial seeding
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'private' AND p.proname = 'enforce_user_role_changes'
  ) THEN
    EXECUTE '
      CREATE OR REPLACE FUNCTION private.enforce_user_role_changes()
      RETURNS trigger
      LANGUAGE plpgsql
      SECURITY DEFINER
      AS $func$
      BEGIN
        IF current_setting(''session_replication_role'', true) = ''replica''
           OR session_user IN (''postgres'', ''service_role'', ''supabase_admin'')
           OR auth.uid() IS NULL
           OR EXISTS (
                SELECT 1 FROM public.users
                WHERE (uid = auth.uid()::text OR id = auth.uid()::text) AND role IN (''landlord'', ''super_admin'')
              ) THEN
          RETURN NEW;
        END IF;

        IF NEW.role IN (''landlord'', ''super_admin'') AND (OLD IS NULL OR OLD.role IS DISTINCT FROM NEW.role) THEN
          RAISE EXCEPTION ''Only a superadmin can create landlord or superadmin accounts'' USING ERRCODE = ''42501'';
        END IF;

        RETURN NEW;
      END;
      $func$;
    ';
  END IF;
END $$;

DO $$
DECLARE
  landlord_user_id UUID := 'e2a1b3c4-d5e6-4f7a-8b9c-0123456789cd'::uuid;
  landlord_email TEXT := 'landlord@ramp.com';
  landlord_password TEXT := 'Landlord123!';
  display_name TEXT := 'Demo Landlord';
  company_name TEXT := 'RAMP Properties';
  encrypted_pw TEXT;
BEGIN
  -- Temporarily set session_replication_role to replica to bypass non-replica triggers during initial seeding
  PERFORM set_config('session_replication_role', 'replica', true);

  -- Generate bcrypt hash for the password
  encrypted_pw := extensions.crypt(landlord_password, extensions.gen_salt('bf'));

  -- 1. Insert or update in auth.users
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = landlord_email) THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      created_at,
      updated_at
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      landlord_user_id,
      'authenticated',
      'authenticated',
      landlord_email,
      encrypted_pw,
      NOW(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object(
        'display_name', display_name,
        'company_name', company_name,
        'role', 'landlord'
      ),
      FALSE,
      NOW(),
      NOW()
    );
  ELSE
    SELECT id INTO landlord_user_id FROM auth.users WHERE email = landlord_email;

    UPDATE auth.users
    SET
      email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
      encrypted_password = encrypted_pw,
      raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{role}',
        '"landlord"'
      )
    WHERE email = landlord_email;
  END IF;

  -- 2. Insert into auth.identities (REQUIRED by Supabase GoTrue Auth)
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    landlord_user_id,
    landlord_user_id,
    jsonb_build_object('sub', landlord_user_id::text, 'email', landlord_email),
    'email',
    landlord_email,
    NOW(),
    NOW(),
    NOW()
  ) ON CONFLICT (provider, provider_id) DO NOTHING;

  -- 3. Insert or update in public.users table
  INSERT INTO public.users (
    id,
    uid,
    email,
    display_name,
    role,
    is_approved,
    must_change_password
  ) VALUES (
    landlord_user_id::text,
    landlord_user_id::text,
    landlord_email,
    display_name,
    'landlord',
    TRUE,
    FALSE
  ) ON CONFLICT (uid) DO UPDATE SET
    role = 'landlord',
    is_approved = TRUE,
    display_name = display_name;

  -- 4. Insert or update in public.landlords table
  INSERT INTO public.landlords (
    id,
    uid,
    name,
    company_name,
    email,
    status,
    subscription_plan,
    total_units_limit
  ) VALUES (
    'l_' || landlord_user_id::text,
    landlord_user_id::text,
    display_name,
    company_name,
    landlord_email,
    'active',
    'Pro',
    50
  ) ON CONFLICT (uid) DO UPDATE SET
    name = display_name,
    company_name = company_name,
    email = landlord_email,
    status = 'active';

  -- Restore session_replication_role to default origin
  PERFORM set_config('session_replication_role', 'origin', true);

  RAISE NOTICE '✅ Landlord account % successfully seeded!', landlord_email;
END $$;
