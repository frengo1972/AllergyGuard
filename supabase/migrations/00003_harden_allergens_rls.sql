-- Hardening: allergens è tabella master, solo lettura pubblica, scrittura riservata a service_role
ALTER TABLE allergens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read allergens"
  ON allergens FOR SELECT
  USING (true);

-- Nessuna policy INSERT/UPDATE/DELETE: solo service_role (bypassa RLS) può modificare
