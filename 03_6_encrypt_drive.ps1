# This scripts enables BitLocker Encryption for the sytem drive $
# CIS Controls v8.1 - Safeguard 10.3


######################## Set up logging ###############################
Try {                                             ### Load config file
    . $PSScriptRoot\settings.ps1
}
Catch {
    Write-Output "==> Error! Missing settings.ps1 or invalid syntax" | Tee-Object $logfile -Append
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

# Get BitLocker status
$bitlocker = Get-BitLockerVolume -MountPoint $system_drive

if ($bitlocker.ProtectionStatus -eq 0) {
    Write-Output "Drive $system_drive is not encrypted. Starting BitLocker encryption using TPM." | Tee-Object $logfile -Append

    # Enable BitLocker as a background job. (Will continue if shell window is terminated.
    Start-Job -Name bitlocker_job -ScriptBlock {
        Enable-BitLocker -MountPoint $system_drive -TpmProtector -EncryptionMethod XtsAes256 -UsedSpaceOnly 
    }
    Write-Output "Encryption Job for drive $system_drive started with job name 'bitlocker_job' " | Tee-Object $logfile -Append
} else {
    Write-Output "Drive $system_drive is already encrypted using BitLocker." | Tee-Object $logfile -Append
}
