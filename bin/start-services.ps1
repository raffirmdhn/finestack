param(
    [Parameter(Mandatory=$false)]
    [string]$Service = "all"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

function Start-Nginx {
    Write-Host "Starting nginx..." -ForegroundColor Cyan
    
    $NginxExe = Join-Path $RootDir "current\nginx\nginx.exe"
    $NginxConf = Join-Path $RootDir "config\nginx\nginx.conf"
    
    if (-not (Test-Path $NginxExe)) {
        Write-Host "[ERROR] nginx.exe not found at: $NginxExe" -ForegroundColor Red
        return $false
    }
    
    # Check if already running
    $Process = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if ($Process) {
        Write-Host "[WARN] nginx is already running (PID: $($Process.Id))" -ForegroundColor Yellow
        return $true
    }
    
    # Start nginx
    try {
        Start-Process -FilePath $NginxExe -ArgumentList "-c", $NginxConf -WorkingDirectory (Join-Path $RootDir "current\nginx") -WindowStyle Hidden
        Start-Sleep -Seconds 1
        
        # Verify
        $Process = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
        if ($Process) {
            Write-Host "[OK] nginx started successfully (PID: $($Process[0].Id))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] nginx failed to start" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] Error starting nginx: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-PHP {
    Write-Host "Starting PHP-CGI..." -ForegroundColor Cyan
    
    $PhpCgiExe = Join-Path $RootDir "current\php\php-cgi.exe"
    $PhpIni = Join-Path $RootDir "config\php\php.ini"
    
    if (-not (Test-Path $PhpCgiExe)) {
        Write-Host "[ERROR] php-cgi.exe not found at: $PhpCgiExe" -ForegroundColor Red
        return $false
    }
    
    # Check if already running
    $Process = Get-Process -Name "php-cgi" -ErrorAction SilentlyContinue
    if ($Process) {
        Write-Host "[WARN] PHP-CGI is already running (PID: $($Process.Id))" -ForegroundColor Yellow
        return $true
    }
    
    # Start PHP-CGI
    try {
        Start-Process -FilePath $PhpCgiExe -ArgumentList "-b", "127.0.0.1:9000", "-c", $PhpIni -WindowStyle Hidden
        Start-Sleep -Seconds 1
        
        # Verify
        $Process = Get-Process -Name "php-cgi" -ErrorAction SilentlyContinue
        if ($Process) {
            Write-Host "[OK] PHP-CGI started successfully (PID: $($Process.Id))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] PHP-CGI failed to start" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] Error starting PHP-CGI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-MySQL {
    Write-Host "Starting MySQL..." -ForegroundColor Cyan
    
    $MysqldExe = Join-Path $RootDir "current\mysql\bin\mysqld.exe"
    $MyIni = Join-Path $RootDir "config\mysql\my.ini"
    
    if (-not (Test-Path $MysqldExe)) {
        Write-Host "[ERROR] mysqld.exe not found at: $MysqldExe" -ForegroundColor Red
        return $false
    }
    
    # Check if already running
    $Process = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
    if ($Process) {
        Write-Host "[WARN] MySQL is already running (PID: $($Process.Id))" -ForegroundColor Yellow
        return $true
    }
    
    # Start MySQL
    try {
        Start-Process -FilePath $MysqldExe -ArgumentList "--defaults-file=$MyIni" -WindowStyle Hidden
        Start-Sleep -Seconds 2
        
        # Verify
        $Process = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
        if ($Process) {
            Write-Host "[OK] MySQL started successfully (PID: $($Process.Id))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] MySQL failed to start" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] Error starting MySQL: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main logic
$Service = $Service.ToLower()

switch ($Service) {
    "nginx" {
        Start-Nginx | Out-Null
    }
    "php" {
        Start-PHP | Out-Null
    }
    "mysql" {
        Start-MySQL | Out-Null
    }
    "all" {
        Write-Host "Starting all services..." -ForegroundColor Cyan
        Write-Host ""
        Start-Nginx | Out-Null
        Start-PHP | Out-Null
        Start-MySQL | Out-Null
        Write-Host ""
        Write-Host "Done!" -ForegroundColor Green
    }
    default {
        Write-Host "Error: Invalid service '$Service'" -ForegroundColor Red
        Write-Host "Valid options: nginx, php, mysql, all"
        exit 1
    }
}
