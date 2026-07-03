# Backup FineStack Configuration
# Creates timestamped backup of config folder

$RootDir = Split-Path $PSScriptRoot -Parent
$ConfigDir = Join-Path $RootDir "config"
$BackupDir = Join-Path $RootDir "backups"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$BackupFile = Join-Path $BackupDir "config_backup_$Timestamp.zip"

# Create backups directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

Write-Host "Creating config backup..." -ForegroundColor Cyan

try {
    # Create zip archive
    Compress-Archive -Path $ConfigDir -DestinationPath $BackupFile -Force
    
    $FileSize = [math]::Round((Get-Item $BackupFile).Length / 1KB, 2)
    Write-Host "[OK] Config backed up successfully" -ForegroundColor Green
    Write-Host "Location: $BackupFile" -ForegroundColor Gray
    Write-Host "Size: $FileSize KB" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Backup failed: $_" -ForegroundColor Red
    exit 1
}
