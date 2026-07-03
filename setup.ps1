# FineStack Setup Script
# Run this after cloning from GitHub
# Requires: Administrator privileges

#Requires -RunAsAdministrator

$RootDir = $PSScriptRoot
if (-not $RootDir) {
    $RootDir = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   FineStack Setup Wizard" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if apps directory exists
if (Test-Path "$RootDir\apps\php") {
    Write-Host "[OK] Binaries found in apps\" -ForegroundColor Green
} else {
    Write-Host "[!] Binaries not found. You need to download:" -ForegroundColor Yellow
    Write-Host "  1. PHP NTS (x64) - https://windows.php.net/download/" -ForegroundColor Gray
    Write-Host "  2. nginx - https://nginx.org/en/download.html" -ForegroundColor Gray
    Write-Host "  3. MySQL - https://dev.mysql.com/downloads/mysql/" -ForegroundColor Gray
    Write-Host "  4. Composer - https://getcomposer.org/download/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Extract to respective folders in apps\" -ForegroundColor Gray
    Write-Host "See README.md for details." -ForegroundColor Gray
    exit 1
}

# Create directories
Write-Host "[*] Creating directories..." -ForegroundColor Cyan
$dirs = @(
    "data\mysql", "logs\nginx", "logs\mysql", "sites\default", "current", "backups",
    "temp", "temp\client_body_temp", "temp\proxy_temp", "temp\fastcgi_temp", "temp\uwsgi_temp", "temp\scgi_temp"
)
foreach ($dir in $dirs) {
    $path = Join-Path $RootDir $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
}

# Find PHP versions
Write-Host ""
Write-Host "[*] Detecting PHP versions..." -ForegroundColor Cyan
$phpVersions = Get-ChildItem "$RootDir\apps\php" -Directory | Select-Object -ExpandProperty Name
if ($phpVersions.Count -eq 0) {
    Write-Host "[ERROR] No PHP versions found in apps\php\" -ForegroundColor Red
    exit 1
}
Write-Host "  Found: $($phpVersions -join ', ')" -ForegroundColor Green

# Find nginx
$nginxVersion = Get-ChildItem "$RootDir\apps\nginx" -Directory | Select-Object -First 1 -ExpandProperty Name
if (-not $nginxVersion) {
    Write-Host "[ERROR] nginx not found in apps\nginx\" -ForegroundColor Red
    exit 1
}
Write-Host "  nginx: $nginxVersion" -ForegroundColor Green

# Find MySQL
$mysqlVersion = Get-ChildItem "$RootDir\apps\mysql" -Directory | Select-Object -First 1 -ExpandProperty Name
if (-not $mysqlVersion) {
    Write-Host "[ERROR] MySQL not found in apps\mysql\" -ForegroundColor Red
    exit 1
}
Write-Host "  MySQL: $mysqlVersion" -ForegroundColor Green

# Create symlinks
Write-Host ""
Write-Host "[*] Creating symlinks..." -ForegroundColor Cyan

# PHP symlink (use latest version)
$latestPhp = $phpVersions | Sort-Object | Select-Object -Last 1
$phpSymlink = Join-Path $RootDir "current\php"
if (Test-Path $phpSymlink) {
    cmd /c rmdir $phpSymlink 2>$null
}
cmd /c mklink /D $phpSymlink "$RootDir\apps\php\$latestPhp" >$null
Write-Host "  PHP: $latestPhp" -ForegroundColor Green

# nginx symlink
$nginxSymlink = Join-Path $RootDir "current\nginx"
if (Test-Path $nginxSymlink) {
    cmd /c rmdir $nginxSymlink 2>$null
}
cmd /c mklink /D $nginxSymlink "$RootDir\apps\nginx\$nginxVersion" >$null
Write-Host "  nginx: $nginxVersion" -ForegroundColor Green

# MySQL symlink
$mysqlSymlink = Join-Path $RootDir "current\mysql"
if (Test-Path $mysqlSymlink) {
    cmd /c rmdir $mysqlSymlink 2>$null
}
cmd /c mklink /D $mysqlSymlink "$RootDir\apps\mysql\$mysqlVersion" >$null
Write-Host "  MySQL: $mysqlVersion" -ForegroundColor Green

# Composer symlink
$composerVersion = Get-ChildItem "$RootDir\apps\composer" -Directory | Select-Object -First 1 -ExpandProperty Name
if ($composerVersion) {
    $composerSymlink = Join-Path $RootDir "current\composer"
    if (Test-Path $composerSymlink) {
        cmd /c rmdir $composerSymlink 2>$null
    }
    cmd /c mklink /D $composerSymlink "$RootDir\apps\composer\$composerVersion" >$null
    Write-Host "  Composer: $composerVersion" -ForegroundColor Green
}

# Copy nginx config files
Write-Host ""
Write-Host "[*] Copying nginx config files..." -ForegroundColor Cyan
$nginxConfigFiles = @("fastcgi_params", "mime.types")
foreach ($file in $nginxConfigFiles) {
    $source = "$RootDir\current\nginx\conf\$file"
    $dest = "$RootDir\config\nginx\$file"
    if (Test-Path $source) {
        if (-not (Test-Path $dest)) {
            Copy-Item $source $dest
            Write-Host "  Copied: $file" -ForegroundColor Gray
        } else {
            Write-Host "  Already exists: $file" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [!] Source not found: $file" -ForegroundColor Yellow
    }
}

# Initialize MySQL data directory
Write-Host ""
Write-Host "[*] Checking MySQL data directory..." -ForegroundColor Cyan
if (-not (Test-Path "$RootDir\data\mysql\mysql")) {
    Write-Host "  Initializing MySQL..." -ForegroundColor Yellow
    & "$RootDir\current\mysql\bin\mysqld.exe" --initialize-insecure --datadir="$RootDir\data\mysql" --console
    Write-Host "[OK] MySQL initialized (root user, no password)" -ForegroundColor Green
} else {
    Write-Host "[OK] MySQL data directory exists" -ForegroundColor Green
}

# Create default index.php if not exists
$defaultIndex = "$RootDir\sites\default\index.php"
if (-not (Test-Path $defaultIndex)) {
    Write-Host ""
    Write-Host "[*] Creating default site..." -ForegroundColor Cyan
    @"
<?php
phpinfo();
"@ | Out-File -FilePath $defaultIndex -Encoding ASCII
    Write-Host "[OK] Default site created" -ForegroundColor Green
}

# PATH configuration
Write-Host ""
Write-Host "[*] PATH Configuration" -ForegroundColor Cyan
Write-Host "  You need to add these to your PATH:" -ForegroundColor Yellow
Write-Host "    $RootDir\bin" -ForegroundColor Gray
Write-Host "    $RootDir\current\php" -ForegroundColor Gray
Write-Host "    $RootDir\current\nginx" -ForegroundColor Gray
Write-Host "    $RootDir\current\mysql\bin" -ForegroundColor Gray
Write-Host ""
Write-Host "  Add to PATH manually or run:" -ForegroundColor Yellow
Write-Host "    .\bin\add-to-path.ps1" -ForegroundColor Gray

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "   Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Add to PATH (see above)" -ForegroundColor Gray
Write-Host "  2. Run: dev start" -ForegroundColor Gray
Write-Host "  3. Open: http://localhost" -ForegroundColor Gray
Write-Host ""
