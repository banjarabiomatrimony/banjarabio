import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, password, full_name, department, designation } = await req.json()

    // Create Supabase Admin Client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Optional: Only allow creator/admin to do this
    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data: { user: adminUser }, error: verifyError } = await supabaseAdmin.auth.getUser(token)
    
    if (verifyError || !adminUser) {
      console.error("Auth Verification Error:", verifyError);
      return new Response(JSON.stringify({ error: 'Unauthorized', details: verifyError }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Verify they are admin
    const { data: adminProfile } = await supabaseAdmin.from('profiles').select('role').eq('user_id', adminUser.id).single()
    if (adminProfile?.role !== 'creator' && adminProfile?.role !== 'admin' && adminUser.email !== 'admin@banjarabio.com') {
      console.error("Role Verification Error: ", adminProfile);
      return new Response(JSON.stringify({ error: 'Unauthorized role. Only admins can hire.' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Create user in Auth
    const { data: authData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: full_name,
        role: 'staff',
        department: department,
        designation: designation,
      }
    })

    if (createError) throw createError

    // Ensure profiles table has the right role
    if (authData.user) {
      const { error: profileError } = await supabaseAdmin.from('profiles').insert({
        user_id: authData.user.id,
        role: 'staff',
        department: department,
        designation: designation,
        full_name: full_name
      });
      if (profileError) {
        console.error("Profile insert error:", profileError);
        // Fallback to update if the row was somehow created
        await supabaseAdmin.from('profiles').update({
          role: 'staff',
          department: department,
          designation: designation,
          full_name: full_name
        }).eq('user_id', authData.user.id);
      }
    }

    return new Response(JSON.stringify({ ok: true, user: authData.user }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err: any) {
    console.error(err)
    return new Response(JSON.stringify({ error: err.message, ok: false }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
