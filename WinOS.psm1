. "$PSScriptRoot\Classes\WinOS.ps1"
function Get-WinOSInfo([string]$Server){[System]::GetServerInfo("$Server");}
function Get-WinOSInfoPrompt([string]$Server){Get-WinOSInfo -Server $(Read-Host "Server")}

function Find-PathInHome([string]$Pattern){[Paths]::FindRootPathInHome($Pattern);}