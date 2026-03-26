// Edge Function: sync-patterns
// Chiamata dal client per aggiornamento incrementale del JSON locale.
// Restituisce tutti i pattern 'verified' più recenti della versione del client.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req) => {
  const { since } = await req.json();

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  let query = supabase
    .from('context_patterns')
    .select('id, pattern_text, language_code, pattern_type, confidence, status, promoted_at')
    .eq('status', 'verified');

  if (since) {
    query = query.gte('promoted_at', since);
  }

  const { data, error } = await query;

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  return new Response(
    JSON.stringify({
      patterns: data,
      count: data?.length ?? 0,
      synced_at: new Date().toISOString(),
    }),
    { headers: { 'Content-Type': 'application/json' } },
  );
});
