/**
 * Resend Email Provider
 * Free tier: 3,000 emails/month (~100/day)
 * Docs: https://resend.com/docs/api-reference/emails/send-email
 */

import type { EmailPayload, SendResult } from './brevo.ts';

export async function sendViaResend(payload: EmailPayload): Promise<SendResult> {
  const apiKey = Deno.env.get('RESEND_API_KEY');
  if (!apiKey) {
    return { success: false, provider: 'resend', error: 'RESEND_API_KEY not set', quotaExceeded: false };
  }

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: `${payload.fromName ?? 'BanjaraBio'} <${payload.from ?? 'noreply@banjarabio.com'}>`,
        to: payload.to,
        subject: payload.subject,
        html: payload.html,
      }),
    });

    if (response.status === 429) {
      return { success: false, provider: 'resend', error: 'Rate limit exceeded', quotaExceeded: true };
    }

    if (!response.ok) {
      const errorBody = await response.text();
      return { success: false, provider: 'resend', error: `HTTP ${response.status}: ${errorBody}`, quotaExceeded: false };
    }

    const data = await response.json();
    return {
      success: true,
      provider: 'resend',
      messageId: data.id,
    };
  } catch (error) {
    return { success: false, provider: 'resend', error: (error as Error).message, quotaExceeded: false };
  }
}
