-- AllergyGuard - Feedback utenti anonimi
-- Tabella feedback utente per monitorare accuratezza scan e raccogliere suggerimenti
CREATE TABLE user_feedback (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id        TEXT NOT NULL,
  feedback_type    TEXT NOT NULL CHECK (feedback_type IN ('scan_accuracy', 'suggestion', 'bug_report', 'general')),
  result_level     TEXT CHECK (result_level IN ('danger', 'warning', 'safe', 'unknown')),
  is_correct       BOOLEAN,
  expected_level   TEXT CHECK (expected_level IN ('danger', 'warning', 'safe', 'unknown')),
  product_barcode  TEXT,
  allergen_keys    TEXT[] DEFAULT '{}',
  comment          TEXT,
  language_code    TEXT,
  country_code     TEXT,
  app_version      TEXT,
  created_at       TIMESTAMP DEFAULT NOW()
);

-- Indici per analytics aggregate
CREATE INDEX idx_user_feedback_type ON user_feedback(feedback_type);
CREATE INDEX idx_user_feedback_created ON user_feedback(created_at);
CREATE INDEX idx_user_feedback_barcode ON user_feedback(product_barcode) WHERE product_barcode IS NOT NULL;

-- RLS: chiunque puo inserire (anonimo), nessuno legge (solo service role)
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert feedback"
  ON user_feedback FOR INSERT
  WITH CHECK (true);

-- Nessuna policy SELECT: solo il service role puo leggere per analytics

-- Vista aggregata pubblica: numero feedback per tipo (senza contenuti)
CREATE VIEW user_feedback_stats AS
SELECT
  feedback_type,
  result_level,
  is_correct,
  country_code,
  DATE_TRUNC('day', created_at) AS day,
  COUNT(*) AS count
FROM user_feedback
GROUP BY feedback_type, result_level, is_correct, country_code, DATE_TRUNC('day', created_at);
