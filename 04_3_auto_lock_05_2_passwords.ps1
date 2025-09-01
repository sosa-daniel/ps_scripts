# This scripts checks that passwords are required and that there is automatic session locking
# CIS Controls v8.1 - Safeguard 4.3: Configure Automatic Session Locking on Enterprise Assets
# CIS Controls v8.1 - Safeguard 5.2: Use Unique Passwords

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

# Check if domain joined
if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain) {
    Write-Output "This system is domain-joined. Set policy through AD controller" | Tee-Object $logfile -Append
    Exit
}

# Require password at logon (disable autologon)
$winlogon = Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Winlogon'
if ($winlogon) {
    Write-Output "Disabling Auto Logon" | Tee-Object $logfile -Append
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Winlogon' -Name "AutoAdminLogon" -Value 0 -Force
} else {
    Write-Output "Auto Logon is not enabled." | Tee-Object $logfile -Append
}


# Configure screensaver settings for every user profile
$user_profiles = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -ne $null }
foreach ($profile in $user_profiles) {
    $sid = $profile.SID
    if ($profile.Special) {
        Write-Output "Skipping special profile. SID:$sid" | Tee-Object $logfile -Append
        continue
    }
    $scr_key_path = "registry::HKEY_USERS\$sid\Control Panel\Desktop"
    # check if path exists. They may be leftover SIDs for deleted users
    if (Test-Path $scr_key_path) {
        Write-Output "Configuring screensaver for SID:$sid" | Tee-Object $logfile -Append
        # set the screensaver file (check settings.ps1)
        Set-ItemProperty -Path $scr_key_path -Name "SCRNSAVE.EXE" -Value $scr_path -Force
        # activate screensaver
        Set-ItemProperty -Path $scr_key_path -Name "ScreenSaveActive" -Value 1 -Force 
        # set the screensaver timeout (check settings.ps1)
        Set-ItemProperty -Path $scr_key_path -Name "ScreenSaveTimeOut" -Value $scr_timeout -Force
        # ask for password on screensaver resume
        Set-ItemProperty -Path $scr_key_path -Name "ScreenSaverIsSecure" -Value 1 -Force
    }
}
# set the InactivityTimeoutSecs system property to match ScreenSaveTimout value
$sys_reg_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $sys_reg_path -Name "InactivityTimeoutSecs" -Value $scr_timeout -Force

# set current power scheme inactivity timer while plugged in and on battery
powercfg /CHANGE monitor-timeout-ac $scr_timeout
powercfg /CHANGE monitor-timeout-dc $scr_timeout

# Set local password policy:
$current_policy = NET ACCOUNTS
Write-Output "Previous local password policy:" | Tee-Object $logfile -Append
Write-Output "$current_policy" | Tee-Object $logfile -Append

NET ACCOUNTS /MINPWLEN:$min_pass_len /MAXPWAGE:$max_pass_age /UNIQUEPW:24
Write-Output "Passwords must be at least $min_pass_len characters and will must change every $max_pass_age days." | Tee-Object $logfile -Append
Write-Output "NOTE: Local password policy (non-domain) in Windows is not very transparent. Consider using Active Directory instead. " | Tee-Object $logfile -Append
