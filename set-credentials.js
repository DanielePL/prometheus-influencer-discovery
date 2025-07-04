// ✅ SUPABASE CREDENTIALS ERFOLGREICH KONFIGURIERT!
// Diese Credentials sind jetzt im Dashboard aktiv.

// 1. IHRE SUPABASE URL
window.SUPABASE_URL = 'https://vzmmdhyrbgfakagzehtx.supabase.co';

// 2. IHRE SUPABASE ANON KEY
window.SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJiss3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6bW1kaHlyYmdmYWthZ3plaHR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1NTkzMTYsImV4cCI6MjA2NzEzNTMxNn0.FgYggzoIsHTuQTKbVpvWni-BXp6IdgI1UAvwm2tzU9A';

// 3. SPEICHERE IN LOCALSTORAGE FÜR PERSISTENZ
localStorage.setItem('SUPABASE_URL', window.SUPABASE_URL);
localStorage.setItem('SUPABASE_ANON_KEY', window.SUPABASE_ANON_KEY);

console.log('✅ Supabase Credentials erfolgreich gesetzt!');
console.log('🔄 Dashboard wird neu geladen...');

// 4. SEITE NEU LADEN
setTimeout(() => {
    location.reload();
}, 1000);
