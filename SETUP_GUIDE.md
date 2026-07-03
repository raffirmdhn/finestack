# FineStack Setup Guide (for cloning)

This guide is for setting up FineStack after cloning from GitHub.

## Prerequisites

- Windows 10/11
- PowerShell 5.1+
- Administrator privileges (for symlinks)

## Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/finestack.git
cd finestack
```

## Step 2: Download Binaries

**Binaries are NOT included in the repository.** Download manually:

### PHP (NTS x64)
- Download: https://windows.php.net/download/
- Versions: 8.1.32, 8.2.28 (or latest)
- Extract to: `apps/php/8.1.32`, `apps/php/8.2.28`

### nginx
- Download: https://nginx.org/en/download.html
- Version: 1.28 or latest
- Extract to: `apps/nginx/1.28`

### MySQL
- Download: https://dev.mysql.com/downloads/mysql/
- Version: 8.4.3 or latest
- Extract to: `apps/mysql/8.4.3`

### Composer
- Download: https://getcomposer.org/download/
- Version: Latest composer.phar
- Place in: `apps/composer/2.10.2/composer.phar`

## Step 3: Run Setup Script

**Run as Administrator:**

```powershell
# Right-click PowerShell -> Run as Administrator
cd C:\path\to\finestack
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

This will:
- Create necessary directories
- Detect installed versions
- Create symlinks to current versions
- Initialize MySQL data directory
- Create default site

## Step 4: Add to PATH

**Manual (recommended):**
1. Open System Properties → Environment Variables
2. Edit User PATH variable
3. Add these paths (in order):
   ```
   C:\path\to\finestack\bin
   C:\path\to\finestack\current\php
   C:\path\to\finestack\current\nginx
   C:\path\to\finestack\current\mysql\bin
   ```

**Or use helper script:**
```powershell
.\bin\add-to-path.ps1
```

Restart terminal after adding to PATH.

## Step 5: Start Services

```cmd
dev start
```

## Step 6: Verify

```cmd
dev status
php -v
mysql -u root -e "SELECT VERSION();"
```

Open: http://localhost

## Troubleshooting

### "Setup.ps1 cannot be loaded"
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### "Access denied" when creating symlinks
- Run PowerShell as Administrator
- Or enable Developer Mode (Settings → Update & Security → For developers)

### MySQL won't start
- Check if MySQL data initialized: `dir data\mysql`
- Re-run: `.\setup.ps1`

### PHP extensions not loading
- Verify `config/php/php.ini` has correct `extension_dir`
- Should point to: `C:/path/to/finestack/current/php/ext`

## Configuration

All configs in `config/` folder:
- `config/php/php.ini` - PHP settings
- `config/nginx/nginx.conf` - nginx main config
- `config/nginx/sites/*.conf` - Site configs
- `config/mysql/my.ini` - MySQL settings

## Next Steps

- Read main README.md for full documentation
- Create new sites in `sites/` folder
- Import databases (see README.md)
- Install Adminer/phpMyAdmin

## Support

See main README.md for:
- Commands reference
- Version switching
- Creating sites
- Troubleshooting

---

**Note:** This is a portable development environment. Keep binaries updated manually.
