param(
    [Parameter(Mandatory=$false)]
    [string]$Service = "all"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Restarting $Service..." -ForegroundColor Cyan
Write-Host ""

# Stop the service(s)
& "$ScriptDir\stop-services.ps1" -Service $Service

# Wait a moment
Start-Sleep -Seconds 2

Write-Host ""

# Start the service(s)
& "$ScriptDir\start-services.ps1" -Service $Service
