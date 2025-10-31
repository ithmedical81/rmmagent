# ITH RMM Agent - Simple Service Installation
# This script installs the ITH RMM agent as a Windows service for testing

Write-Host ""
Write-Host "ITH RMM Agent - Service Installation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Check admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERROR: Administrator rights required!" -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

$agentPath = ".\ithrmm-windows-amd64.exe"

if (-not (Test-Path $agentPath)) {
    Write-Host "ERROR: Agent binary not found: $agentPath" -ForegroundColor Red
    exit 1
}

Write-Host "Agent binary: $agentPath" -ForegroundColor Cyan

# Copy agent to Program Files
$installDir = "C:\Program Files\ITH RMM Agent"
$agentExe = "$installDir\ithrmm.exe"

Write-Host ""
Write-Host "Creating installation directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Copying agent binary..." -ForegroundColor Yellow
Copy-Item $agentPath $agentExe -Force

Write-Host "Setting permissions..." -ForegroundColor Yellow
icacls $installDir /grant "Everyone:(OI)(CI)F" /T | Out-Null

# Create a basic configuration file for testing
$configPath = "C:\ProgramData\ITH RMM\agent.conf"
$configDir = Split-Path $configPath
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$config = @{
    "agent_id" = [System.Guid]::NewGuid().ToString()
    "api_url" = "https://not-configured.ith-medical.com"
    "description" = "ITH RMM Test Agent - $(hostname)"
    "agent_type" = "server"
    "version" = "2.9.1-ITH"
}

$config | ConvertTo-Json | Set-Content $configPath

Write-Host "Configuration created: $configPath" -ForegroundColor Green

# Install service using sc.exe
Write-Host ""
Write-Host "Installing Windows service..." -ForegroundColor Yellow

$serviceName = "ithrmm"
$serviceDisplayName = "ITH RMM Agent Service"
$serviceDescription = "ITH Medical Remote Monitoring and Management Agent"

# Remove existing service if present
$existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Removing existing service..." -ForegroundColor Yellow
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    & sc.exe delete $serviceName
    Start-Sleep 2
}

# Create service
$createResult = & sc.exe create $serviceName binPath= "`"$agentExe`" -m svc" DisplayName= $serviceDisplayName start= auto
if ($LASTEXITCODE -eq 0) {
    Write-Host "Service created successfully!" -ForegroundColor Green
    
    # Set service description
    & sc.exe description $serviceName $serviceDescription | Out-Null
    
    # Set service to restart on failure
    & sc.exe failure $serviceName reset= 86400 actions= restart/5000/restart/5000/restart/5000 | Out-Null
    
    Write-Host "Starting service..." -ForegroundColor Yellow
    $startResult = Start-Service -Name $serviceName -PassThru
    
    if ($startResult.Status -eq "Running") {
        Write-Host "Service started successfully!" -ForegroundColor Green
    } else {
        Write-Host "Service installed but failed to start." -ForegroundColor Yellow
        Write-Host "This is normal without a valid RMM server connection." -ForegroundColor Cyan
    }
} else {
    Write-Host "Failed to create service. Error code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

# Show final status
Write-Host ""
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Service Details:" -ForegroundColor Cyan
try {
    $service = Get-Service -Name $serviceName
    Write-Host "  Name: $($service.Name)" -ForegroundColor White
    Write-Host "  Display Name: $($service.DisplayName)" -ForegroundColor White
    Write-Host "  Status: $($service.Status)" -ForegroundColor White
} catch {
    Write-Host "  Error retrieving service status" -ForegroundColor Red
}

Write-Host ""
Write-Host "Files installed:" -ForegroundColor Cyan
Write-Host "  Agent: $agentExe" -ForegroundColor White
Write-Host "  Config: $configPath" -ForegroundColor White

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure the agent with your RMM server details" -ForegroundColor White
Write-Host "2. Test status: .\ithrmm-windows-amd64.exe -m status" -ForegroundColor White
Write-Host "3. View service: Get-Service ithrmm" -ForegroundColor White

Write-Host ""
Write-Host "ITH RMM Agent is now installed as a Windows service!" -ForegroundColor Green