# Create ITH RMM deployment packages
# PowerShell script to organize ITH branded files

Write-Host "Creating ITH RMM Agent deployment packages..." -ForegroundColor Green

# Change to builds directory
if (-not (Test-Path "builds")) {
    Write-Host "Error: builds directory not found" -ForegroundColor Red
    exit 1
}

Set-Location builds

# Update Linux scripts for ITH branding
Write-Host "Updating Linux scripts for ITH branding..." -ForegroundColor Yellow

# Create ITH-branded Linux installation script
$ithLinuxInstall = Get-Content "install-linux.sh" -Raw
$ithLinuxInstall = $ithLinuxInstall -replace "TacticalRMM", "ITH RMM"
$ithLinuxInstall = $ithLinuxInstall -replace "tacticalagent", "ithagent"
$ithLinuxInstall = $ithLinuxInstall -replace "tacticalrmm-linux", "ithrmm-linux"
$ithLinuxInstall = $ithLinuxInstall -replace "Tactical RMM", "ITH RMM"
$ithLinuxInstall | Set-Content "install-ith-linux.sh"

# Create ITH Linux package
Write-Host "Creating ITH Linux package..." -ForegroundColor Yellow
$linuxDir = "ith-rmm-agent-linux"
if (Test-Path $linuxDir) { Remove-Item $linuxDir -Recurse -Force }
New-Item -ItemType Directory -Name $linuxDir | Out-Null

Copy-Item "ithrmm-linux-*" $linuxDir -ErrorAction SilentlyContinue
Copy-Item "install-ith-linux.sh" "$linuxDir/install.sh"
Copy-Item "make-executable.sh" $linuxDir -ErrorAction SilentlyContinue

# Create ITH service file
@"
[Unit]
Description=ITH RMM Agent Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/ithagent/ithagent -m svc
WorkingDirectory=/opt/ithagent
User=root
Group=root
Restart=always
RestartSec=5
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30
StandardOutput=journal
StandardError=journal
SyslogIdentifier=ithagent

# Security settings
NoNewPrivileges=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
MemoryDenyWriteExecute=false
SystemCallArchitectures=native

[Install]
WantedBy=multi-user.target
"@ | Set-Content "$linuxDir/ithagent.service"

# Create ITH README
@"
# ITH RMM Agent for Linux

This package contains the ITH RMM Agent binaries and installation scripts for Linux systems.

## Quick Installation

1. Make scripts executable: `chmod +x *.sh`
2. Run installation: `sudo ./install.sh`
3. Configure agent with your ITH RMM server details
4. Start service: `sudo systemctl start ithagent`

## Package Contents

- `ithrmm-linux-amd64` - Agent for 64-bit systems
- `ithrmm-linux-386` - Agent for 32-bit systems  
- `ithrmm-linux-arm64` - Agent for ARM64 systems
- `install.sh` - Installation script
- `ithagent.service` - SystemD service file

## ITH Medical
Copyright © 2025 ITH Medical. All rights reserved.
Based on Tactical RMM Agent (AmidaWare Inc.)
"@ | Set-Content "$linuxDir/README.md"

# Create Windows package
Write-Host "Creating ITH Windows package..." -ForegroundColor Yellow
$windowsDir = "ith-rmm-agent-windows"
if (Test-Path $windowsDir) { Remove-Item $windowsDir -Recurse -Force }
New-Item -ItemType Directory -Name $windowsDir | Out-Null

Copy-Item "ithrmm-windows-*.exe" $windowsDir -ErrorAction SilentlyContinue

# Create Windows README
@"
# ITH RMM Agent for Windows

## Installation

1. Run the appropriate executable for your system:
   - `ithrmm-windows-amd64.exe` for 64-bit Windows
   - `ithrmm-windows-386.exe` for 32-bit Windows

2. Use command line parameters to configure:
   ```
   ithrmm-windows-amd64.exe -m install -api <API_URL> -client-id <ID> -site-id <ID> -auth <TOKEN>
   ```

## ITH Medical
Copyright © 2025 ITH Medical. All rights reserved.
Based on Tactical RMM Agent (AmidaWare Inc.)
"@ | Set-Content "$windowsDir/README.md"

# Create macOS package
Write-Host "Creating ITH macOS package..." -ForegroundColor Yellow
$macosDir = "ith-rmm-agent-macos"
if (Test-Path $macosDir) { Remove-Item $macosDir -Recurse -Force }
New-Item -ItemType Directory -Name $macosDir | Out-Null

Copy-Item "ithrmm-macos-*" $macosDir -ErrorAction SilentlyContinue

# Create macOS README
@"
# ITH RMM Agent for macOS

## Installation

1. Choose the appropriate binary:
   - `ithrmm-macos-amd64` for Intel Macs
   - `ithrmm-macos-arm64` for Apple Silicon Macs (M1/M2)

2. Make executable: `chmod +x ithrmm-macos-*`

3. Configure and install:
   ```
   sudo ./ithrmm-macos-amd64 -m install -api <API_URL> -client-id <ID> -site-id <ID> -auth <TOKEN>
   ```

## ITH Medical
Copyright © 2025 ITH Medical. All rights reserved.
Based on Tactical RMM Agent (AmidaWare Inc.)
"@ | Set-Content "$macosDir/README.md"

Write-Host ""
Write-Host "ITH RMM packages created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Linux package: $linuxDir\" -ForegroundColor Cyan
Write-Host "Windows package: $windowsDir\" -ForegroundColor Cyan  
Write-Host "macOS package: $macosDir\" -ForegroundColor Cyan

Set-Location ..