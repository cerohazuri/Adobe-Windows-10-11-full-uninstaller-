Erklärung des PowerShell-Skripts

Das Skript ist ein komplettes Bereinigungs- und Deinstallations-Tool für Adobe Creative Cloud und alle Adobe-Programme.
Es führt folgende Aufgaben durch:

✅ 1. Adobe-Prozesse zwangsbeenden (Stop-AdobeProcessesForce)

Das Skript stoppt alle Adobe- und Creative-Cloud-Prozesse, z. B.:

Adobe Desktop Service

AdobeIPCBroker

AdobeGCClient

CoreSync

Photoshop

Illustrator

Premiere

After Effects

Media Encoder

InDesign usw.

→ Dadurch werden Dateisperren gelöst, und man kann alle Ordner löschen.

🧽 2. Adobe-Dienste beenden und deaktivieren

Das Skript sucht nach Windows-Diensten, die mit Adobe zu tun haben (z. B. AGSService),
und stoppt sie bzw. deaktiviert sie.

🗑 3. Adobe-Ordner auf dem System löschen

Es werden alle relevanten Adobe-Ordner entfernt, z. B.:

C:\Program Files\Adobe

C:\Program Files (x86)\Adobe

C:\ProgramData\Adobe

C:\Users\<Benutzer>\AppData\Roaming\Adobe

...\Local\Adobe

Creative Cloud Caches

→ Vollständige Entfernung lokaler Dateien, Einstellungen und Caches.

🔄 4. Registry-Einträge entfernen

Es löscht Adobe-bezogene Registry-Keys unter:

HKLM:\SOFTWARE\Adobe

HKCU:\Software\Adobe

teilweise noch Installationsreste von Creative Cloud

→ Entfernt Installationsreste komplett aus Windows.

🧼 5. Startup-Einträge deaktivieren

Es entfernt Adobe-Programme aus:

Autostart

Run / RunOnce Registry-Schlüsseln

geplanten Aufgaben

→ Dadurch startet niemals wieder ein Adobe-Dienst im Hintergrund.

🚿 6. DirectX-Cache, Temp-Ordner und Prüfdaten entfernen

Das Skript putzt zusätzlich:

Windows Temp

Benutzer Temp

DirectX Shader Cache

Download- und Installationsreste von Adobe

CoreSync-Datenbank

⚙️ 7. Interaktive Abfrage am Ende

Am Ende fragt das Skript:

Sofort starten? (j/N)


→ Bei j startet der komplette Cleanup
→ Bei N zeigt es nur die Informationen an

🚀 8. „Invoke-Now“ – Schnellstartfunktion

Du kannst direkt auf der Konsole eingeben:

Invoke-Now


→ Führt die komplette Bereinigung sofort aus.

🎯 Kurzversion – Was macht das Script?

Es deinstalliert Adobe Creative Cloud vollständig, inklusive:

✔ Programme
✔ Dienste
✔ Hintergrundprozesse
✔ Caches
✔ Registry
✔ Autostart
✔ Systemordner
✔ Benutzerordner

→ Danach ist Windows so, als ob nie Adobe installiert war.

🛠️ ZUSÄTZLICHE SOFORT-LÖSUNGEN
Lösung 1: Safe Mode Löschung
powershell
# 1. PC im Abgesicherten Modus starten
# 2. PowerShell als Admin öffnen
# 3. Dies ausführen:
& {
    takeown /f "C:\Program Files (x86)\Common Files\Adobe" /r /d y
    icacls "C:\Program Files (x86)\Common Files\Adobe" /grant administrators:F /t
    Remove-Item "C:\Program Files (x86)\Common Files\Adobe" -Recurse -Force
}
Lösung 2: Einzelne Datei manuell löschen
powershell
# Für die spezifische DLL:
$file = "C:\Program Files (x86)\Common Files\Adobe\CoreSync_x64.dll"
takeown /f "$file"
icacls "$file" /grant "%username%:F"
del /f "$file"
Lösung 3: Batch-Skript für hartnäckige Dateien
batch
@echo off
echo Adobe Force Delete Tool
takeown /f "C:\Program Files (x86)\Common Files\Adobe" /r /d y
timeout /t 2
icacls "C:\Program Files (x86)\Common Files\Adobe" /grant administrators:F /t
timeout /t 2
rmdir /s /q "C:\Program Files (x86)\Common Files\Adobe"
echo Fertig!
pause
🎯 EMPFOHLENE VORGEWENSWEISE
Für deinen spezifischen Fehler:

Erweiterte Version ausführen:

powershell
.\AdobeCleanupAdvanced.ps1
Falls immer noch Fehler:

🔄 Computer neustarten

🔄 Skript erneut ausführen

Als letzte Lösung:

🛡️ Abgesicherten Modus verwenden

🛡️ Offiziellen Adobe Cleaner Tool nutzen
