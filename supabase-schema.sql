-- Prometheus Influencer Discovery - Supabase Database Schema
-- Führe dieses SQL im Supabase SQL Editor aus

-- Influencers table (updated schema)
CREATE TABLE influencers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    handle VARCHAR(100) UNIQUE NOT NULL,
    bio TEXT,
    follower_count INTEGER DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0.0,
    post_count INTEGER DEFAULT 0,
    
    -- Status and workflow
    status VARCHAR(50) DEFAULT 'new_lead',
    assigned_to VARCHAR(100),
    last_contact_date TIMESTAMP,
    notes TEXT,
    
    -- Categories and tags
    category_tags TEXT[], -- Array of tags like ['fitness', 'female', 'dach']
    
    -- Contact information
    email VARCHAR(255),
    instagram_url VARCHAR(255),
    tiktok_url VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_influencers_status ON influencers(status);
CREATE INDEX idx_influencers_assigned ON influencers(assigned_to);
CREATE INDEX idx_influencers_follower_count ON influencers(follower_count);

-- Aktivitäten-Feed
CREATE TABLE activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  value VARCHAR(255),
  avatar VARCHAR(10),
  user_id VARCHAR(100),
  influencer_id UUID REFERENCES influencers(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Team-Mitglieder
CREATE TABLE team_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  avatar VARCHAR(10),
  role VARCHAR(50) DEFAULT 'member',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Influencer-Notizen (für detaillierte Notizen)
CREATE TABLE influencer_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  influencer_id UUID REFERENCES influencers(id) ON DELETE CASCADE,
  author VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Kampagnen (für zukünftige Erweiterungen)
CREATE TABLE campaigns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  budget DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'planning',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Influencer-Kampagnen-Zuordnung
CREATE TABLE campaign_influencers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
  influencer_id UUID REFERENCES influencers(id) ON DELETE CASCADE,
  fee DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Additional indexes for better performance
CREATE INDEX idx_activities_created_at ON activities(created_at);
CREATE INDEX idx_activities_type ON activities(type);
CREATE INDEX idx_influencer_notes_influencer_id ON influencer_notes(influencer_id);

-- RLS (Row Level Security) aktivieren
ALTER TABLE influencers ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE influencer_notes ENABLE ROW LEVEL SECURITY;

-- Basis-Policies (öffentlicher Zugriff für Demo - in Produktion anpassen!)
CREATE POLICY "Allow all operations for now" ON influencers FOR ALL USING (true);
CREATE POLICY "Allow all operations for now" ON activities FOR ALL USING (true);
CREATE POLICY "Allow all operations for now" ON team_members FOR ALL USING (true);
CREATE POLICY "Allow all operations for now" ON influencer_notes FOR ALL USING (true);

-- Update-Trigger für updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER update_influencers_updated_at
    BEFORE UPDATE ON influencers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Funktion für automatische Aktivitäts-Erstellung
CREATE OR REPLACE FUNCTION create_activity_on_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO activities (type, content, value, avatar, influencer_id)
        VALUES (
            'status_change',
            'Status changed from ' || OLD.status || ' to ' || NEW.status,
            NEW.handle,
            'S',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER status_change_activity
    AFTER UPDATE ON influencers
    FOR EACH ROW EXECUTE FUNCTION create_activity_on_status_change();
