param(
    [Parameter(Mandatory=$true)]
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

# Normalize version (remove 'php-' prefix if present)
$Version = $Version -replace '^php-', ''

$TargetPath = Join-Path $RootDir "apps\php\$Version"
$LinkPath = Join-Path $RootDir "current\php"

# Check if target version exists
if (-not (Test-Path $TargetPath)) {
    Write-Host "Error: PHP version $Version not found" -ForegroundColor Red
    Write-Host "Looking for: $TargetPath"
    Write-Host ""
    Write-Host "Available PHP versions:"
    Get-ChildItem (Join-Path $RootDir "apps\php") -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)"
    }
    exit 1
}

# Get current version
if (Test-Path $LinkPath) {
    $CurrentTarget = (Get-Item $LinkPath).Target
    Write-Host "Current PHP: $CurrentTarget" -ForegroundColor Yellow
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
        Write-Host "[OK] Switched to PHP $Version" -ForegroundColor Green
        Write-Host "New path: $NewTarget"
        
        # Show PHP version
        $PhpExe = Join-Path $LinkPath "php.exe"
        if (Test-Path $PhpExe) {
            Write-Host ""
            & $PhpExe -v | Select-Object -First 1
        }
    } else {
        Write-Host "[ERROR] Failed to create symlink" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Error creating symlink: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
