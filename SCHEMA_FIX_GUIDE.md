# 🔧 SCHEMA-PROBLEME BEHEBEN - KOMPLETTE ANLEITUNG

## Problem: "column follower_count does not exist"

Wenn Sie diesen Fehler sehen, bedeutet das, dass Ihre Supabase-Tabelle entweder:
1. Die Spalte `follower_count` nicht hat
2. Die Spalte anders benannt ist (z.B. `followers`)
3. Ein veraltetes/unvollständiges Schema verwendet

## 🚀 SCHNELLE LÖSUNG

### Schritt 1: Verbesserte Schema-Fix V2 ausführen
```sql
-- Öffnen Sie Supabase SQL Editor und fügen Sie das komplette schema-fix-v2.sql ein
-- Dieses Script ist extrem robust und behandelt alle möglichen Schema-Varianten
```

👉 **[schema-fix-v2.sql herunterladen](./schema-fix-v2.sql)**

### Schritt 2: Schema-Fix ausführen
1. Öffnen Sie Ihr [Supabase Dashboard](https://supabase.com/dashboard)
2. Gehen Sie zu **SQL Editor**
3. Kopieren Sie den kompletten Inhalt von `schema-fix-v2.sql`
4. Klicken Sie auf **Run**

## 🔍 WAS DAS SCRIPT MACHT

### Automatische Schema-Erkennung
- Erkennt vorhandene Spalten automatisch
- Behandelt verschiedene Spaltennamen (`follower_count` vs `followers`)
- Fügt fehlende Spalten hinzu ohne Datenverlust

### Robuste Spalten-Behandlung
```sql
-- Beispiel: Automatische Spalten-Umbenennung
IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'influencers' AND column_name = 'followers') THEN
    ALTER TABLE influencers RENAME COLUMN followers TO follower_count;
END IF;
```

### Vollständige Feature-Unterstützung
- ✅ Kern-Spalten (name, handle, follower_count, status)
- ✅ Erweiterte Spalten (category_tags, bio, instagram_url)
- ✅ Indizes für Performance
- ✅ Trigger für automatische Timestamps
- ✅ Row Level Security (RLS)

## 🛠️ ALTERNATIVE LÖSUNGEN

### Option 1: Setup-Tool verwenden
1. Öffnen Sie `setup.html`
2. Klicken Sie auf **"Verbesserte Schema-Fix V2"**
3. Führen Sie das SQL in Supabase aus

### Option 2: Minimales Schema
Falls Sie nur grundlegende Features brauchen:
```sql
-- Minimal-Schema (nur Kern-Spalten)
CREATE TABLE IF NOT EXISTS influencers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    handle TEXT UNIQUE NOT NULL,
    follower_count INTEGER DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0.0,
    status TEXT DEFAULT 'new_lead',
    assigned_to TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Option 3: Dashboard-Code Anpassung
Das Dashboard ist jetzt **schema-aware** und erkennt automatisch:
- Verschiedene Spaltennamen (`follower_count` vs `followers`)
- Fehlende optionale Spalten
- Minimale vs. erweiterte Schemas

## 🔧 TROUBLESHOOTING

### Problem: "permission denied for table influencers"
```sql
-- RLS Policy hinzufügen
ALTER TABLE influencers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON influencers FOR ALL USING (auth.role() = 'authenticated');
```

### Problem: "relation influencers does not exist"
1. Tabelle existiert nicht → Führen Sie `enhanced-schema.sql` aus
2. Falsche Datenbank → Prüfen Sie Ihre Supabase URL

### Problem: Array-Spalten funktionieren nicht
```sql
-- PostgreSQL Arrays aktivieren
ALTER TABLE influencers ADD COLUMN IF NOT EXISTS category_tags TEXT[] DEFAULT '{}';
```

## 📊 SCHEMA-VALIDIERUNG

Nach dem Schema-Fix sollten diese Spalten vorhanden sein:

### Kern-Spalten (Minimum)
- `id` (BIGSERIAL PRIMARY KEY)
- `name` (TEXT NOT NULL)
- `handle` (TEXT UNIQUE NOT NULL)
- `follower_count` (INTEGER)
- `engagement_rate` (DECIMAL)
- `status` (TEXT)
- `created_at` (TIMESTAMP)

### Erweiterte Spalten (Vollfeature)
- `category_tags` (TEXT[])
- `bio` (TEXT)
- `instagram_url` (TEXT)
- `post_count` (INTEGER)
- `notes` (TEXT)
- `last_contact_date` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `assigned_to` (TEXT)

## 🎯 NACH DEM SCHEMA-FIX

1. **Dashboard neu laden** - Das Dashboard erkennt automatisch das neue Schema
2. **CSV-Import testen** - Alle Import-Funktionen funktionieren jetzt
3. **CRUD-Operationen testen** - Alle Datenbank-Operationen sollten funktionieren

## 🚨 HÄUFIGE FEHLER VERMEIDEN

### ❌ Falsch: Manuelle Spalten hinzufügen
```sql
ALTER TABLE influencers ADD COLUMN follower_count INTEGER;
-- Problem: Keine Fehlerbehandlung, keine Indizes
```

### ✅ Richtig: Schema-Fix V2 verwenden
```sql
-- Komplettes robustes Script mit Fehlerbehandlung
-- Automatische Schema-Erkennung
-- Performance-Indizes
-- RLS-Konfiguration
```

## 📞 SUPPORT

Falls Sie weiterhin Probleme haben:

1. **Setup-Tool**: Verwenden Sie `setup.html` → Schema-Diagnose
2. **Test-Tool**: Verwenden Sie `test-connection.html` 
3. **GitHub Issues**: [Repository Issues](https://github.com/DanielePL/prometheus-influencer-discovery/issues)

## 🎉 ERFOLGSSTATUS

Nach erfolgreichem Schema-Fix sollten Sie sehen:
- ✅ Dashboard lädt ohne Fehler
- ✅ Alle CRUD-Operationen funktionieren
- ✅ CSV-Import/Export funktioniert
- ✅ Real-time Updates funktionieren

**Das Dashboard ist jetzt produktionsbereit! 🚀**
