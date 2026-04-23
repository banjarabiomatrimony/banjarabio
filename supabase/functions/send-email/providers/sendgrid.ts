/**
 * SendGrid Email Provider
 * Free tier: 100 emails/day forever
 * Docs: https://docs.sendgrid.com/api-reference/mail-send/mail-send
 */

import type { EmailPayload, SendResult } from './brevo.ts';

export async function sendViaSendGrid(payload: EmailPayload): Promise<SendResult> {
  const apiKey = Deno.env.get('SENDGRID_API_KEY');
  if (!apiKey) {
    return { success: false, provider: 'sendgrid', error: 'SENDGRID_API_KEY not set', quotaExceeded: false };
  }

  try {
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [
          {
            to: payload.to.map((email) => ({ email })),
            subject: payload.subject,
          },
        ],
        from: {
          email: payload.from ?? 'noreply@banjarabio.com',
          name: payload.fromName ?? 'BanjaraBio',
        },
        content: [
          {
            type: 'text/html',
            value: payload.html,
          },
        ],
      }),
    });

    // SendGrid returns 202 for accepted, 429 for rate limit
    if (response.status === 429) {
      return { success: false, provider: 'sendgrid', error: 'Rate limit exceeded', quotaExceeded: true };
    }

    if (response.status !== 202 && !response.ok) {
      const errorBody = await response.text();
      return { success: false, provider: 'sendgrid', error: `HTTP ${response.status}: ${errorBody}`, quotaExceeded: false };
    }

    // SendGrid returns message ID in the header
    const messageId = response.headers.get('X-Message-Id') ?? undefined;
    return {
      success: true,
      provider: 'sendgrid',
      messageId,
    };
  } catch (error) {
    return { success: false, provider: 'sendgrid', error: (error as Error).message, quotaExceeded: false };
  }
}
