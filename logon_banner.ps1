# This script displays a warning message before logon
# CIS Controls: N/A but included in CIS windows benchmark 


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

$sys_reg_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$old_title = Get-ItemPropertyValue -Path $sys_reg_path -Name LegalNoticeCaption
$old_text = Get-ItemPropertyValue -Path $sys_reg_path -Name LegalNoticeText
Write-Output "Current banner title: $old_title" | Tee-Object $logfile -Append
Write-Output "Current banner text: $old_text" | Tee-Object $logfile -Append
Set-ItemProperty -Path $sys_reg_path -Name LegalNoticeCaption -Value $banner_title
Set-ItemProperty -Path $sys_reg_path -Name LegalNoticeText -Value $banner_text
Write-Output "Logon banner configured as follows:" | Tee-Object $logfile -Append
Write-Output "Banner Title: $banner_title" | Tee-Object $logfile -Append
Write-Output "Banner Text: $banner_text" | Tee-Object $logfile -Append

