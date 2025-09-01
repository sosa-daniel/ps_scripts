# This scripts enables system restore (idempotent) and creates a restore point.

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

Try {                                             ### Load config file
    Install-PackageProvider NuGet -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module -Name Microsoft.PowerApps.Administration.Powershell -Repository PSGallery
    Import-Module Microsoft.PowerShell.Management
    Enable-ComputerRestore -Drive $system_drive
    Checkpoint-Computer -Description $sr_description -RestorePointType $sr_type 
}
Catch {
    Write-Output "==> Error. Exception while creating System Restore" | Tee-Object $logfile -Append
    Exit
}

Write-Output "==> System Restore is enabled and a new Restore Point has been created." | Tee-Object $logfile -Append
Write-Output "==> Drive: $system_drive" | Tee-Object $logfile -Append
Write-Output "==> Description: $sr_description" | Tee-Object $logfile -Append
Write-Output "==> Restore Point Type = $sr_type" | Tee-Object $logfile -Append

