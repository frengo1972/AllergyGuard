// Edge Function: promote-patterns
// Schedulata ogni 24h. Promuove pattern candidati a verificati
// quando raggiungono le soglie: seen_count >= 5, device_ids.length >= 3.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const PROMOTE_SEEN_COUNT = 5;
const PROMOTE_DEVICE_COUNT = 3;

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: candidates, error } = await supabase
    .from('context_patterns')
    .select('*')
    .eq('status', 'candidate')
    .gte('seen_count', PROMOTE_SEEN_COUNT);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  let promoted = 0;
  for (const pattern of candidates ?? []) {
    const deviceCount = (pattern.device_ids ?? []).length;
    if (deviceCount >= PROMOTE_DEVICE_COUNT) {
      await supabase
        .from('context_patterns')
        .update({
          status: 'verified',
          promoted_at: new Date().toISOString(),
        })
        .eq('id', pattern.id);
      promoted++;
    }
  }

  return new Response(
    JSON.stringify({ promoted, checked: candidates?.length ?? 0 }),
    { headers: { 'Content-Type': 'application/json' } },
  );
});
