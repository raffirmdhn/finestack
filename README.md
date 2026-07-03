# FineStack

Lightweight, portable development environment for Windows - A complete Laragon replacement.

## Features

- **Multiple PHP Versions**: Easy switching between PHP 8.1, 8.2, and more
- **Web Server**: nginx with FastCGI support
- **Database**: MySQL with configurable versions
- **Package Manager**: Composer integration
- **Symlink-based**: Instant version switching without file copying
- **CLI Tool**: Simple `dev` command for all operations
- **Tab Completion**: PowerShell and cmd/cmder support
- **Portable**: No installation, no system modifications (except PATH)

## Installation

### Cloning from GitHub

**For first-time setup after cloning:**

```bash
# 1. Clone repository
git clone https://github.com/yourusername/finestack.git
cd finestack

# 2. Download binaries (not included in repo)
# - PHP NTS x64: https://windows.php.net/download/
# - nginx: https://nginx.org/en/download.html
# - MySQL: https://dev.mysql.com/downloads/mysql/
# - Composer: https://getcomposer.org/download/
# Extract to: apps/php/, apps/nginx/, apps/mysql/, apps/composer/

# 3. Run setup script (as Administrator)
powershell -ExecutionPolicy Bypass -File setup.ps1

# 4. Add to PATH (as Administrator)
powershell -ExecutionPolicy Bypass -File bin\add-to-path.ps1

# 5. Restart terminal, then start services
dev start
```

**📖 See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions and troubleshooting.**

---

## Quick Start

**For existing installations:**

```cmd
# Start all services
dev start

# Check status
dev status

# Open http://localhost in browser
# Default site at sites/default/

# Stop services
dev stop
```

## Folder Structure

```
FineStack/
├── apps/           # Application binaries
│   ├── php/        # PHP versions (8.1.32, 8.2.28, etc.)
│   ├── nginx/      # nginx versions
│   ├── mysql/      # MySQL versions
│   └── composer/   # Composer
├── bin/            # CLI scripts
│   ├── dev.cmd     # Main CLI entry point
│   ├── dev.ps1     # PowerShell implementation
│   └── *.ps1       # Helper scripts
├── config/         # Configuration files
│   ├── php/        # php.ini
│   ├── nginx/      # nginx.conf, sites/*.conf
│   └── mysql/      # my.ini
├── current/        # Symlinks to active versions
│   ├── php/        # → apps/php/8.2.28
│   ├── nginx/      # → apps/nginx/1.28
│   ├── mysql/      # → apps/mysql/8.4.3
│   └── composer/   # → apps/composer/2.10.2
├── data/           # Service data
│   └── mysql/      # MySQL data directory
├── logs/           # Service logs
│   ├── nginx/
│   └── mysql/
└── sites/          # Web sites
    └── default/    # Default site (index.php)
```

## Commands Reference

### Service Management

```cmd
# Start all services (nginx, PHP-CGI, MySQL)
dev start

# Stop all services
dev stop

# Restart all services
dev restart

# Restart specific service
dev restart nginx
dev restart php
dev restart mysql

# Check service status
dev status
```

### Version Management

```cmd
# List available PHP versions
dev list php

# List available MySQL versions
dev list mysql

# List all versions
dev list all

# Switch PHP version (requires admin)
dev use php 8.1.32

# Switch database version (requires admin)
dev use db mysql
```

### Service Status Output

```
[OK] nginx     - PID: 1234, Memory: 12.5 MB, Port 80: LISTENING
[OK] php-cgi   - PID: 5678, Memory: 45.2 MB, Port 9000: LISTENING
[OK] mysqld    - PID: 9012, Memory: 234.5 MB, Port 3306: LISTENING

Active Versions:
  PHP: 8.2.28
  Database: mysql 8.4.3
```

## Version Switching

FineStack uses **symlinks** for instant version switching:

