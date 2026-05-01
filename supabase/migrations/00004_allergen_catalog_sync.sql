-- Estende il catalogo allergeni per supportare sync remota, badge dinamici
-- e metadati per mostrare i nuovi allergeni aggiunti.

ALTER TABLE allergens
  ADD COLUMN IF NOT EXISTS search_terms JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS icon_type TEXT DEFAULT 'bundle',
  ADD COLUMN IF NOT EXISTS icon_emoji TEXT,
  ADD COLUMN IF NOT EXISTS icon_color TEXT,
  ADD COLUMN IF NOT EXISTS dataset_version INT DEFAULT 1,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

UPDATE allergens
SET
  search_terms = COALESCE(search_terms, '{}'::jsonb),
  icon_type = COALESCE(icon_type, 'bundle'),
  dataset_version = COALESCE(dataset_version, 1),
  updated_at = COALESCE(updated_at, NOW()),
  is_active = COALESCE(is_active, true);

ALTER TABLE allergens
  ALTER COLUMN search_terms SET DEFAULT '{}'::jsonb,
  ALTER COLUMN icon_type SET DEFAULT 'bundle',
  ALTER COLUMN dataset_version SET DEFAULT 1,
  ALTER COLUMN updated_at SET DEFAULT NOW(),
  ALTER COLUMN is_active SET DEFAULT true;

CREATE TABLE IF NOT EXISTS app_datasets (
  dataset_name TEXT PRIMARY KEY,
  version      INT NOT NULL DEFAULT 1,
  updated_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  summary      TEXT,
  added_keys   TEXT[] NOT NULL DEFAULT '{}'
);

INSERT INTO app_datasets (
  dataset_name,
  version,
  updated_at,
  summary,
  added_keys
)
VALUES (
  'allergens',
  1,
  NOW(),
  'Initial bundled allergen catalog',
  '{}'::TEXT[]
)
ON CONFLICT (dataset_name) DO NOTHING;

ALTER TABLE app_datasets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read app datasets" ON app_datasets;
CREATE POLICY "Anyone can read app datasets"
  ON app_datasets FOR SELECT
  USING (true);
