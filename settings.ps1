# This is a configuration file to provide inputs to a suite of scripts in a centralized location

$log_path = "$env:TEMP"
$logname = "endpoint_hardening.log"

# 03_6_encrypt_drive.ps1
$system_drive = "C:\" 


# 04_3_auto_lock_05_2_passwords.ps1
$scr_path = "C:\windows\system32\scrnsave.scr"
$scr_timeout = "600" # Timeout in seconds. e.g. 300 = 5m; 600 = 10m; 900 = 15m
$max_pass_age = 180
$min_pass_len = 12


# 09_2_dns_filtering.ps1:
# Uncomment one of the following
 $dns_servers = @("9.9.9.9", "149.112.112.112", "2620:fe::fe", "2620:fe::9") #Quad9 Servers
# $dns_servers = @("1.1.1.2", "1.0.0.2", "2606:4700:4700::1112", "2606:4700:4700::1002") # Cloudflare Malware
# $dns_servers = @("193.110.81.9", "185.253.5.9", "2a0f:fc80::9", "2a0f:fc81::9") # dns0.eu/zero Servers
# $dns_servers = @("193.110.81.0", "185.253.5.0", "2a0f:fc80::", "2a0f:fc81::") # dns0.eu Servers (zero above is hardened)
# $dns_servers = @("193.110.81.1", "185.253.5.1", "2a0f:fc80::1", "2a0f:fc81::1") # dns0.eu/kids Servers
# $dns_servers = @("1.1.1.3", "1.0.0.3", "2606:4700:4700::1113", "2606:4700:4700::1003") # Cloudflare for Families
# $dns_servers = @("76.76.2.2", "76.76.10.2", "2606:1a40::2", "2606:1a40:1::2") # Control D: Malware + Ads & Tracking
# $dns_servers = @("76.76.2.4", "76.76.10.4", "2606:1a40::4", "2606:1a40:1::4") # Control D: Malware + Ads & Tracking + Adult Content & Drugs
# $dns_servers = @("76.76.2.3", "76.76.10.3", "2606:1a40::3", "2606:1a40:1::3") # Control D: Malware + Ads & Tracking + Social Networks

# browser_policy.ps1
$extension_blocklist = @("*")
# if a list of allowed or forced extensions, create a list of strings
$extension_allowlist = @("")
$extension_forcelist = @("")

# Uncomment one of the following
# $doh_address = "https://YOUR_ENDPOINT.cloudflare-gateway.com/dns-query" # Personalized blocking: cf zero trust
 $doh_address = "https://security.cloudflare-dns.com/dns-query" # Cloudflare Malware
# $doh_address = "https://dns0.eu/"
# $doh_address = "https://zero.dns0.eu/"
# $doh_address = "https://kids.dns0.eu/"
# $doh_address = "https://family.cloudflare-dns.com/dns-query"
# $doh_address = "https://freedns.controld.com/p2" # Control D: Malware + Ads & Tracking
# $doh_address = "https://freedns.controld.com/family" # Control D: Malware + Ads & Tracking + Adult Content & Drugs
# $doh_address = "https://freedns.controld.com/p3" # Control D: Malware + Ads & Tracking + Social Networks

# 10_3_disable_autorun.ps1
# N/A: No custom configuration is necessary to disable autorun/autoplay.

# logon_banner.ps1
$org_name = "Organization Name Here"
$banner_title = "By clicking OK below you acknowledge and consent to the following:"
$banner_text  = @"
All activities on this computer will be monitored.
You consent to the unrestricted monitoring, interception, recording, and searching of all communications and data on this computer system at any time and for any purpose by $org_name and by any person or entity authorized by $org_name.
You are acknowledging that you have no reasonable expectation of privacy regarding your use of this computer system.
These acknowledgements and consents cover all use of the system, including work-related and personal use without exception.
"@

# system_restore_point.ps1
# change the drive letter, description, and restore point type
# "$system_drive" setting was configured above in 03_6_encrypt_drive.ps1
$sr_description = "Restore Point prior to device configuration changes"
$sr_type = "MODIFY_SETTINGS"

