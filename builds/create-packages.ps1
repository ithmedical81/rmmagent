# Create deployment packages for Tactical RMM Agent
# PowerShell script to organize files into deployment packages

Write-Host "Creating Tactical RMM Agent deployment packages..." -ForegroundColor Green

# Change to builds directory
Set-Location builds

# Create Linux package
Write-Host "Creating Linux package..." -ForegroundColor Yellow
$linuxDir = "tactical-rmm-agent-linux"
if (Test-Path $linuxDir) { Remove-Item $linuxDir -Recurse -Force }
New-Item -ItemType Directory -Name $linuxDir | Out-Null

Copy-Item "tacticalrmm-linux-*" $linuxDir
Copy-Item "install-linux.sh" $linuxDir
Copy-Item "uninstall-linux.sh" $linuxDir  
Copy-Item "configure-linux.sh" $linuxDir
Copy-Item "make-executable.sh" $linuxDir
Copy-Item "tacticalagent.service" $linuxDir
Copy-Item "README-Linux.md" "$linuxDir\README.md"

# Create Windows package
Write-Host "Creating Windows package..." -ForegroundColor Yellow
$windowsDir = "tactical-rmm-agent-windows"
if (Test-Path $windowsDir) { Remove-Item $windowsDir -Recurse -Force }
New-Item -ItemType Directory -Name $windowsDir | Out-Null

Copy-Item "tacticalrmm-windows-*.exe" $windowsDir

# Create macOS package  
Write-Host "Creating macOS package..." -ForegroundColor Yellow
$macosDir = "tactical-rmm-agent-macos"
if (Test-Path $macosDir) { Remove-Item $macosDir -Recurse -Force }
New-Item -ItemType Directory -Name $macosDir | Out-Null

Copy-Item "tacticalrmm-macos-*" $macosDir

Write-Host ""
Write-Host "Packages created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Linux package: $linuxDir\" -ForegroundColor Cyan
Write-Host "Windows package: $windowsDir\" -ForegroundColor Cyan
Write-Host "macOS package: $macosDir\" -ForegroundColor Cyan
Write-Host ""
Write-Host "For Linux installation:" -ForegroundColor White
Write-Host "1. Copy the $linuxDir folder to your Linux server" -ForegroundColor Gray
Write-Host "2. Run: chmod +x *.sh" -ForegroundColor Gray
Write-Host "3. Run: sudo ./install-linux.sh" -ForegroundColor Gray
Write-Host "4. Run: sudo ./configure-linux.sh --configure" -ForegroundColor Gray
Write-Host "5. Run: sudo ./configure-linux.sh --start" -ForegroundColor Gray

Set-Location ..