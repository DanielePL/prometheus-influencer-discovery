-- SCHEMA-KORREKTUR FÜR PROMETHEUS DASHBOARD
-- Führe dieses SQL in Supabase SQL Editor aus, um fehlende Spalten hinzuzufügen

-- 0. AKTUELLE SCHEMA-INFO ANZEIGEN (zum Debuggen)
SELECT 'AKTUELLE SPALTEN IN DER TABELLE:' AS info;
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'influencers' 
ORDER BY ordinal_position;

-- 1. Grundlegende Spalten hinzufügen (falls sie nicht existieren)
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS id BIGSERIAL PRIMARY KEY;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT 'Unknown';
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS handle TEXT UNIQUE NOT NULL DEFAULT '@unknown';

-- 2. Standard-Spalten mit verschiedenen möglichen Namen
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS followers INTEGER DEFAULT 0; -- Alternative Name
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS engagement_rate DECIMAL(5,2) DEFAULT 0.0;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'new_lead';
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS assigned_to TEXT;

-- 3. Erweiterte Spalten für volles Dashboard
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS category_tags TEXT[] DEFAULT '{}';
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS instagram_url TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS post_count INTEGER DEFAULT 0;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS last_contact_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 4. Fallback: Wenn follower_count nicht existiert, aber followers existiert
DO $$
BEGIN
    -- Prüfe ob follower_count existiert, falls nicht und followers existiert, erstelle Alias-View
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'influencers' AND column_name = 'follower_count'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'influencers' AND column_name = 'followers'
    ) THEN
        -- Kopiere Daten von followers zu follower_count falls vorhanden
        ALTER TABLE influencers ADD COLUMN follower_count INTEGER DEFAULT 0;
        UPDATE influencers SET follower_count = followers WHERE followers IS NOT NULL;
    END IF;
END $$;

-- 5. Verbessere bestehende Spalten falls nötig (mit Fehlerbehandlung)
DO $$
BEGIN
    -- Engagement rate verbessern falls Spalte existiert
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'influencers' AND column_name = 'engagement_rate'
    ) THEN
        BEGIN
            ALTER TABLE influencers ALTER COLUMN engagement_rate TYPE DECIMAL(5,2);
        EXCEPTION WHEN others THEN
            -- Ignoriere Fehler falls Typ-Konvertierung nicht möglich
            NULL;
        END;
    END IF;
    
    -- Status Default setzen falls Spalte existiert
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'influencers' AND column_name = 'status'
    ) THEN
        BEGIN
            ALTER TABLE influencers ALTER COLUMN status SET DEFAULT 'new_lead';
        EXCEPTION WHEN others THEN
            -- Ignoriere Fehler
            NULL;
        END;
    END IF;
END $$;

-- 6. Index für bessere Performance (nur falls Spalten existieren)
DO $$
BEGIN
    -- Category tags index (GIN für Arrays)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'influencers' AND column_name = 'category_tags'
    ) THEN
        CREATE INDEX IF NOT EXISTS idx_influencers_category_tags ON influencers USING GIN (category_tags);
    END IF;
    
    -- Andere Indexe
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'status') THEN
        CREATE INDEX IF NOT EXISTS idx_influencers_status ON influencers(status);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'assigned_to') THEN
        CREATE INDEX IF NOT EXISTS idx_influencers_assigned_to ON influencers(assigned_to);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'follower_count') THEN
        CREATE INDEX IF NOT EXISTS idx_influencers_follower_count ON influencers(follower_count);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'created_at') THEN
        CREATE INDEX IF NOT EXISTS idx_influencers_created_at ON influencers(created_at);
    END IF;
END $$;

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
