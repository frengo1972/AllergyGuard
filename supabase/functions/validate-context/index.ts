// Edge Function: validate-context
// Trigger su INSERT in context_patterns (candidati).
// Chiama Claude API per validare e tradurre nuovi pattern.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const CLAUDE_MODEL = 'claude-sonnet-4-20250514';

const SYSTEM_PROMPT = `You are a food label allergen expert. You will receive a text fragment
extracted from a food product label using OCR. Your task is to evaluate
if this fragment is a valid allergen declaration context from a food label.

Respond ONLY with valid JSON, no markdown, no preamble:
{
  "is_valid_label_context": boolean,
  "confidence": float (0.0-1.0),
  "pattern_type": "contains"|"may_contain"|"facility"|"unknown",
  "detected_language": "ISO 639-1 code",
  "translations": {
    "it": "...", "en": "...", "de": "...", "fr": "...",
    "es": "...", "pt": "...", "nl": "...", "pl": "...",
    "ja": "...", "zh": "...", "ko": "...", "ar": "...",
    "tr": "...", "sv": "...", "da": "...", "fi": "..."
  },
  "rejection_reason": "string or null"
}`;

Deno.serve(async (req) => {
  const { record } = await req.json();

  if (!record || record.status !== 'candidate') {
    return new Response(JSON.stringify({ skipped: true }), { status: 200 });
  }

  const anthropicKey = Deno.env.get('ANTHROPIC_API_KEY');
  if (!anthropicKey) {
    return new Response(JSON.stringify({ error: 'Missing ANTHROPIC_API_KEY' }), {
      status: 500,
    });
  }

  // Chiama Claude API
  const claudeResponse = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': anthropicKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: CLAUDE_MODEL,
      max_tokens: 500,
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: 'user',
          content: `Evaluate this text fragment from a food label OCR: "${record.pattern_text}"`,
        },
      ],
    }),
  });

  const claudeData = await claudeResponse.json();
  const responseText = claudeData.content?.[0]?.text ?? '';

  let validation;
  try {
    validation = JSON.parse(responseText);
  } catch {
    return new Response(JSON.stringify({ error: 'Failed to parse Claude response' }), {
      status: 500,
    });
  }

  // Aggiorna il record con la validazione
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  if (validation.is_valid_label_context && validation.confidence >= 0.7) {
    await supabase
      .from('context_patterns')
      .update({
        confidence: validation.confidence,
        pattern_type: validation.pattern_type,
        language_code: validation.detected_language,
      })
      .eq('id', record.id);
  } else {
    // Scarta il pattern
    await supabase
      .from('context_patterns')
      .delete()
      .eq('id', record.id);
  }

  return new Response(JSON.stringify({ validated: true, result: validation }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
