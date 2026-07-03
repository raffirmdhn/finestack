param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$Target,
    
    [Parameter(Position=2)]
    [string]$Value
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

function Show-AvailableVersions {
    param(
        [string]$Type
    )
    
    $Type = if ($Type) { $Type.ToLower() } else { "all" }
    
    if ($Type -eq "php" -or $Type -eq "all") {
        Write-Host ""
        Write-Host "Available PHP versions:" -ForegroundColor Cyan
        Write-Host "----------------------" -ForegroundColor Cyan
        
        $PhpPath = Join-Path $RootDir "apps\php"
        $CurrentPhp = ""
        
        if (Test-Path (Join-Path $RootDir "current\php")) {
            $CurrentPhpLink = Get-Item (Join-Path $RootDir "current\php")
            $CurrentPhp = Split-Path $CurrentPhpLink.Target -Leaf
        }
        
        if (Test-Path $PhpPath) {
            Get-ChildItem $PhpPath -Directory | ForEach-Object {
                if ($_.Name -eq $CurrentPhp) {
                    Write-Host "  [OK] $($_.Name) (active)" -ForegroundColor Green
                } else {
                    Write-Host "      $($_.Name)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  No PHP versions found" -ForegroundColor Red
        }
    }
    
    if ($Type -eq "mysql" -or $Type -eq "db" -or $Type -eq "all") {
        Write-Host ""
        Write-Host "Available MySQL versions:" -ForegroundColor Cyan
        Write-Host "------------------------" -ForegroundColor Cyan
        
        $MysqlPath = Join-Path $RootDir "apps\mysql"
        $CurrentMysql = ""
        
        if (Test-Path (Join-Path $RootDir "current\mysql")) {
            $CurrentMysqlLink = Get-Item (Join-Path $RootDir "current\mysql")
            $CurrentMysql = Split-Path $CurrentMysqlLink.Target -Leaf
        }
        
        if (Test-Path $MysqlPath) {
            Get-ChildItem $MysqlPath -Directory | ForEach-Object {
                if ($_.Name -eq $CurrentMysql) {
                    Write-Host "  [OK] $($_.Name) (active)" -ForegroundColor Green
                } else {
                    Write-Host "      $($_.Name)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  No MySQL versions found" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

function Show-Help {
    Write-Host "FineStack Development Environment CLI" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  fine start [all|nginx|php|mysql]   - Start services"
    Write-Host "  fine stop [all|nginx|php|mysql]    - Stop services"
    Write-Host "  fine restart [all|nginx|php|mysql] - Restart services"
    Write-Host "  fine status                         - Check service status"
    Write-Host "  fine use php <version>              - Switch PHP version (e.g., 8.1.32)"
    Write-Host "  fine list [php|mysql|all]           - List available versions"
    Write-Host "  fine use php <version>              - Switch PHP version (e.g., 8.1.32)"
    Write-Host "  fine use db <type>                  - Switch database (e.g., mysql)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  fine start all"
    Write-Host "  fine stop nginx"
    Write-Host "  fine restart nginx"
    Write-Host "  fine list php"
    Write-Host "  fine use php 8.1.32"
    Write-Host "  fine status"
}

if (-not $Command) {
    Show-Help
    exit 0
}

switch ($Command.ToLower()) {
    "start" {
        & "$ScriptDir\start-services.ps1" -Service $Target
    }
    "stop" {
        & "$ScriptDir\stop-services.ps1" -Service $Target
    }
    "restart" {
        & "$ScriptDir\restart-services.ps1" -Service $Target
    }
    "status" {
        & "$ScriptDir\status.ps1"
    }
    "list" {
        Show-AvailableVersions -Type $Target
    }
    "use" {
        if (-not $Target) {
            Write-Host "Error: Please specify what to switch (php or db)" -ForegroundColor Red
            Write-Host "Usage: fine use [php|db] <version>"
            exit 1
        }
        
        switch ($Target.ToLower()) {
            "php" {
                if (-not $Value) {
                    Write-Host "Error: Please specify PHP version" -ForegroundColor Red
                    Write-Host "Usage: fine use php <version>"
                    Write-Host "Example: fine use php 8.2.28"
                    exit 1
                }
                & "$ScriptDir\use-php.ps1" -Version $Value
            }
            "db" {
                if (-not $Value) {
                    Write-Host "Error: Please specify database type" -ForegroundColor Red
                    Write-Host "Usage: fine use db <type>"
                    Write-Host "Example: fine use db mysql"
                    exit 1
                }
                & "$ScriptDir\use-db.ps1" -Database $Value
            }
            default {
                Write-Host "Error: Invalid target '$Target'" -ForegroundColor Red
                Write-Host "Usage: fine use [php|db] <version>"
                exit 1
            }
        }
    }
    default {
        Write-Host "Error: Unknown command '$Command'" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}
