```
# Skript startet mit Administratorrechten
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Bitte starten Sie dieses Skript als Administrator!" -ForegroundColor Red
    Pause
    Exit
}  

Write-Host "Starte Konfigurationsbearbeitung..." -ForegroundColor Cyan

# Setzt den Wert für ForceCSREMFDespooling in der Registry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" -Name "ForceCSREMFDespooling" -Value 0 -Type DWord -Force
Write-Host "Registry-Eintrag ForceCSREMFDespooling gesetzt." -ForegroundColor Green

# Setzt den Wert für AllowInsecureGuestAuth in der Registry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -Value 1 -Type DWord -Force
Write-Host "Registry-Eintrag AllowInsecureGuestAuth gesetzt." -ForegroundColor Green

# Steuern des SMB-Signaturverhaltens
$tempSecPol = "$env:TEMP\secpol.cfg"
secedit /export /cfg $tempSecPol

Add-Content -Path $tempSecPol -Value "[System Access]"
Add-Content -Path $tempSecPol -Value "[Event Audit]"
Add-Content -Path $tempSecPol -Value "[Registry Values]"
Add-Content -Path $tempSecPol -Value "[Privilege Rights]"
Add-Content -Path $tempSecPol -Value "[Version]"
Add-Content -Path $tempSecPol -Value 'signature="$SYSTEM$"'
Add-Content -Path $tempSecPol -Value "Revision=1"
Add-Content -Path $tempSecPol -Value "[System Access]"
Add-Content -Path $tempSecPol -Value "[Kerberos Policy]"
Add-Content -Path $tempSecPol -Value "[Audit Policy]"
Add-Content -Path $tempSecPol -Value "[Registry Values]"
Add-Content -Path $tempSecPol -Value "[Privilege Rights]"
Add-Content -Path $tempSecPol -Value "[System Logon]"
Add-Content -Path $tempSecPol -Value "[Security Options]"
Add-Content -Path $tempSecPol -Value "EnableSecuritySignature=0"

secedit /configure /db "$env:windir\security\local.sdb" /cfg $tempSecPol /areas SECURITYPOLICY
Write-Host "Sicherheitsrichtlinie aktualisiert." -ForegroundColor Green

# Gruppenrichtlinien aktualisieren
gpupdate /force
Write-Host "Gruppenrichtlinien wurden aktualisiert." -ForegroundColor Green


Write-Host "Bearbeitung abgeschlossen. Bitte starten Sie den Computer neu, um alle Einstellungen zu übernehmen." -ForegroundColor Yellow

Pause
Exit
```
