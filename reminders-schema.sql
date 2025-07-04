-- FOLLOW-UP REMINDERS SYSTEM SCHEMA
-- Erweitert das Prometheus Dashboard um ein vollständiges Reminder-System

-- 1. Reminders Tabelle erstellen
CREATE TABLE IF NOT EXISTS reminders (
    id BIGSERIAL PRIMARY KEY,
    influencer_id BIGINT REFERENCES influencers(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    reminder_type TEXT DEFAULT 'follow_up' CHECK (reminder_type IN ('follow_up', 'deadline', 'meeting', 'call', 'email', 'review')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    assigned_to TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'snoozed', 'cancelled')),
    snooze_until TIMESTAMP WITH TIME ZONE,
    completion_notes TEXT,
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 2. Automatic Reminder Rules Tabelle
CREATE TABLE IF NOT EXISTS reminder_rules (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    trigger_condition TEXT NOT NULL, -- JSON: {"status": "contacted", "days_since": 3}
    reminder_template TEXT NOT NULL, -- Template für automatische Reminders
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Notification Settings Tabelle
CREATE TABLE IF NOT EXISTS notification_settings (
    id BIGSERIAL PRIMARY KEY,
    user_email TEXT NOT NULL,
    reminder_types TEXT[] DEFAULT ARRAY['follow_up', 'deadline', 'meeting'],
    notification_methods TEXT[] DEFAULT ARRAY['dashboard', 'email'],
    advance_notice_hours INTEGER DEFAULT 24,
    daily_digest_time TIME DEFAULT '09:00:00',
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Indexe für Performance
CREATE INDEX IF NOT EXISTS idx_reminders_influencer_id ON reminders(influencer_id);
CREATE INDEX IF NOT EXISTS idx_reminders_due_date ON reminders(due_date);
CREATE INDEX IF NOT EXISTS idx_reminders_assigned_to ON reminders(assigned_to);
CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders(status);
CREATE INDEX IF NOT EXISTS idx_reminders_priority ON reminders(priority);
CREATE INDEX IF NOT EXISTS idx_reminders_type ON reminders(reminder_type);

-- 5. Trigger für updated_at
CREATE OR REPLACE FUNCTION update_reminder_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        NEW.completed_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_reminders_updated_at ON reminders;
CREATE TRIGGER update_reminders_updated_at 
    BEFORE UPDATE ON reminders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_reminder_updated_at();

-- 6. Standard Reminder Rules einfügen
INSERT INTO reminder_rules (name, description, trigger_condition, reminder_template, is_active) VALUES
('Follow-up after Contact', 'Automatische Erinnerung 3 Tage nach erstem Kontakt', '{"status_change": "contacted", "days_after": 3}', 'Follow up with {influencer_name} - 3 days since initial contact', true),
('Negotiation Check-in', 'Wöchentliche Erinnerung während Verhandlungsphase', '{"status": "negotiating", "days_since_update": 7}', 'Check negotiation progress with {influencer_name}', true),
('Partnership Review', 'Monatliche Partner-Review', '{"status": "partner", "days_since_update": 30}', 'Monthly review with partner {influencer_name}', true),
('Stale Lead Cleanup', 'Aufräumen alter Leads ohne Aktivität', '{"status": "new_lead", "days_since_created": 14}', 'Review stale lead: {influencer_name} - no activity for 2 weeks', true);

-- 7. Standard Notification Settings
INSERT INTO notification_settings (user_email, reminder_types, notification_methods, advance_notice_hours, daily_digest_time) VALUES
('admin@prometheus.com', ARRAY['follow_up', 'deadline', 'meeting', 'call'], ARRAY['dashboard', 'email'], 24, '09:00:00'),
('team@prometheus.com', ARRAY['follow_up', 'meeting'], ARRAY['dashboard'], 4, '10:00:00');

-- 8. Test Reminders einfügen (für Demo)
INSERT INTO reminders (influencer_id, title, description, reminder_type, priority, due_date, assigned_to, created_by) 
SELECT 
    i.id,
    'Follow up with ' || i.name,
    'Check on partnership progress and next steps',
    'follow_up',
    CASE 
        WHEN i.status = 'negotiating' THEN 'high'
        WHEN i.status = 'contacted' THEN 'medium'
        ELSE 'low'
    END,
    NOW() + INTERVAL '2 days',
    COALESCE(i.assigned_to, 'Team'),
    'System'
FROM influencers i 
WHERE i.status IN ('contacted', 'negotiating')
LIMIT 5;

-- 9. Views für einfache Abfragen
CREATE OR REPLACE VIEW active_reminders AS
SELECT 
    r.*,
    i.name as influencer_name,
    i.handle as influencer_handle,
    i.status as influencer_status,
    i.follower_count,
    CASE 
        WHEN r.due_date < NOW() THEN 'overdue'
        WHEN r.due_date < NOW() + INTERVAL '24 hours' THEN 'due_soon'
        ELSE 'upcoming'
    END as urgency_status
FROM reminders r
JOIN influencers i ON r.influencer_id = i.id
WHERE r.status = 'pending' 
   OR (r.status = 'snoozed' AND r.snooze_until <= NOW())
ORDER BY r.due_date ASC;

CREATE OR REPLACE VIEW reminder_dashboard AS
SELECT 
    assigned_to,
    COUNT(*) as total_reminders,
    COUNT(CASE WHEN due_date < NOW() THEN 1 END) as overdue_count,
    COUNT(CASE WHEN due_date < NOW() + INTERVAL '24 hours' THEN 1 END) as due_today_count,
    COUNT(CASE WHEN priority = 'urgent' THEN 1 END) as urgent_count,
    COUNT(CASE WHEN priority = 'high' THEN 1 END) as high_priority_count
FROM reminders 
WHERE status IN ('pending', 'snoozed')
GROUP BY assigned_to
ORDER BY total_reminders DESC;

-- 10. RLS für Security (optional)
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

-- Policies für authentifizierte Benutzer
CREATE POLICY "Allow all operations for authenticated users" ON reminders
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all operations for authenticated users" ON reminder_rules
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all operations for authenticated users" ON notification_settings
    FOR ALL USING (auth.role() = 'authenticated');

-- 11. Validierung und Erfolgsmeldung
SELECT 'Follow-up Reminders Schema erfolgreich erstellt!' as result;

SELECT 
    'Tabellen erstellt:' as info,
    COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_name IN ('reminders', 'reminder_rules', 'notification_settings');

SELECT 
    'Test-Reminders erstellt:' as info,
    COUNT(*) as reminder_count
FROM reminders;

SELECT 
    'Aktive Reminder-Rules:' as info,
    COUNT(*) as rule_count
FROM reminder_rules WHERE is_active = true;
