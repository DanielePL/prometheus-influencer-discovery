# 🔧 Supabase Debug & Setup Guide

## 🚨 AKTUELLE SITUATION
Das Dashboard verwendet momentan Demo-Daten, weil die Supabase-Verbindung fehlschlägt.

## 🔍 DEBUGGING SCHRITTE

### 1. **Überprüfen Sie die Browser-Konsole**
Öffnen Sie die Entwicklertools (F12) und schauen Sie in die Konsole. Sie sollten folgende Debug-Meldungen sehen:

```
🔍 DEBUGGING SUPABASE CONNECTION...
Supabase URL: YOUR_SUPABASE_URL_HERE
Supabase Key (masked): NOT SET
❌ SUPABASE_URL not configured!
```

### 2. **Setzen Sie die Supabase-Credentials**

#### Option A: Im Browser (für Tests)
Öffnen Sie die Browser-Konsole und setzen Sie die Variablen:

```javascript
// Setzen Sie Ihre echten Supabase-Credentials
window.SUPABASE_URL = 'https://ihreprojektid.supabase.co';
window.SUPABASE_ANON_KEY = 'Ihr_Anon_Key_hier';

// Dann laden Sie die Seite neu
location.reload();
```

#### Option B: Direkt im Code (für Development)
Ersetzen Sie in `index.html` (Zeile ~641):

```javascript
// VON:
const SUPABASE_URL = window.SUPABASE_URL || 'YOUR_SUPABASE_URL_HERE';
const SUPABASE_ANON_KEY = window.SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY_HERE';

// ZU:
const SUPABASE_URL = window.SUPABASE_URL || 'https://ihreprojektid.supabase.co';
const SUPABASE_ANON_KEY = window.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Ihr Anon Key
```

### 3. **Testen Sie die Verbindung**

1. **Öffnen Sie das Dashboard** (http://localhost:8080)
2. **Klicken Sie den "🔍 Debug Supabase" Button** 
3. **Schauen Sie in die Browser-Konsole** für detaillierte Debug-Informationen

### 4. **Verwenden Sie das Test-Tool**

Öffnen Sie `test-connection.html` (http://localhost:8080/test-connection.html):

1. Geben Sie Ihre Supabase URL und Anon Key ein
2. Klicken Sie "Test Connection"
3. Führen Sie alle Tests durch

## 🔧 HÄUFIGE PROBLEME

### Problem: "Schema test failed"
**Lösung**: Führen Sie die SQL-Schemas aus:
1. Öffnen Sie Supabase Dashboard → SQL Editor
2. Führen Sie `supabase-schema.sql` aus
3. Führen Sie `sample-data.sql` aus

### Problem: "RLS policy prevents access"
**Lösung**: Deaktivieren Sie RLS für Tests:
```sql
ALTER TABLE influencers DISABLE ROW LEVEL SECURITY;
ALTER TABLE activities DISABLE ROW LEVEL SECURITY;
```

### Problem: "Invalid JWT"
**Lösung**: Überprüfen Sie Ihren Anon Key:
1. Supabase Dashboard → Settings → API
2. Kopieren Sie den "anon public" Key
3. NICHT den "service_role" Key verwenden!

## 📊 ERWARTETE DEBUG-AUSGABE (bei korrekter Konfiguration)

```
🔍 DEBUGGING SUPABASE CONNECTION...
Supabase URL: https://ihreprojektid.supabase.co
Supabase Key (masked): eyJhbGciOiJIUzI1NiIsIn...
Supabase Client: INITIALIZED
🔍 Testing basic connection...
✅ Supabase Connected Successfully!
Sample data: [{"id": 1, "name": "Test User", ...}]
```

## 🚀 NÄCHSTE SCHRITTE

Nach erfolgreicher Verbindung sollten Sie sehen:
- ✅ Live-Daten in der Influencer-Tabelle
- ✅ Echte Statistiken im Dashboard
- ✅ Funktionierende Such- und Filteroptionen
- ✅ Real-time Updates

## ⚡ SCHNELL-TEST

1. Öffnen Sie Browser-Konsole
2. Führen Sie aus:
```javascript
debugSupabaseConnection()
```
3. Schauen Sie auf die Ausgabe

Wenn Sie weiterhin Probleme haben, teilen Sie die komplette Konsolen-Ausgabe mit!
