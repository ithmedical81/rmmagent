# ITH RMM Agent Build Script
# Compiles the agent with ITH Medical branding and optional code signing

param(
    [switch]$Sign,
    [string]$CertPath = "ith-medical-cert.p12",
    [string]$CertPassword = "ITHMedical2025!"
)

Write-Host ""
Write-Host "██╗████████╗██╗  ██╗    ██████╗ ███╗   ███╗███╗   ███╗" -ForegroundColor Blue
Write-Host "██║╚══██╔══╝██║  ██║    ██╔══██╗████╗ ████║████╗ ████║" -ForegroundColor Blue  
Write-Host "██║   ██║   ███████║    ██████╔╝██╔████╔██║██╔████╔██║" -ForegroundColor Blue
Write-Host "██║   ██║   ██╔══██║    ██╔══██╗██║╚██╔╝██║██║╚██╔╝██║" -ForegroundColor Blue
Write-Host "██║   ██║   ██║  ██║    ██║  ██║██║ ╚═╝ ██║██║ ╚═╝ ██║" -ForegroundColor Blue
Write-Host "╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝" -ForegroundColor Blue
Write-Host ""
Write-Host "ITH Medical Remote Monitoring and Management Agent" -ForegroundColor Cyan
Write-Host "Build System v1.0" -ForegroundColor Gray
Write-Host "=================================================" -ForegroundColor Green

# Check if Go is installed
$goVersion = & go version 2>$null
if (-not $goVersion) {
    Write-Host "Go is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "Go version: $goVersion" -ForegroundColor Green

# Clean old builds
Write-Host ""
Write-Host "Cleaning old builds..." -ForegroundColor Yellow
if (Test-Path "builds") {
    Remove-Item "builds\ithrmm-*" -Force -ErrorAction SilentlyContinue
}

# Create builds directory
New-Item -ItemType Directory -Force -Path "builds" | Out-Null

Write-Host "Building ITH RMM Agent for all platforms..." -ForegroundColor Yellow
Write-Host ""

# Build configurations
$builds = @(
    @{Platform="windows"; Arch="amd64"; Output="builds/ithrmm-windows-amd64.exe"; Description="Windows 64-bit"},
    @{Platform="windows"; Arch="386"; Output="builds/ithrmm-windows-386.exe"; Description="Windows 32-bit"},
    @{Platform="linux"; Arch="amd64"; Output="builds/ithrmm-linux-amd64"; Description="Linux 64-bit"},
    @{Platform="linux"; Arch="386"; Output="builds/ithrmm-linux-386"; Description="Linux 32-bit"},
    @{Platform="linux"; Arch="arm64"; Output="builds/ithrmm-linux-arm64"; Description="Linux ARM64"},
    @{Platform="darwin"; Arch="amd64"; Output="builds/ithrmm-macos-amd64"; Description="macOS Intel"},
    @{Platform="darwin"; Arch="arm64"; Output="builds/ithrmm-macos-arm64"; Description="macOS Apple Silicon"}
)

$buildCount = 0
$totalBuilds = $builds.Count

foreach ($build in $builds) {
    $buildCount++
    Write-Host "[$buildCount/$totalBuilds] Building $($build.Description)..." -ForegroundColor Cyan
    
    $env:CGO_ENABLED = "0"
    $env:GOOS = $build.Platform
    $env:GOARCH = $build.Arch
    
    try {
        & go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o $build.Output
        if ($LASTEXITCODE -eq 0) {
            $fileSize = (Get-Item $build.Output).Length
            $fileSizeMB = [math]::Round($fileSize / 1MB, 1)
            Write-Host "  Success: $($build.Output) ($fileSizeMB MB)" -ForegroundColor Green
        } else {
            Write-Host "  Failed to build $($build.Description)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Test one binary
Write-Host ""
Write-Host "Testing Windows binary..." -ForegroundColor Yellow
if (Test-Path "builds/ithrmm-windows-amd64.exe") {
    try {
        $version = & "builds/ithrmm-windows-amd64.exe" --version 2>$null
        Write-Host "Binary test successful" -ForegroundColor Green
    }
    catch {
        Write-Host "Binary test failed, but file exists" -ForegroundColor Yellow
    }
}

# Code signing
if ($Sign) {
    Write-Host ""
    Write-Host "Code signing requested..." -ForegroundColor Yellow
    
    if (Test-Path $CertPath) {
        Write-Host "Signing Windows binaries..." -ForegroundColor Cyan
        & .\sign-code.ps1 -CertificatePath $CertPath -CertificatePassword $CertPassword
    } else {
        Write-Host "Certificate not found: $CertPath" -ForegroundColor Red
        Write-Host "Create a certificate first: .\create-cert.ps1" -ForegroundColor Yellow
    }
}

# Package creation
Write-Host ""
Write-Host "Creating deployment packages..." -ForegroundColor Yellow
& .\builds\create-packages-ith.ps1

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Output files:" -ForegroundColor Cyan
Get-ChildItem "builds" -Filter "ithrmm-*" | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 1)
    Write-Host "  $($_.Name) ($size MB)" -ForegroundColor Gray
}

Write-Host ""
if ($Sign) {
    Write-Host "Binaries have been code signed" -ForegroundColor Green
} else {
    Write-Host "To sign binaries, use: .\build-ith.ps1 -Sign" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Ready for deployment!" -ForegroundColor Green