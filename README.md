# ps_scripts
Powershell Scripts for various system administration tasks

## Download scripts into current working directory
`irm https://raw.githubusercontent.com/sosa-daniel/ps_scripts/master/dl.ps1 | iex`

## Start PS as administrator and set the session execution policy:
`Set-ExecutionPolicy Bypass`

This will permit the execution of scripts without any warnings or prompts. Applies only to the current PS session.

