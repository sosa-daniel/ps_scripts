# ps_scripts
Powershell Scripts for various system administration tasks

## Fair warning
Do NOT run any commands/scripts from the internet unless you've read the source code and understand exactly how it works and what you are doing.

## Download the scripts into current working directory

`irm https://raw.githubusercontent.com/sosa-daniel/ps_scripts/master/dl.ps1 | iex`

## Start PS as administrator and set the session execution policy:
`Set-ExecutionPolicy Bypass`

This will permit the execution of scripts without any warnings or prompts. Applies only to the current PS session.

## CIS Controls 5.4: Restrict Administrator Privileges
_Restrict administrator privileges to dedicated administrator accounts on enterprise assets. Conduct general computing activities, such as internet browsing, email, and productivity suite use, from the user’s primary, non-privileged account._
** Configure this control manually to avoid possible Admin lockout issues.**

Create a system restore point prior to configuration changes to allow for rollback: `system_restore_point.ps1`

```
# View local user accounts:
Get-LocalUser

# View members of local Administrators group:
Get-LocalGroupMember -Group Administrators

# Create a new local user (replace values as needed)
$user = "MyNewAdminUserAccount"
$psw = Read-Host "password" -AsSecureString
New-LocalUser -Name $user -Password $psw

# Add the new user to Administrators group
Add-LocalGroupMember -Group Administrators -Member $user

# At this stage you should make sure the new admin credentials are working.

# Remove old_user account from the local Administrators group
Remove-LocalGroupMember -Group Administrators -Member old_user

# If there are unused local users, remove them: (also delete home directory and user profile)
Remove-LocalGroupMember -Group Administrators -Member UserToDelete
rm -r -Force C:\Users\UserToDelete
Get-CimInstance -ClassName Win32_UserProfile | Where-Object {$_.LocalPath -like "C:\Users\UserToDelete"} | Remove-CimInstance -Confirm:$true
```
