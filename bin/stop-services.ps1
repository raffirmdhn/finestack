param(
    [Parameter(Mandatory=$false)]
    [string]$Service = "all"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

function Stop-Nginx {
    Write-Host "Stopping nginx..." -ForegroundColor Cyan
    
    # Check if running
    $Process = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if (-not $Process) {
        Write-Host "[WARN] nginx is not running" -ForegroundColor Yellow
        return $true
    }
    
    # Try graceful shutdown first
    $NginxExe = Join-Path $RootDir "current\nginx\nginx.exe"
    if (Test-Path $NginxExe) {
        try {
            Start-Process -FilePath $NginxExe -ArgumentList "-s", "quit" -WindowStyle Hidden -Wait
            Start-Sleep -Seconds 1
        } catch {
            # Fall back to force kill
        }
    }
    
    # Check if still running
    $Process = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if ($Process) {
        # Force stop
        try {
            Stop-Process -Name "nginx" -Force
            Write-Host "[OK] nginx stopped (forced)" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[ERROR] Error stopping nginx: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "[OK] nginx stopped successfully" -ForegroundColor Green
        return $true
    }
}

function Stop-PHP {
    Write-Host "Stopping PHP-CGI..." -ForegroundColor Cyan
    
    # Check if running
    $Process = Get-Process -Name "php-cgi" -ErrorAction SilentlyContinue
    if (-not $Process) {
        Write-Host "[WARN] PHP-CGI is not running" -ForegroundColor Yellow
        return $true
    }
    
    # Stop process
    try {
        Stop-Process -Name "php-cgi" -Force
        Start-Sleep -Seconds 1
        
        # Verify
        $Process = Get-Process -Name "php-cgi" -ErrorAction SilentlyContinue
        if (-not $Process) {
            Write-Host "[OK] PHP-CGI stopped successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] PHP-CGI failed to stop" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] Error stopping PHP-CGI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Stop-MySQL {
    Write-Host "Stopping MySQL..." -ForegroundColor Cyan
    
    # Check if running
    $Process = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
    if (-not $Process) {
        Write-Host "[WARN] MySQL is not running" -ForegroundColor Yellow
        return $true
    }
    
    # Try graceful shutdown first using mysqladmin
    $MysqlAdmin = Join-Path $RootDir "current\mysql\bin\mysqladmin.exe"
    if (Test-Path $MysqlAdmin) {
        try {
            Start-Process -FilePath $MysqlAdmin -ArgumentList "-u", "root", "shutdown" -WindowStyle Hidden -Wait
            Start-Sleep -Seconds 2
        } catch {
            # Fall back to force kill
        }
    }
    
    # Check if still running
    $Process = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
    if ($Process) {
        # Force stop
        try {
            Stop-Process -Name "mysqld" -Force
            Write-Host "[OK] MySQL stopped (forced)" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[ERROR] Error stopping MySQL: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "[OK] MySQL stopped successfully" -ForegroundColor Green
        return $true
    }
}

# Main logic
$Service = $Service.ToLower()

switch ($Service) {
    "nginx" {
        Stop-Nginx | Out-Null
    }
    "php" {
        Stop-PHP | Out-Null
    }
    "mysql" {
        Stop-MySQL | Out-Null
    }
    "all" {
        Write-Host "Stopping all services..." -ForegroundColor Cyan
        Write-Host ""
        Stop-Nginx | Out-Null
        Stop-PHP | Out-Null
        Stop-MySQL | Out-Null
        Write-Host ""
        Write-Host "Done!" -ForegroundColor Green
    }
    default {
        Write-Host "Error: Invalid service '$Service'" -ForegroundColor Red
        Write-Host "Valid options: nginx, php, mysql, all"
        exit 1
    }
}
