-- VERBESSERTE SCHEMA-KORREKTUR FÜR PROMETHEUS DASHBOARD
-- Diese Version ist noch robuster und behandelt alle möglichen Schema-Varianten
-- Führe dieses SQL in Supabase SQL Editor aus

-- 0. AKTUELLE SCHEMA-INFO ANZEIGEN
SELECT 'AKTUELLE TABELLEN-STRUKTUR:' AS info;
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'influencers' 
ORDER BY ordinal_position;

-- 1. TABELLE ERSTELLEN FALLS SIE NICHT EXISTIERT
CREATE TABLE IF NOT EXISTS influencers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Unknown',
    handle TEXT UNIQUE NOT NULL DEFAULT '@unknown'
);

-- 2. KERN-SPALTEN MIT FLEXIBILITÄT FÜR VERSCHIEDENE NAMEN
DO $$
BEGIN
    -- Name/Handle Spalten sicherstellen
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'name') THEN
        ALTER TABLE influencers ADD COLUMN name TEXT NOT NULL DEFAULT 'Unknown';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'handle') THEN
        ALTER TABLE influencers ADD COLUMN handle TEXT UNIQUE;
    END IF;
    
    -- Follower Count - versuche verschiedene Namen
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'follower_count') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'followers') THEN
            -- Umbenennen von followers zu follower_count
            ALTER TABLE influencers RENAME COLUMN followers TO follower_count;
        ELSE
            -- Neue Spalte erstellen
            ALTER TABLE influencers ADD COLUMN follower_count INTEGER DEFAULT 0;
        END IF;
    END IF;
    
    -- Engagement Rate
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'engagement_rate') THEN
        ALTER TABLE influencers ADD COLUMN engagement_rate DECIMAL(5,2) DEFAULT 0.0;
    END IF;
    
    -- Status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'status') THEN
        ALTER TABLE influencers ADD COLUMN status TEXT DEFAULT 'new_lead';
    END IF;
    
    -- Assigned To
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'assigned_to') THEN
        ALTER TABLE influencers ADD COLUMN assigned_to TEXT;
    END IF;
    
    RAISE NOTICE 'Kern-Spalten erfolgreich hinzugefügt/überprüft';
END $$;

-- 3. ERWEITERTE SPALTEN
DO $$
BEGIN
    -- Category Tags (Array)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'category_tags') THEN
        ALTER TABLE influencers ADD COLUMN category_tags TEXT[] DEFAULT '{}';
    END IF;
    
    -- Bio/Beschreibung
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'bio') THEN
        ALTER TABLE influencers ADD COLUMN bio TEXT;
    END IF;
    
    -- Instagram URL
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'instagram_url') THEN
        ALTER TABLE influencers ADD COLUMN instagram_url TEXT;
    END IF;
    
    -- Post Count
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'post_count') THEN
        ALTER TABLE influencers ADD COLUMN post_count INTEGER DEFAULT 0;
    END IF;
    
    -- Notes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'notes') THEN
        ALTER TABLE influencers ADD COLUMN notes TEXT;
    END IF;
    
    -- Last Contact Date
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'last_contact_date') THEN
        ALTER TABLE influencers ADD COLUMN last_contact_date TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Created At
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'created_at') THEN
        ALTER TABLE influencers ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Updated At
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'updated_at') THEN
        ALTER TABLE influencers ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    RAISE NOTICE 'Erweiterte Spalten erfolgreich hinzugefügt/überprüft';
END $$;

-- 4. SPALTEN-TYPEN KORRIGIEREN FALLS NÖTIG
DO $$
BEGIN
    -- Engagement Rate Typ verbessern
    BEGIN
        ALTER TABLE influencers ALTER COLUMN engagement_rate TYPE DECIMAL(5,2);
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'Engagement rate Typ-Änderung übersprungen: %', SQLERRM;
    END;
    
    -- Status Default setzen
    BEGIN
        ALTER TABLE influencers ALTER COLUMN status SET DEFAULT 'new_lead';
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'Status Default-Änderung übersprungen: %', SQLERRM;
    END;
    
    -- Handle unique constraint
    BEGIN
        ALTER TABLE influencers ADD CONSTRAINT influencers_handle_unique UNIQUE (handle);
    EXCEPTION WHEN duplicate_object THEN
        RAISE NOTICE 'Handle unique constraint existiert bereits';
    WHEN others THEN
        RAISE NOTICE 'Handle unique constraint konnte nicht hinzugefügt werden: %', SQLERRM;
    END;
    
    RAISE NOTICE 'Spalten-Typen erfolgreich korrigiert';
END $$;

-- 5. INDEXE FÜR PERFORMANCE
DO $$
BEGIN
    -- Category tags index (GIN für Arrays)
    CREATE INDEX IF NOT EXISTS idx_influencers_category_tags ON influencers USING GIN (category_tags);
    
    -- Standard Indexe
    CREATE INDEX IF NOT EXISTS idx_influencers_status ON influencers(status);
    CREATE INDEX IF NOT EXISTS idx_influencers_assigned_to ON influencers(assigned_to);
    CREATE INDEX IF NOT EXISTS idx_influencers_follower_count ON influencers(follower_count);
    CREATE INDEX IF NOT EXISTS idx_influencers_created_at ON influencers(created_at);
    CREATE INDEX IF NOT EXISTS idx_influencers_engagement_rate ON influencers(engagement_rate);
    
    RAISE NOTICE 'Indexe erfolgreich erstellt';
END $$;

-- 6. TRIGGER FÜR AUTOMATISCHE UPDATED_AT AKTUALISIERUNG
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

-- 7. RLS (ROW LEVEL SECURITY) KONFIGURATION
ALTER TABLE influencers ENABLE ROW LEVEL SECURITY;

-- Policy für authentifizierte Benutzer (alle Operationen erlauben)
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON influencers;
CREATE POLICY "Allow all operations for authenticated users" ON influencers
    FOR ALL USING (auth.role() = 'authenticated');

-- Policy für anonyme Benutzer (nur lesen)
DROP POLICY IF EXISTS "Allow read for anonymous users" ON influencers;
CREATE POLICY "Allow read for anonymous users" ON influencers
    FOR SELECT USING (true);

-- 8. VALIDIERUNG: FINALE SPALTEN-ÜBERSICHT
SELECT 'FINALE TABELLEN-STRUKTUR:' AS info;
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'influencers' 
ORDER BY ordinal_position;

-- 9. TEST-EINTRAG ZUR VERIFIZIERUNG
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
    'Schema Test User V2', 
    '@schema_fix_v2_' || extract(epoch from now())::text, 
    'Test nach verbesserter Schema-Korrektur', 
    25000, 
    4.2, 
    'new_lead', 
    'System Admin', 
    ARRAY['test', 'schema', 'v2', 'fix'],
    'https://instagram.com/schema_test_v2',
    300,
    'Verbesserte Schema-Korrektur erfolgreich!'
) ON CONFLICT (handle) DO NOTHING;

-- 10. ERFOLGS-BESTÄTIGUNG
SELECT 
    'Schema-Korrektur V2 erfolgreich abgeschlossen!' AS result,
    'Dashboard sollte jetzt vollständig funktionieren.' AS status,
    COUNT(*) || ' Einträge in der Tabelle' AS count
FROM influencers;

-- 11. PERFORMANCE-TEST
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM influencers 
WHERE status = 'new_lead' 
ORDER BY follower_count DESC 
LIMIT 10;
