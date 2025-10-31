# ITH RMM Agent Installation Test Script
# This script demonstrates how to install the ITH RMM agent

Write-Host ""
Write-Host "ITH RMM Agent Installation Demo" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "WARNING: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Cyan
    pause
    exit 1
}

Write-Host "✓ Running as Administrator" -ForegroundColor Green

# Installation parameters for testing (you'll need real values from your RMM server)
Write-Host ""
Write-Host "Installation Parameters:" -ForegroundColor Cyan
Write-Host "Note: These are example values - you need real credentials from your RMM server!" -ForegroundColor Yellow
Write-Host ""

$agentPath = ".\ithrmm-windows-amd64.exe"
$apiUrl = "https://your-rmm-server.com/api"  # Replace with your actual RMM server
$clientId = 1                                # Replace with your client ID  
$siteId = 1                                  # Replace with your site ID
$authToken = "your-auth-token-here"          # Replace with your auth token
$description = "ITH RMM Test Agent - $(hostname)"

Write-Host "Agent Binary: $agentPath" -ForegroundColor Gray
Write-Host "API URL: $apiUrl" -ForegroundColor Gray  
Write-Host "Client ID: $clientId" -ForegroundColor Gray
Write-Host "Site ID: $siteId" -ForegroundColor Gray
Write-Host "Description: $description" -ForegroundColor Gray

Write-Host ""
Write-Host "Available installation modes:" -ForegroundColor Cyan
Write-Host "1. Install service only (for testing)" -ForegroundColor White
Write-Host "2. Full installation (requires RMM server)" -ForegroundColor White
Write-Host "3. Show current status" -ForegroundColor White
Write-Host "4. Uninstall agent" -ForegroundColor White

Write-Host ""
$choice = Read-Host "Select option (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Installing ITH RMM Agent service for testing..." -ForegroundColor Yellow
        Write-Host "Note: This will install the service but it won't connect without proper credentials" -ForegroundColor Yellow
        
        # Install service only
        Write-Host "Installing service..." -ForegroundColor Cyan
        & $agentPath -m installsvc
        
        Write-Host "Starting service..." -ForegroundColor Cyan
        Start-Service -Name "ithrmm" -ErrorAction SilentlyContinue
        
        Write-Host ""
        Write-Host "Service installation completed!" -ForegroundColor Green
        Write-Host "Check status with: Get-Service ithrmm" -ForegroundColor Cyan
    }
    
    "2" {
        Write-Host ""
        Write-Host "Full ITH RMM Agent Installation" -ForegroundColor Yellow
        Write-Host "You need to provide real credentials from your RMM server!" -ForegroundColor Red
        Write-Host ""
        
        $realApiUrl = Read-Host "Enter API URL (e.g., https://rmm.yourdomain.com)"
        $realClientId = Read-Host "Enter Client ID"
        $realSiteId = Read-Host "Enter Site ID" 
        $realToken = Read-Host "Enter Auth Token" -AsSecureString
        $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($realToken))
        
        Write-Host ""
        Write-Host "Installing with real credentials..." -ForegroundColor Cyan
        
        $installArgs = @(
            "-m", "install",
            "-api", $realApiUrl,
            "-client-id", $realClientId,
            "-site-id", $realSiteId,
            "-auth", $tokenPlain,
            "-desc", $description,
            "-agent-type", "server"
        )
        
        & $agentPath $installArgs
    }
    
    "3" {
        Write-Host ""
        Write-Host "ITH RMM Agent Status:" -ForegroundColor Cyan
        
        # Show version
        Write-Host ""
        Write-Host "Version Information:" -ForegroundColor Yellow
        & $agentPath --version
        
        # Show service status
        Write-Host ""
        Write-Host "Service Status:" -ForegroundColor Yellow
        try {
            $service = Get-Service -Name "ithrmm" -ErrorAction Stop
            Write-Host "Service Name: $($service.Name)" -ForegroundColor Green
            Write-Host "Display Name: $($service.DisplayName)" -ForegroundColor Green  
            Write-Host "Status: $($service.Status)" -ForegroundColor Green
        }
        catch {
            Write-Host "Service not installed" -ForegroundColor Red
        }
        
        # Show status dialog
        Write-Host ""
        Write-Host "Opening status dialog..." -ForegroundColor Cyan
        & $agentPath -m status
    }
    
    "4" {
        Write-Host ""
        Write-Host "Uninstalling ITH RMM Agent..." -ForegroundColor Yellow
        
        # Stop service
        try {
            Stop-Service -Name "ithrmm" -Force -ErrorAction SilentlyContinue
            Write-Host "Service stopped" -ForegroundColor Green
        }
        catch {
            Write-Host "Service was not running" -ForegroundColor Yellow
        }
        
        # Remove service
        & $agentPath -m removesvc
        Write-Host "Service removed" -ForegroundColor Green
    }
    
    default {
        Write-Host "Invalid selection" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green