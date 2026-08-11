import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const waCloudToken = Deno.env.get('WHATSAPP_CLOUD_API_TOKEN')
  const waPhoneNumberId = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')

  try {
    // 1. Fetch match digests for relative users
    const { data: digests, error } = await supabase.rpc('fn_get_relative_match_digests', { p_limit: 50 })

    if (error) throw error

    const results = []

    if (digests && digests.length > 0) {
      for (const digest of digests) {
        const relationStr = digest.relation ? digest.relation : 'नातेवाईक'
        const genderLabel = digest.target_gender === 'Female' ? 'वधू' : 'वर'
        
        const messageText = 
          `जय सेवालाल! 🚩 बंजाराबायो (BanjaraBio) वर तुमच्या ${relationStr} साठी या आठवड्यात ${digest.match_count} नवीन ${genderLabel} प्रोफाईल आले आहेत:\n\n` +
          `👤 उमेदवारांची नावे: ${digest.sample_profile_names}\n\n` +
          `👉 प्रोफाईल पाहण्यासाठी आणि बायो-डाटा पाठवण्यासाठी आताच ॲप उघडा:\n` +
          `https://play.google.com/store/apps/details?id=com.avishio.banjarabio`

        let sendStatus = 'queued'

        // 2. Dispatch via Meta WhatsApp Cloud API (Free tier: 1,000 conversations/mo)
        if (waCloudToken && waPhoneNumberId && digest.phone_number) {
          try {
            const cleanPhone = digest.phone_number.replace(/\D/g, '')
            const formattedPhone = cleanPhone.startsWith('91') ? cleanPhone : `91${cleanPhone}`

            const response = await fetch(
              `https://graph.facebook.com/v18.0/${waPhoneNumberId}/messages`,
              {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${waCloudToken}`,
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  messaging_product: 'whatsapp',
                  recipient_type: 'individual',
                  to: formattedPhone,
                  type: 'text',
                  text: { preview_url: true, body: messageText }
                }),
              }
            )

            if (response.ok) {
              sendStatus = 'sent'
            } else {
              const resJson = await response.json()
              console.error('WhatsApp API Error:', resJson)
              sendStatus = 'failed'
            }
          } catch (apiErr) {
            console.error('WhatsApp Cloud API call failed:', apiErr)
            sendStatus = 'failed'
          }
        }

        // 3. Log to whatsapp_notification_logs
        await supabase.from('whatsapp_notification_logs').insert({
          user_id: digest.user_id,
          phone_number: digest.phone_number,
          matched_profile_ids: digest.matching_profile_ids,
          status: sendStatus,
        })

        results.push({
          user_id: digest.user_id,
          phone: digest.phone_number,
          status: sendStatus,
          count: digest.match_count
        })
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        processed_count: results.length,
        results 
      }), 
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }), 
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
