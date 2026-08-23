-- 🗑️ [BanjaraBio] Server-side auth user deletion RPC
-- Called during account deletion flow from the client.
-- The Supabase client SDK cannot delete auth.users directly —
-- this SECURITY DEFINER function runs with elevated privileges to do so.
-- Uses auth.uid() to ensure users can only delete themselves.

CREATE OR REPLACE FUNCTION fn_delete_auth_user()
RETURNS void AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Delete the auth user record (cascades via Supabase internal triggers)
    DELETE FROM auth.users WHERE id = v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions;

-- Only authenticated users can call this (not anon)
REVOKE EXECUTE ON FUNCTION fn_delete_auth_user() FROM anon;
GRANT EXECUTE ON FUNCTION fn_delete_auth_user() TO authenticated;
