# 🚀 Supabase Setup & Testing Guide

## STEP 1: Database Schema Setup

### 1.1 Führe das Schema SQL aus

Kopiere den Inhalt von `supabase-schema.sql` und führe ihn im Supabase SQL Editor aus:

```sql
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
```

### 1.2 Führe die Beispieldaten aus

Kopiere den Inhalt von `sample-data.sql` und führe ihn aus:

```sql
-- Team-Mitglieder einfügen
INSERT INTO team_members (name, email, avatar, role) VALUES
  ('Sarah Martinez', 'sarah.martinez@prometheus.com', 'SM', 'manager'),
  ('Tom Wilson', 'tom.wilson@prometheus.com', 'TW', 'specialist'),
  -- ... weitere Daten
```

## STEP 2: Connection Testing

### 2.1 Teste die Verbindung

1. Öffne `test-connection.html` im Browser
2. Trage deine Supabase URL und Anon Key ein
3. Klicke durch alle Test-Schritte:
   - ✅ Test Connection
   - ✅ Test Schema  
   - ✅ Test Insert
   - ✅ Test Read
   - ✅ Test Update
   - ✅ Test Realtime

### 2.2 Erwartete Ergebnisse

- **Connection**: ✅ Connection initialized successfully
- **Schema**: ✅ Schema exists and accessible  
- **Data Operations**: ✅ Insert/Read/Update successful
- **Realtime**: ✅ Realtime working! (after making changes)

## STEP 3: Dashboard Configuration

### 3.1 Supabase Credentials eingetragen

In `index.html` ersetze:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL_HERE';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY_HERE';
```

Mit deinen echten Werten:

```javascript
const SUPABASE_URL = 'https://xxxxxxxxxxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### 3.2 Realtime aktivieren

Im Supabase Dashboard:
1. Database → Replication
2. Aktiviere Realtime für:
   - ☑️ `influencers`
   - ☑️ `activities`
   - ☑️ `influencer_notes`
   - ☑️ `team_members`

## STEP 4: Verification

### 4.1 Dashboard testen

1. Öffne `index.html` im Browser
2. Browser-Konsole prüfen (F12):

```
✅ Supabase client initialized successfully
✅ Data loaded from Supabase: {influencers: 6, activities: 10}
```

### 4.2 Features prüfen

- **Filter**: Status, Followers, Categories funktionieren
- **Search**: Suche nach Namen/Handle funktioniert  
- **Stats**: Zahlen aktualisieren sich basierend auf Filtern
- **Realtime**: Änderungen in Supabase erscheinen sofort im Dashboard

## 🎯 Schema Updates (Was geändert wurde)

| Alt (Demo) | Neu (Supabase) | Grund |
|------------|-----------------|--------|
| `followers` | `follower_count` | Klarere Benennung |
| `categories` | `category_tags` | Konsistente Array-Benennung |
| `last_contact` | `last_contact_date` | Spezifischere Benennung |
| `status: 'new'` | `status: 'new_lead'` | Explizitere Status-Werte |
| `avatar` (Text) | Generiert aus Handle | Dynamische Avatar-Generierung |
| `verified` (Boolean) | Basierend auf Follower-Count | Vereinfachte Verifikation |

## 🚨 Troubleshooting

### Problem: "Schema test failed"
**Lösung**: 
- Schema SQL komplett ausführen
- RLS-Policies prüfen
- Tabellen-Permissions kontrollieren

### Problem: "Data loaded from Supabase: {influencers: 0}"
**Lösung**:
- Sample-Data SQL ausführen
- INSERT-Statements einzeln testen
- Constraint-Violations prüfen

### Problem: "Realtime not working"
**Lösung**:
- Realtime für Tabellen aktivieren
- Browser-Cache leeren
- WebSocket-Verbindungen prüfen

---

**Nach erfolgreichem Setup**: Dashboard ist live mit echter Datenbank! 🎉
