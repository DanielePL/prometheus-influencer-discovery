# Prometheus Influencer Discovery - Supabase Setup Guide

Detaillierte Schritt-für-Schritt Anleitung zur Einrichtung der Supabase-Integration.

## 🎯 Übersicht

Diese Anleitung führt dich durch die komplette Einrichtung der Supabase-Backend-Integration für das Prometheus Influencer Discovery Dashboard.

## 📋 Voraussetzungen

- Supabase-Account (kostenlos unter [supabase.com](https://supabase.com))
- Grundkenntnisse in SQL
- Moderner Webbrowser

## 🚀 Schritt-für-Schritt Setup

### 1. Supabase-Projekt erstellen

1. **Registrieren/Anmelden** bei [supabase.com](https://supabase.com)
2. **Neues Projekt erstellen**:
   - Klicke auf "New Project"
   - Organisation auswählen (oder neue erstellen)
   - Projektname: `prometheus-influencer-discovery`
   - Passwort für Datenbank setzen (gut merken!)
   - Region auswählen (Europe West für DACH-Region empfohlen)
   - Klicke "Create new project"

3. **Auf Projektfertigstellung warten** (ca. 2-3 Minuten)

### 2. Projekt-Credentials notieren

Nach der Erstellung findest du in den **Project Settings** → **API**:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **Wichtig**: Diese Werte brauchst du später für die Dashboard-Konfiguration!

### 3. Datenbankschema einrichten

1. **SQL Editor öffnen**: Dashboard → SQL Editor
2. **Neues Query erstellen**: "New query" klicken
3. **Schema-SQL einfügen**: Inhalt von `supabase-schema.sql` kopieren und einfügen
4. **Ausführen**: "Run" klicken

✅ **Erwartetes Ergebnis**: 
- 6 Tabellen erstellt
- Indizes angelegt  
- RLS-Policies aktiviert
- Trigger-Funktionen erstellt

### 4. Beispieldaten einfügen

1. **Neues Query erstellen** im SQL Editor
2. **Sample-Data-SQL einfügen**: Inhalt von `sample-data.sql` kopieren
3. **Ausführen**: "Run" klicken

✅ **Erwartetes Ergebnis**:
- 13 Influencer-Datensätze
- 18 Aktivitäts-Einträge
- 4 Team-Mitglieder
- Diverse Notizen

### 5. Realtime aktivieren

1. **Database** → **Replication** im Supabase Dashboard
2. **Realtime aktivieren** für folgende Tabellen:
   - ☑️ `influencers`
   - ☑️ `activities`  
   - ☑️ `influencer_notes`
   - ☑️ `team_members`

### 6. Dashboard konfigurieren

In der Datei `index.html` diese Zeilen ersetzen:

```javascript
// Ersetze diese Placeholder:
const SUPABASE_URL = 'DEINE_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'DEIN_SUPABASE_ANON_KEY';

// Mit deinen echten Werten:
const SUPABASE_URL = 'https://xxxxxxxxxxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### 7. Testen der Integration

1. **Dashboard öffnen**: `index.html` im Browser
2. **Browser-Konsole prüfen**: F12 → Console
3. **Erwartete Meldungen**:
   ```
   Supabase client initialized successfully
   Data loaded from Supabase: {influencers: 13, activities: 18}
   ```

## 🔧 Troubleshooting

### Problem: "Supabase client initialization failed"
**Lösung**: 
- Prüfe SUPABASE_URL und SUPABASE_ANON_KEY
- Stelle sicher, dass keine Anführungszeichen fehlen

### Problem: "Error loading data from Supabase"
**Lösung**:
- Prüfe ob das Schema korrekt ausgeführt wurde
- Kontrolliere RLS-Policies in Supabase Dashboard

### Problem: "No real-time updates"
**Lösung**:
- Realtime für Tabellen aktivieren (siehe Schritt 5)
- Browser-Cache leeren und neu laden

### Problem: "Table XYZ does not exist"
**Lösung**:
- Schema-SQL komplett erneut ausführen
- Prüfe auf SQL-Syntaxfehler im Editor

## 📊 Datenbank-Übersicht

### Tabellen-Struktur:

```
influencers/
├── id (UUID, Primary Key)
├── handle (Text, Unique)
├── name (Text)
├── status (new|contacted|negotiating|partner)
├── followers (Integer)
├── engagement_rate (Numeric)
├── categories (Text Array)
└── ...weitere Felder

activities/
├── id (UUID, Primary Key)  
├── type (Text)
├── content (Text)
├── value (Text)
└── created_at (Timestamp)

team_members/
├── id (UUID, Primary Key)
├── name (Text)
├── email (Text, Unique)
└── role (Text)
```

### Automatische Features:
- 📝 **Auto-Timestamps**: `created_at`, `updated_at`
- 🔄 **Status-Change-Tracking**: Automatische Activity bei Status-Änderung
- 🔍 **Performance-Indizes**: Optimierte Suche und Filter
- 🔒 **Row Level Security**: Grundlegende Sicherheit aktiviert

## 🌐 Deployment-Optionen

### GitHub Pages:
1. Repository auf GitHub pushen
2. Settings → Pages → Source: "Deploy from branch"
3. Branch: `main`, Folder: `/ (root)`
4. **Umgebungsvariablen**: Direkt in `index.html` eintragen

### Vercel:
1. GitHub-Repository verknüpfen
2. Environment Variables setzen:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

### Netlify:
1. Drag & Drop Deployment oder Git-Integration
2. Environment Variables in Site Settings setzen

## 🔐 Sicherheits-Hinweise

### Für Demo/Test:
- ✅ Aktuelle RLS-Policies erlauben alle Operationen
- ✅ Anon Key ist sicher für Client-Side-Nutzung

### Für Produktion:
- 🔄 RLS-Policies anpassen (User-basierte Zugriffskontrollen)
- 🔄 Authentication hinzufügen
- 🔄 API-Rate-Limiting konfigurieren

## 📞 Support

Bei Problemen:

1. **Supabase-Logs prüfen**: Dashboard → Logs
2. **Browser-Konsole checken**: F12 → Console
3. **SQL-Editor nutzen**: Manuelle Queries zum Debugging
4. **Community**: [Supabase Discord](https://discord.supabase.com/)

---

**Status nach Setup**: 🚀 **Production-Ready** mit Live-Datenbank!
