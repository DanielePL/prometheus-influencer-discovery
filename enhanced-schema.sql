-- ERWEITERTE SCHEMA FÜR VOLLSTÄNDIGES DASHBOARD
-- Führen Sie dies in Supabase SQL Editor aus

-- 1. Löschen Sie die Tabelle falls sie existiert (mit CASCADE für abhängige Objekte)
DROP TABLE IF EXISTS influencers CASCADE;

-- 2. Erstellen Sie die vollständige Tabelle mit allen benötigten Spalten
CREATE TABLE influencers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    handle TEXT UNIQUE NOT NULL,
    bio TEXT,
    follower_count INTEGER DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0.0,
    post_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'new_lead' CHECK (status IN ('new_lead', 'contacted', 'negotiating', 'partner', 'rejected', 'inactive')),
    assigned_to TEXT,
    category_tags TEXT[] DEFAULT '{}',
    instagram_url TEXT,
    last_contact_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. RLS ausschalten für Tests (kann später aktiviert werden)
ALTER TABLE influencers DISABLE ROW LEVEL SECURITY;

-- 4. Indexe für bessere Performance
CREATE INDEX idx_influencers_status ON influencers(status);
CREATE INDEX idx_influencers_handle ON influencers(handle);
CREATE INDEX idx_influencers_follower_count ON influencers(follower_count);
CREATE INDEX idx_influencers_engagement_rate ON influencers(engagement_rate);
CREATE INDEX idx_influencers_assigned_to ON influencers(assigned_to);
CREATE INDEX idx_influencers_created_at ON influencers(created_at);

-- 5. Trigger für updated_at automatische Aktualisierung
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_influencers_updated_at 
    BEFORE UPDATE ON influencers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 6. Test-Insert um Schema zu verifizieren
INSERT INTO influencers (
    name, 
    handle, 
    bio, 
    follower_count, 
    engagement_rate, 
    status, 
    assigned_to, 
    category_tags,
    instagram_url
) VALUES (
    'Test Schema User', 
    '@test_schema_' || extract(epoch from now())::text, 
    'This is a test bio to verify the schema is working correctly', 
    25000, 
    4.5, 
    'new_lead', 
    'System Admin', 
    ARRAY['test', 'schema', 'verification'],
    'https://instagram.com/test_schema'
);

-- 7. Daten anzeigen zur Bestätigung
SELECT 
    id,
    name,
    handle,
    bio,
    follower_count,
    engagement_rate,
    status,
    assigned_to,
    category_tags,
    instagram_url,
    created_at
FROM influencers;

-- 8. Schema-Info anzeigen
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'influencers' 
ORDER BY ordinal_position;
