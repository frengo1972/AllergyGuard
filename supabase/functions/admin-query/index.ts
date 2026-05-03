import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'content-type, x-admin-secret',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS })

  const secret = req.headers.get('x-admin-secret')
  const ADMIN_SECRET = Deno.env.get('ADMIN_DASHBOARD_SECRET')
  if (!ADMIN_SECRET || secret !== ADMIN_SECRET) {
    return Response.json({ error: 'Unauthorized' }, { status: 401, headers: CORS })
  }

  const sb = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } }
  )

  let body: Record<string, unknown>
  try { body = await req.json() } catch { return Response.json({ error: 'Invalid JSON' }, { status: 400, headers: CORS }) }

  const { action, table } = body as { action: string; table: string }

  try {
    if (action === 'ping') return Response.json({ ok: true }, { headers: CORS })

    if (action === 'count') {
      let q = sb.from(table).select('*', { count: 'exact', head: true })
      for (const [k, v] of Object.entries((body.filters as Record<string, string>) || {})) {
        if (v) q = q.eq(k, v)
      }
      const { count, error } = await q
      if (error) throw error
      return Response.json({ count }, { headers: CORS })
    }

    if (action === 'col') {
      const { data, error } = await sb.from(table).select(body.col as string).limit(2000)
      if (error) throw error
      return Response.json(data, { headers: CORS })
    }

    // action === 'query'
    const { filters, search, sc, sortCol, sortAsc, page, PS, forExport } =
      body as {
        filters: Record<string, string>; search: string; sc: string[]
        sortCol: string; sortAsc: boolean; page: number; PS: number; forExport: boolean
      }

    let q = sb.from(table).select('*', { count: 'exact' })
    for (const [c, v] of Object.entries(filters || {})) {
      if (v === '' || v == null) continue
      if (v === 'true') q = q.eq(c, true)
      else if (v === 'false') q = q.eq(c, false)
      else q = q.eq(c, v)
    }
    if (search && sc?.length) {
      q = q.or(sc.map(c => `${c}.ilike.%${search}%`).join(','))
    }
    q = q.order(sortCol || 'id', { ascending: sortAsc ?? false })
    if (!forExport) {
      const from = (page || 0) * (PS || 50)
      q = q.range(from, from + (PS || 50) - 1)
    } else {
      q = q.limit(10000)
    }
    const { data, error, count } = await q
    if (error) throw error
    return Response.json({ data, count }, { headers: CORS })

  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e)
    return Response.json({ error: msg }, { status: 500, headers: CORS })
  }
})
