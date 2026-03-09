# README – `server_access_fix.ps1`

## Purpose
`server_access_fix.ps1` modifies local Windows policy and registry settings to restore access to certain legacy or insecurely configured SMB servers/shares.

> ⚠️ **Warning:** This script lowers security settings. Use only in controlled environments and only as long as required.

## What the script changes
1. Verifies the script is running with Administrator rights.
2. Sets printer policy registry value:
   - `HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers`
   - `ForceCSREMFDespooling = 0` (DWORD)
3. Enables insecure guest auth for SMB client:
   - `HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation`
   - `AllowInsecureGuestAuth = 1` (DWORD)
4. Exports and reapplies local security policy via `secedit`, including:
   - `EnableSecuritySignature=0`
5. Runs `gpupdate /force`.
6. Prompts for a restart.

## Requirements
- Windows with PowerShell
- Local Administrator permissions
- `secedit` and `gpupdate` available (default on Windows)

## Run
Open PowerShell **as Administrator** and execute:

```powershell
.\server_access_fix.ps1
```

If execution policy blocks scripts, allow for current session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\server_access_fix.ps1
```

## Expected output
- Start message for configuration changes
- Confirmation of registry updates
- Confirmation of local security policy update
- Confirmation of `gpupdate`
- Restart notice

## Security impact
This script reduces SMB-related security:
- Enables insecure guest authentication (`AllowInsecureGuestAuth=1`)
- Disables required SMB signing (`EnableSecuritySignature=0`)

This increases risk of unauthorized access and man-in-the-middle attacks on untrusted networks.

## Revert (recommended after troubleshooting)
Set values back to secure defaults:

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -Value 0 -Type DWord
```

Then run:

```powershell
gpupdate /force
Restart-Computer
```