1. Multiple versions stored in `apps/php/`, `apps/mysql/`, etc.
2. `current/` folder contains symlinks to active versions
3. Switching versions updates symlinks (requires admin privileges)
4. No file copying = instant switching

**Example: Adding new PHP version**

```cmd
# Download PHP 8.3.0 NTS (x64)
# Extract to C:\Users\Raffi\Programs\FineStack\apps\php\8.3.0

# Switch to new version
dev use php 8.3.0

# Verify
php -v
```

## Adding New PHP Versions

**Requirements:**
- PHP NTS (Non-Thread Safe) build recommended for nginx FastCGI
- x64 (64-bit) version
- Download from: https://windows.php.net/download/

**Steps:**

1. **Download and extract**
   ```cmd
   # Extract to: apps\php\{version}
   # Example: apps\php\8.3.0
   ```

2. **Verify structure**
   ```
   apps\php\8.3.0\
   ├── php.exe
   ├── php-cgi.exe
   ├── ext\          # Extensions folder
   └── ...
   ```

3. **Switch to new version**
   ```cmd
   dev use php 8.3.0
   ```

4. **Restart PHP-CGI**
   ```cmd
   dev restart php
   ```

**The shared `config/php/php.ini` applies to all PHP versions.**

## Creating New Sites

FineStack uses nginx with site-based configuration.

**Example: Create a new site**

1. **Create site folder**
   ```cmd
   mkdir sites\myproject
   echo ^<?php phpinfo(); ?^> > sites\myproject\index.php
   ```

2. **Create nginx site config**
   ```cmd
   # File: config\nginx\sites\myproject.conf
   ```

   ```nginx
   server {
       listen 80;
       server_name myproject.local;
       root "C:/Users/Raffi/Programs/FineStack/sites/myproject";
       
       index index.php index.html;
       
       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }
       
       location ~ \.php$ {
           fastcgi_pass   127.0.0.1:9000;
           fastcgi_index  index.php;
           fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include        fastcgi_params;
       }
   }
   ```

3. **Add to hosts file** (requires admin)
   ```cmd
   # File: C:\Windows\System32\drivers\etc\hosts
   # Add line:
   127.0.0.1  myproject.local
   ```

4. **Reload nginx**
   ```cmd
   dev restart nginx
   ```

5. **Open in browser**
   ```
   http://myproject.local
   ```

## Configuration

### PHP Configuration

**File:** `config/php/php.ini`

Shared across all PHP versions. Key settings:

```ini
extension_dir = "C:/Users/Raffi/Programs/FineStack/current/php/ext"
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
date.timezone = Asia/Jakarta
```

### nginx Configuration

**Main config:** `config/nginx/nginx.conf`

**Site configs:** `config/nginx/sites/*.conf`

Default FastCGI configuration passes PHP requests to port 9000.

### MySQL Configuration

**File:** `config/mysql/my.ini`

Key settings:

```ini
port = 3306
character-set-server = utf8mb4
max_connections = 100
```

## Tab Completion

### For cmd/cmder (Clink)

Already configured if you have cmder with Clink:

```cmd
# File: bin\dev-completion.lua (already installed)

# Test:
dev [TAB]           # Shows: start, stop, status, list, use
dev use php [TAB]   # Shows: 8.1.32, 8.2.28
```

### For PowerShell (optional)

**One-time setup:**

```powershell
# Open PowerShell profile
notepad $PROFILE

# Add this line:
. "C:\Users\Raffi\Programs\FineStack\bin\FineStack-Completion.ps1"

# Save, restart PowerShell

# Bonus: Show all suggestions with Tab (optional)
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
```

## Troubleshooting

### Services won't start

```cmd
# Check if ports are in use
netstat -ano | findstr ":80 "
netstat -ano | findstr ":9000 "
netstat -ano | findstr ":3306 "

# Kill conflicting processes
taskkill /PID <pid> /F

# Check logs
type logs\nginx\error.log
type logs\mysql\error.log
```

