# Add FineStack to Windows PATH
# Run as Administrator

#Requires -RunAsAdministrator

$RootDir = Split-Path $PSScriptRoot -Parent

$pathsToAdd = @(
    "$RootDir\bin",
    "$RootDir\current\php",
    "$RootDir\current\nginx",
    "$RootDir\current\mysql\bin"
)

Write-Host "Adding FineStack to PATH..." -ForegroundColor Cyan
Write-Host ""

# Get current User PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathArray = $currentPath -split ";"

$added = 0
foreach ($path in $pathsToAdd) {
    if ($pathArray -notcontains $path) {
        Write-Host "[+] Adding: $path" -ForegroundColor Green
        $pathArray = @($path) + $pathArray  # Prepend for priority
        $added++
    } else {
        Write-Host "[OK] Already in PATH: $path" -ForegroundColor Gray
    }
}

if ($added -gt 0) {
    # Update PATH
    $newPath = $pathArray -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    Write-Host ""
    Write-Host "[OK] $added path(s) added to User PATH" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Restart your terminal for changes to take effect!" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "[OK] All paths already configured" -ForegroundColor Green
}
