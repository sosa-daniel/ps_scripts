# This script creates registry keys to manage Google Chrome,
# MS Edge, and Mozilla Firefox using local GPO settings

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

$edge_path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\"
$chrome_path = "HKLM:\SOFTWARE\Policies\Google\Chrome\"
$firefox_path = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS"
$path_list =  @($edge_path, $chrome_path)

# Handle Chrome and Edge together
foreach ($key_path in $path_list) {
	if (-not (Test-Path -Path $key_path -PathType Container)) {
        Write-Output "key '$key_path' does not exist. Creating" | Tee-Object $logfile -Append
		New-Item -Path $key_path -Force
	} else {
        Write-Output "key '$key_path' already exists." | Tee-Object $logfile -Append
	}
    ###### DNS over HTTPS
    New-ItemProperty -Path $key_path -Name "BuiltInDnsClientEnabled" -Value 1 -PropertyType DWord -Force
    # DnsOverHttpsMode: 'automatic' will send DoH queries first and may fallback to sending insecure queries on error.
    # 'secure' mode will only send DoH queries and will fail to resolve on error.
    New-ItemProperty -Path $key_path -Name "DnsOverHttpsMode" -Value "automatic" -PropertyType String -Force
    New-ItemProperty -Path $key_path -Name "DnsOverHttpsTemplates" -Value $doh_address -PropertyType String -Force
    ##### Basic hardening
    New-ItemProperty -Path $key_path -Name "DiskCacheSize" -Value 250609664 -PropertyType DWord -Force
    # block malicious downloads
    New-ItemProperty -Path $key_path -Name "DownloadRestrictions" -Value 4 -PropertyType DWord -Force
    # automatic updates
    New-ItemProperty -Path $key_path -Name "RelaunchNotification" -Value 2 -PropertyType DWord -Force
    New-ItemProperty -Path $key_path -Name "RelaunchNotificationPeriod" -Value 86400000 -PropertyType DWord -Force
    # preserve history
    New-ItemProperty -Path $key_path -Name "SavingBrowserHistoryDisabled" -Value 0 -PropertyType DWord -Force
    New-ItemProperty -Path $key_path -Name "BrowserGuestModeEnabled" -Value 0 -PropertyType DWord -Force
    New-ItemProperty -Path $key_path -Name "AllowDeletingBrowserHistory" -Value 0 -PropertyType DWord -Force
    if ($key_path.Contains("Edge")) {
    New-ItemProperty -Path $key_path -Name "InPrivateModeAvailability" -Value 1 -PropertyType DWord -Force
    } else {
    New-ItemProperty -Path $key_path -Name "IncognitoModeAvailability" -Value 1 -PropertyType DWord -Force
    }
    # Manage Extensions (uncomment allowlist/forcelist if needed)
    New-ItemProperty -Path $key_path -Name "BlockExternalExtensions" -Value 1 -PropertyType DWord -Force
    New-ItemProperty -Path $key_path -Name "ExtensionInstallBlocklist" -Value $extension_blocklist -PropertyType MultiString -Force
    #New-ItemProperty -Path $key_path -Name "ExtensionInstallAllowlist" -Value $extension_allowlist -PropertyType MultiString -Force
    #New-ItemProperty -Path $key_path -Name "ExtensionInstallForcelist" -Value $extension_forcelist -PropertyType MultiString -Force
}

# Handle Firefox Separately
if (-not (Test-Path -Path $firefox_path -PathType Container)) {
    Write-Output "key '$firefox_path does not exist. Creating" | Tee-Object $logfile -Append
    New-Item -Path $firefox_path -Force
} else {
    Write-Output "key '$firefox_path already exists." | Tee-Object $logfile -Append
    }
New-ItemProperty -Path $firefox_path -Name "Enabled" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $firefox_path -Name "ProviderURL" -Value $doh_address -PropertyType String -Force
# 'Locked' prevents the user from changing DoH preferences
New-ItemProperty -Path $firefox_path -Name "Locked" -Value 1 -PropertyType DWord -Force
# 'Fallback' determines whether or not Firefox will use your default DNS resolver if there is a problem with DoH
# to disable fallback change value to 0
New-ItemProperty -Path $firefox_path -Name "Fallback" -Value 1 -PropertyType DWord -Force

Write-Output "Configured DoH address $doh_address" | Tee-Object $logfile -Append

