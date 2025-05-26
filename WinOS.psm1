. "$PSScriptRoot\Classes\WinOS.ps1"
function Get-WinOSInfo([string]$Server){[Sys]::GetServerInfo("$Server");}
function Get-WinOSInfoPrompt([string]$Server){$Info = Get-WinOSInfo -Server $(Read-Host "Server"); Write-Host "Server: $($Info.Server)"}

function Find-PathInHome([string]$Pattern){[Paths]::FindRootPathInHome($Pattern);}