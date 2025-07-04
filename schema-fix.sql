-- SCHEMA-KORREKTUR FÜR PROMETHEUS DASHBOARD
-- Führe dieses SQL in Supabase SQL Editor aus, um fehlende Spalten hinzuzufügen

-- 1. Fehlende Spalten zur influencers Tabelle hinzufügen
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS category_tags TEXT[] DEFAULT '{}';
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS instagram_url TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS post_count INTEGER DEFAULT 0;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS last_contact_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Verbessere bestehende Spalten falls nötig
ALTER TABLE influencers ALTER COLUMN engagement_rate TYPE DECIMAL(5,2);
ALTER TABLE influencers ALTER COLUMN status SET DEFAULT 'new_lead';

-- 3. Index für bessere Performance
CREATE INDEX IF NOT EXISTS idx_influencers_category_tags ON influencers USING GIN (category_tags);
CREATE INDEX IF NOT EXISTS idx_influencers_status ON influencers(status);
CREATE INDEX IF NOT EXISTS idx_influencers_assigned_to ON influencers(assigned_to);
CREATE INDEX IF NOT EXISTS idx_influencers_follower_count ON influencers(follower_count);

-- 4. Trigger für automatische updated_at Aktualisierung
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_influencers_updated_at ON influencers;
CREATE TRIGGER update_influencers_updated_at 
    BEFORE UPDATE ON influencers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 5. Validierung: Alle Spalten anzeigen
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'influencers' 
ORDER BY ordinal_position;

-- 6. Test-Insert um zu verifizieren
INSERT INTO influencers (
    name, 
    handle, 
    bio, 
    follower_count, 
    engagement_rate, 
    status, 
    assigned_to, 
    category_tags,
    instagram_url,
    post_count,
    notes
) VALUES (
    'Schema Test User', 
    '@schema_fix_' || extract(epoch from now())::text, 
    'Test nach Schema-Korrektur', 
    15000, 
    3.8, 
    'new_lead', 
    'System', 
    ARRAY['test', 'schema', 'fix'],
    'https://instagram.com/schema_test',
    250,
    'Schema erfolgreich korrigiert!'
) ON CONFLICT (handle) DO NOTHING;

-- 7. Erfolg bestätigen
SELECT 'Schema-Korrektur erfolgreich! Dashboard sollte jetzt funktionieren.' AS result;