### PHP version won't switch

- **Requires admin privileges**
- Run cmd/PowerShell as Administrator
- Or right-click → "Run as administrator"

### nginx: "bind() to 0.0.0.0:80 failed"

- Port 80 already in use
- Check for other web servers (IIS, Apache, old Laragon)
- Stop conflicting service or change nginx port in `config/nginx/nginx.conf`

### MySQL won't start

```cmd
# Check if data directory is initialized
dir data\mysql

# If empty, reinitialize:
current\mysql\bin\mysqld --initialize-insecure --datadir=C:\Users\Raffi\Programs\FineStack\data\mysql
```

### PHP extensions not loading

- Check `extension_dir` in `config/php/php.ini`
- Should point to `current/php/ext`
- Verify DLL files exist in `current/php/ext/`

### Composer not found

```cmd
# Verify composer.bat exists in bin/
dir bin\composer.bat

# Verify PATH includes FineStack\bin
echo %PATH%
```

## Database Access

### Command Line

```cmd
# MySQL client (no password for root)
mysql -u root

# Create database
mysql -u root -e "CREATE DATABASE myapp;"

# Import SQL file
mysql -u root myapp < database.sql
```

### GUI Tools

- **HeidiSQL**: Connect to 127.0.0.1:3306, user: root, no password
- **phpMyAdmin**: Place in `sites/phpmyadmin/`, configure nginx site

## PATH Configuration

FineStack adds these to Windows User PATH:

```
C:\Users\Raffi\Programs\FineStack\bin
C:\Users\Raffi\Programs\FineStack\current\php
C:\Users\Raffi\Programs\FineStack\current\nginx
C:\Users\Raffi\Programs\FineStack\current\mysql\bin
```

This allows `dev`, `php`, `composer`, `mysql` commands from any directory.

## Backup & Restore

### Backup Configuration

```cmd
# Backup config folder
xcopy config config_backup\ /E /I /H

# Or use PowerShell
powershell Compress-Archive -Path config -DestinationPath config_backup.zip
```

### Backup Sites & Databases

```cmd
# Backup sites
xcopy sites sites_backup\ /E /I /H

# Export database
mysqldump -u root --all-databases > backup.sql

# Export specific database
mysqldump -u root myapp > myapp_backup.sql
```

### Restore Database

```cmd
mysql -u root < backup.sql
```

## Switching from Laragon

FineStack completely replaces Laragon:

1. ✅ **Services managed independently** - No conflicts
2. ✅ **Laragon kept as backup** - At `C:\Users\Raffi\Programs\laragon\`
3. ✅ **PATH cleaned** - Laragon removed from PATH
4. ✅ **Auto-start disabled** - Laragon won't start automatically

To re-enable Laragon: Add back PATH entries from `LARAGON_BACKUP_INFO.md`

## Technical Details

### Services Architecture

- **nginx**: Master/worker process model, port 80
- **PHP-CGI**: FastCGI process, port 9000 (127.0.0.1 only)
- **MySQL**: Standard mysqld server, port 3306

### Why NTS PHP?

- **NTS** (Non-Thread Safe) recommended for nginx FastCGI
- **TS** (Thread Safe) for Apache with mod_php
- FineStack uses nginx → NTS PHP

### Symlink Requirements

- Creating/modifying symlinks requires **Administrator privileges**
- One-time setup: Run `dev use php <version>` as admin
- After setup: `dev start/stop/status` work without admin

## Support & Contributions

This is a personal development environment. Modify as needed:

- Add more PHP versions in `apps/php/`
- Add PostgreSQL/MariaDB in `apps/`
- Customize nginx configs in `config/nginx/sites/`
- Extend `bin/dev.ps1` with new commands

## License

Personal project. Use and modify freely.

---

**FineStack** - Fine-tuned stack for fine developers. 🚀
