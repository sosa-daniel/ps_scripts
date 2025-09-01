# Download scripts from github into the CWD

$url_base = "https://raw.githubusercontent.com/sosa-daniel/ps_scripts/master/"
# Re-generate file list with:
# (Get-ChildItem -File -Name -Filter "*.ps1") -join '", "'
$files = @("03_6_encrypt_drive.ps1", "04_3_auto_lock_05_2_passwords.ps1", "09_2_dns_filtering.ps1", "09_2_dns_over_https.ps1", "10_3_disable_autorun.ps1", "logon_banner.ps1", "settings.ps1", "system_restore_point.ps1")

foreach ($f in $files) {
    if (-not (Test-Path -Path $PSScriptRoot\$f)) {
        Invoke-WebRequest -Uri $url_base$f -OutFile .\$f
        Write-Host "$f downloaded successfully"
    } else {
        Write-Host "$f already exists in current working directory. Skipping."
    }
}
