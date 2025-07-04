-- MINIMAL SCHEMA FÜR SCHNELLEN TEST
-- Führen Sie dies in Supabase SQL Editor aus

-- 1. Löschen Sie die Tabelle falls sie existiert
DROP TABLE IF EXISTS influencers CASCADE;

-- 2. Erstellen Sie eine einfache Tabelle
CREATE TABLE influencers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    handle TEXT UNIQUE NOT NULL,
    bio TEXT,
    follower_count INTEGER DEFAULT 0,
    engagement_rate DECIMAL(4,2) DEFAULT 0.0,
    status TEXT DEFAULT 'new_lead',
    assigned_to TEXT,
    category_tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. RLS ausschalten für Tests
ALTER TABLE influencers DISABLE ROW LEVEL SECURITY;

-- 4. Index für bessere Performance
CREATE INDEX idx_influencers_status ON influencers(status);
CREATE INDEX idx_influencers_handle ON influencers(handle);

-- 5. Test-Insert um zu verifizieren
INSERT INTO influencers (name, handle, bio, follower_count, engagement_rate, status, assigned_to, category_tags) 
VALUES ('Test User', '@test_user', 'Test bio', 1000, 5.0, 'new_lead', 'Admin', ARRAY['test']);

-- 6. Daten anzeigen
SELECT * FROM influencers;
