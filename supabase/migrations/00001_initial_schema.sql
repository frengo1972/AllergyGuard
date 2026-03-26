-- AllergyGuard - Schema iniziale
-- Tabella allergeni master
CREATE TABLE allergens (
  id           SERIAL PRIMARY KEY,
  name_key     TEXT NOT NULL UNIQUE,
  names        JSONB NOT NULL,
  severity     TEXT DEFAULT 'high',
  eu_regulated BOOLEAN DEFAULT false,
  created_at   TIMESTAMP DEFAULT NOW()
);

-- Tabella pattern di contesto multilingua
CREATE TABLE context_patterns (
  id              SERIAL PRIMARY KEY,
  pattern_text    TEXT NOT NULL,
  language_code   TEXT NOT NULL,
  pattern_type    TEXT NOT NULL,
  confidence      FLOAT DEFAULT 0.0,
  status          TEXT DEFAULT 'candidate',
  seen_count      INT DEFAULT 1,
  device_ids      TEXT[] DEFAULT '{}',
  source_ocr_text TEXT,
  created_at      TIMESTAMP DEFAULT NOW(),
  promoted_at     TIMESTAMP,
  UNIQUE (pattern_text, language_code)
);

-- Tabella report prodotti dalla community
CREATE TABLE product_reports (
  id            SERIAL PRIMARY KEY,
  barcode       TEXT NOT NULL,
  product_name  TEXT,
  brand         TEXT,
  allergen_id   INT REFERENCES allergens(id),
  report_type   TEXT NOT NULL,
  device_id     TEXT,
  confirmed_by  TEXT[] DEFAULT '{}',
  created_at    TIMESTAMP DEFAULT NOW()
);

-- Tabella storico scansioni (sync cloud per utenti registrati)
CREATE TABLE scan_history (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  barcode      TEXT,
  product_name TEXT,
  ocr_text     TEXT,
  result       TEXT NOT NULL,
  confidence   FLOAT,
  allergens    TEXT[],
  scanned_at   TIMESTAMP DEFAULT NOW()
);

-- Indici
CREATE INDEX idx_context_patterns_status ON context_patterns(status);
CREATE INDEX idx_context_patterns_language ON context_patterns(language_code);
CREATE INDEX idx_product_reports_barcode ON product_reports(barcode);
CREATE INDEX idx_scan_history_user ON scan_history(user_id);

-- RLS (Row Level Security)
ALTER TABLE scan_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own scan history"
  ON scan_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own scan history"
  ON scan_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own scan history"
  ON scan_history FOR DELETE
  USING (auth.uid() = user_id);

-- context_patterns: lettura pubblica, scrittura da service role
ALTER TABLE context_patterns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read verified patterns"
  ON context_patterns FOR SELECT
  USING (status = 'verified');

CREATE POLICY "Anyone can insert candidate patterns"
  ON context_patterns FOR INSERT
  WITH CHECK (status = 'candidate');

-- product_reports: lettura pubblica, inserimento libero
ALTER TABLE product_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read product reports"
  ON product_reports FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert product reports"
  ON product_reports FOR INSERT
  WITH CHECK (true);
