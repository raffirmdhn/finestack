param(
    [Parameter(Mandatory=$true)]
    [string]$Database,
    
    [Parameter(Mandatory=$false)]
    [string]$Version
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Error: This command requires Administrator privileges" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again"
    exit 1
}

# Normalize database name
$Database = $Database.ToLower()
$ValidDatabases = @("mysql", "mariadb", "postgres")

if ($Database -notin $ValidDatabases) {
    Write-Host "Error: Invalid database type '$Database'" -ForegroundColor Red
    Write-Host "Valid options: mysql, mariadb, postgres"
    exit 1
}

$DbPath = Join-Path $RootDir "apps\$Database"

# Check if database type exists
if (-not (Test-Path $DbPath)) {
    Write-Host "Error: Database type '$Database' not installed" -ForegroundColor Red
    Write-Host "Looking for: $DbPath"
    Write-Host ""
    Write-Host "Installed databases:"
    Get-ChildItem (Join-Path $RootDir "apps") -Directory | Where-Object { $_.Name -in $ValidDatabases } | ForEach-Object {
        Write-Host "  - $($_.Name)"
    }
    exit 1
}

# Find available versions
$Versions = Get-ChildItem $DbPath -Directory | Select-Object -ExpandProperty Name

if ($Versions.Count -eq 0) {
    Write-Host "Error: No versions found for $Database" -ForegroundColor Red
    exit 1
}

# If version not specified, use the first (or only) available version
if (-not $Version) {
    $Version = $Versions[0]
    Write-Host "No version specified, using: $Version" -ForegroundColor Cyan
}

$TargetPath = Join-Path $DbPath $Version
$LinkPath = Join-Path $RootDir "current\$Database"

# Check if target version exists
if (-not (Test-Path $TargetPath)) {
    Write-Host "Error: $Database version $Version not found" -ForegroundColor Red
    Write-Host "Looking for: $TargetPath"
    Write-Host ""
    Write-Host "Available versions:"
    $Versions | ForEach-Object {
        Write-Host "  - $_"
    }
    exit 1
}

# Get current version
if (Test-Path $LinkPath) {
    $CurrentTarget = (Get-Item $LinkPath).Target
    Write-Host "Current $Database`: $CurrentTarget" -ForegroundColor Yellow
}

# Remove existing symlink
if (Test-Path $LinkPath) {
    Remove-Item $LinkPath -Force
}

# Create new symlink
try {
    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
    
    # Verify
    if (Test-Path $LinkPath) {
        $NewTarget = (Get-Item $LinkPath).Target
        Write-Host "[OK] Switched to $Database $Version" -ForegroundColor Green
        Write-Host "New path: $NewTarget"
    } else {
        Write-Host "[ERROR] Failed to create symlink" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Error creating symlink: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
