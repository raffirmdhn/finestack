$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

function Get-ServiceStatus {
    param(
        [string]$ProcessName,
        [string]$ServiceName,
        [int]$Port
    )
    
    $Process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if ($Process) {
        $Status = "Running"
        $Color = "Green"
        $Symbol = "[OK]"
        
        # Get first process if multiple
        $Proc = $Process | Select-Object -First 1
        $ProcessId = $Proc.Id
        $Memory = [math]::Round($Proc.WorkingSet64 / 1MB, 2)
        
        Write-Host "$Symbol $ServiceName" -ForegroundColor $Color -NoNewline
        Write-Host " (PID: $ProcessId, Memory: ${Memory}MB)" -ForegroundColor Gray
    } else {
        $Status = "Stopped"
        $Color = "Red"
        $Symbol = "[ERROR]"
        
        Write-Host "$Symbol $ServiceName" -ForegroundColor $Color -NoNewline
        Write-Host " (Not running)" -ForegroundColor Gray
    }
    
    # Check port if specified
    if ($Port -and $Process) {
        $PortCheck = netstat -ano | Select-String ":$Port.*LISTENING"
        if ($PortCheck) {
            Write-Host "  |- Port $Port is listening" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "FineStack Service Status" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check nginx
Get-ServiceStatus -ProcessName "nginx" -ServiceName "nginx" -Port 80

# Check PHP-CGI
Get-ServiceStatus -ProcessName "php-cgi" -ServiceName "PHP-CGI" -Port 9000

# Check MySQL
Get-ServiceStatus -ProcessName "mysqld" -ServiceName "MySQL" -Port 3306

Write-Host ""
Write-Host "Active Versions:" -ForegroundColor Cyan
Write-Host "----------------" -ForegroundColor Cyan

# Show current versions
$PhpLink = Join-Path $RootDir "current\php"
$MysqlLink = Join-Path $RootDir "current\mysql"
$NginxLink = Join-Path $RootDir "current\nginx"

if (Test-Path $PhpLink) {
    $PhpTarget = (Get-Item $PhpLink).Target
    $PhpVersion = Split-Path $PhpTarget -Leaf
    Write-Host "PHP:   $PhpVersion" -ForegroundColor Gray
}

if (Test-Path $NginxLink) {
    $NginxTarget = (Get-Item $NginxLink).Target
    $NginxVersion = Split-Path $NginxTarget -Leaf
    Write-Host "nginx: $NginxVersion" -ForegroundColor Gray
}

if (Test-Path $MysqlLink) {
    $MysqlTarget = (Get-Item $MysqlLink).Target
    $MysqlVersion = Split-Path $MysqlTarget -Leaf
    Write-Host "MySQL: $MysqlVersion" -ForegroundColor Gray
}

Write-Host ""
