<#
.SYNOPSIS
    Erweitertes Adobe & Creative Cloud Cleanup Tool
.DESCRIPTION
    Beendet zuerst alle Prozesse und umgeht Dateisperren
#>

function Stop-AdobeProcessesForce {
    Write-Host "`n[!] Beende alle Adobe-Prozesse..." -ForegroundColor Red
    
    $adobeProcesses = @(
        "Adobe*", "Creative*", "CCX*", "CCLibrary*", "CoreSync*",
        "Adobe Desktop Service", "AdobeIPCBroker", "AdobeGCClient",
        "Acrobat*", "Photoshop*", "Illustrator*", "Premier*", "AfterEffects*",
        "MediaEncoder*", "Lightroom*", "InDesign*", "Dreamweaver*"
    )
    
    foreach ($pattern in $adobeProcesses) {
        try {
            $processes = Get-Process -Name $pattern -ErrorAction SilentlyContinue
            foreach ($process in $processes) {
                Write-Host "  ⚡ Beende: $($process.ProcessName) (PID: $($process.Id))" -ForegroundColor Yellow
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Continue on errors
        }
    }
    
    # Warte kurz damit Prozesse komplett beendet werden
    Start-Sleep -Seconds 3
}

function Remove-LockedFiles {
    param([string]$Path)
    
    try {
        # Versuche normale Löschung
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Host "  🔄 Versuche erweiterte Löschmethode für: $Path" -ForegroundColor Yellow
        
        try {
            # Methode 1: Take Ownership und setze Berechtigungen
            Take-Ownership -Path $Path
            Set-FullPermissions -Path $Path
            
            # Methode 2: Erneuter Löschversuch
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            return $true
            
        } catch {
            # Methode 3: Verwende cmd.exe del für einzelne Dateien
            try {
                Get-ChildItem $Path -Recurse -File | ForEach-Object {
                    try {
                        cmd.exe /c "del /f /q `"$($_.FullName)`" 2>nul"
                    } catch {
                        # Ignoriere Fehler bei einzelnen Dateien
                    }
                }
                
                # Versuche Ordner zu löschen
                Get-ChildItem $Path -Recurse -Directory | Sort-Object -Property FullName -Descending | ForEach-Object {
                    try {
                        cmd.exe /c "rmdir /s /q `"$($_.FullName)`" 2>nul"
                    } catch {
                        # Ignoriere Fehler bei einzelnen Ordnern
                    }
                }
                
                # Versuche Hauptordner
                cmd.exe /c "rmdir /s /q `"$Path`" 2>nul"
                return $true
                
            } catch {
                return $false
            }
        }
    }
}

function Take-Ownership {
    param([string]$Path)
    
    try {
        # Take Ownership mit takeown.exe
        $takeownArgs = @("/f", "`"$Path`"", "/r", "/d", "y")
        Start-Process "takeown" -ArgumentList $takeownArgs -Wait -WindowStyle Hidden
        
        # Für Unterordner
        Get-ChildItem $Path -Recurse | ForEach-Object {
            try {
                $itemArgs = @("/f", "`"$($_.FullName)`"", "/d", "y")
                Start-Process "takeown" -ArgumentList $itemArgs -Wait -WindowStyle Hidden
            } catch {
                # Continue on errors
            }
        }
        return $true
    } catch {
        return $false
    }
}

function Set-FullPermissions {
    param([string]$Path)
    
    try {
        # Setze volle Berechtigungen mit icacls
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $icaclsArgs = @("`"$Path`"", "/grant", "$user`:F", "/t", "/c", "/q")
        Start-Process "icacls" -ArgumentList $icaclsArgs -Wait -WindowStyle Hidden
        return $true
    } catch {
        return $false
    }
}

function Stop-AdobeServices {
    Write-Host "`n[!] Beende Adobe-Dienste..." -ForegroundColor Red
    
    $services = Get-Service | Where-Object { 
        $_.Name -like "*Adobe*" -or 
        $_.DisplayName -like "*Adobe*" -or
        $_.Name -like "*Creative*" -or
        $_.DisplayName -like "*Creative*"
    }
    
    foreach ($service in $services) {
        try {
            Write-Host "  ⚡ Beende Dienst: $($service.DisplayName)" -ForegroundColor Yellow
            Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service.Name -StartupType Disabled -ErrorAction SilentlyContinue
        } catch {
            # Continue on errors
        }
    }
}

# Erweiterte Löschfunktion
function Remove-AdobeItemsAdvanced {
    param([array]$ItemsToDelete)
    
    $successCount = 0
    $errorCount = 0
    $retryItems = @()
    
    # Erster Durchgang: Normales Löschen
    foreach ($item in $ItemsToDelete) {
        if ($item.Type -eq "Folder") {
            $result = Remove-LockedFiles -Path $item.Path
            if ($result) {
                Write-Host "  ✅ Gelöscht: $($item.Path)" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ❌ Fehler: $($item.Path)" -ForegroundColor Red
                $retryItems += $item
                $errorCount++
            }
        }
    }
    
    # Zweiter Durchgang: Nach Neustart empfohlen
    if ($retryItems.Count -gt 0) {
        Write-Host "`n[!] Einige Dateien sind immer noch gesperrt:" -ForegroundColor Red
        foreach ($item in $retryItems) {
            Write-Host "  🔒 Gesperrt: $($item.Path)" -ForegroundColor Yellow
        }
        
        Write-Host "`n💡 LÖSUNG:" -ForegroundColor Cyan
        Write-Host "1. Starten Sie Ihren Computer neu" -ForegroundColor White
        Write-Host "2. Führen Sie dieses Skript ERNEUT aus" -ForegroundColor White
        Write-Host "3. Oder verwenden Sie den offiziellen Adobe Cleaner Tool" -ForegroundColor White
    }
    
    return @{ Success = $successCount; Error = $errorCount; Retry = $retryItems.Count }
}

# Hauptfunktion mit erweitertem Cleanup
function Start-AdvancedCleanup {
    Write-Host "🚀 STARTE ERWEITERTES ADOBE CLEANUP..." -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    # 1. Prozesse beenden
    Stop-AdobeProcessesForce
    
    # 2. Dienste beenden
    Stop-AdobeServices
    
    # 3. Kurze Pause
    Start-Sleep -Seconds 2
    
    # 4. Gefundene Ordner löschen (aus vorherigem Skript)
    $folders = Find-AdobeFolders
    
    if ($folders.Count -gt 0) {
        Write-Host "`n🗑️  Lösche $($folders.Count) Adobe-Ordner..." -ForegroundColor Red
        $results = Remove-AdobeItemsAdvanced -ItemsToDelete $folders
        
        Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
        Write-Host "ERGEBNIS:" -ForegroundColor Yellow
        Write-Host "✅ Erfolgreich gelöscht: $($results.Success)" -ForegroundColor Green
        Write-Host "❌ Fehler: $($results.Error)" -ForegroundColor Red
        Write-Host "🔄 Noch gesperrt: $($results.Retry)" -ForegroundColor Yellow
        Write-Host "=" * 60 -ForegroundColor Cyan
    }
    
    # Zusätzliche Tools empfehlen
    Show-AdditionalTools
}

function Show-AdditionalTools {
    Write-Host "`n🔧 ZUSÄTZLICHE LÖSCHTOOLS:" -ForegroundColor Cyan
    
    Write-Host "`n1. OFFIZIELLER ADOBE CLEANER TOOL:" -ForegroundColor Yellow
    Write-Host "   Download: https://helpx.adobe.com/de/download-install/kb/creative-cloud-cleaner-tool.html" -ForegroundColor White
    Write-Host "   (Am effektivsten für restliche Komponenten)" -ForegroundColor Gray
    
    Write-Host "`n2. WINDOWS SAFE MODE LÖSCHUNG:" -ForegroundColor Yellow
    Write-Host "   - PC im Abgesicherten Modus starten (F8 beim Boot)" -ForegroundColor White
    Write-Host "   - Skript erneut ausführen" -ForegroundColor White
    
    Write-Host "`n3. MANUELLE LÖSCHUNG:" -ForegroundColor Yellow
    Write-Host "   - Unlocker Tool verwenden (https://github.com/Lockhunter/)" -ForegroundColor White
    Write-Host "   - Process Explorer zum Finden gesperrter Dateien" -ForegroundColor White
}

# Kurzbefehl für sofortige Ausführung
function Invoke-Now {
    Start-AdvancedCleanup
}

# Usage
Write-Host "Adobe Advanced Cleanup Tool" -ForegroundColor Cyan
Write-Host "Verwendung: .\Skript.ps1" -ForegroundColor White
Write-Host "Oder: Invoke-Now" -ForegroundColor White

# Automatisch starten wenn gewünscht
$autoStart = Read-Host "`nSofort starten? (j/N)"
if ($autoStart -eq 'j') {
    Start-AdvancedCleanup
}
