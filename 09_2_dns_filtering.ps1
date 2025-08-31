# This scripts updates the DNS servers on all network adapters to enable DNS filtering service
# CIS Controls v8.1 - Safeguard 9.2

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


# get the current DNS servers
$net_adapters = Get-NetAdapter
function get_dns_servers {
    param ($adapters)
    Write-Output "==> Current DNS Servers are: " | Tee-Object $logfile -Append
    foreach ($a in $adapters) {
        $dns_data = Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex
        Write-Output $dns_data | Tee-Object $logfile -Append
    }
    
}

# set the new servers on all interfaces
function set_dns_servers {
    param ($adapters)
    Try {
        Write-Output "==> Updating DNS configuration... " | Tee-Object $logfile -Append
        foreach ($a in $adapters){
            Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $dns_servers
        }
    }
    Catch {
        #didn't work
        Write-Output "There was an error setting the DNS servers" | Tee-Object $logfile -Append
        Exit
    }
}

get_dns_servers($net_adapters)
set_dns_servers($net_adapters)
Write-Output "Update completed. New configuration as follows" | Tee-Object $logfile -Append
get_dns_servers($net_adapters)

