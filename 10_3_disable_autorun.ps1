# This scripts sets the registry keys to disable autorun and autoplay for removable media
# CIS Controls v8.1 - Safeguard 10.3


######################## Set up logging ###############################
Try {                                             ### Load config file
    . $PSScriptRoot\settings.ps1
}
Catch {
    Write-Output "==> Error! Missing settings.ps1 or invalid syntax"
    Exit
}
#Clear-Content $logfile  #<---- Uncomment to clear file every time, comment to concatenate
$DATE = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"
$logfile = "$log_path\$logname"
if (!(Test-Path $logfile)) {
    New-Item -ItemType File -Path $log_path -Name ($logname) | Out-Null
}
Write-Output ("=" * 80)  | Tee-Object $logfile -Append
Write-Output "==> $PSCommandPath" | Tee-Object $logfile -Append
Write-Output "==> $DATE" | Tee-Object $logfile -Append
######################################################################

$autorun_path  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$autoplay_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"

New-ItemProperty -Path $autorun_path  -Name "NoDriveAutoRun" -Value 0xFF -PropertyType DWord -Force
New-ItemProperty -Path $autoplay_path -Name "DisableAutoplay" -Value 1 -PropertyType DWord -Force

Write-Output "==> Autorun & Autoplay Disabled." | Tee-Object $logfile -Append
