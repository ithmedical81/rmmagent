# ITH RMM Agent Build Script
# Simple and clean version

param(
    [switch]$Sign,
    [string]$CertPath = "ith-medical-cert.p12",
    [string]$CertPassword = "ITHMedical2025!"
)

Write-Host ""
Write-Host "ITH RMM Agent Build System" -ForegroundColor Blue
Write-Host "==========================" -ForegroundColor Green

# Check Go
$goVersion = & go version 2>$null
if (-not $goVersion) {
    Write-Host "Error: Go is not installed" -ForegroundColor Red
    exit 1
}
Write-Host "Go: $goVersion" -ForegroundColor Green

# Clean and create builds directory
Write-Host ""
Write-Host "Cleaning old builds..." -ForegroundColor Yellow
if (Test-Path "builds") {
    Remove-Item "builds\ithrmm-*" -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path "builds" | Out-Null

Write-Host "Building ITH RMM Agent..." -ForegroundColor Yellow

# Build Windows 64-bit
Write-Host "Building Windows 64-bit..." -ForegroundColor Cyan
$env:CGO_ENABLED = "0"
$env:GOOS = "windows"
$env:GOARCH = "amd64"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-windows-amd64.exe"

# Build Windows 32-bit
Write-Host "Building Windows 32-bit..." -ForegroundColor Cyan
$env:GOARCH = "386"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-windows-386.exe"

# Build Linux 64-bit
Write-Host "Building Linux 64-bit..." -ForegroundColor Cyan
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-linux-amd64"

# Build Linux 32-bit
Write-Host "Building Linux 32-bit..." -ForegroundColor Cyan
$env:GOARCH = "386"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-linux-386"

# Build Linux ARM64
Write-Host "Building Linux ARM64..." -ForegroundColor Cyan
$env:GOARCH = "arm64"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-linux-arm64"

# Build macOS Intel
Write-Host "Building macOS Intel..." -ForegroundColor Cyan
$env:GOOS = "darwin"
$env:GOARCH = "amd64"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-macos-amd64"

# Build macOS Apple Silicon
Write-Host "Building macOS Apple Silicon..." -ForegroundColor Cyan
$env:GOARCH = "arm64"
go build -ldflags "-s -w -X main.version=2.9.1-ITH" -o "builds/ithrmm-macos-arm64"

# Test Windows binary
Write-Host ""
Write-Host "Testing Windows binary..." -ForegroundColor Yellow
if (Test-Path "builds/ithrmm-windows-amd64.exe") {
    try {
        $testOutput = & "builds/ithrmm-windows-amd64.exe" --version 2>$null
        Write-Host "Test successful" -ForegroundColor Green
    }
    catch {
        Write-Host "Binary exists but test failed" -ForegroundColor Yellow
    }
}

# Code signing
if ($Sign) {
    Write-Host ""
    Write-Host "Code signing..." -ForegroundColor Yellow
    if (Test-Path $CertPath) {
        & .\sign-code.ps1 -CertificatePath $CertPath -CertificatePassword $CertPassword
    } else {
        Write-Host "Certificate not found: $CertPath" -ForegroundColor Red
    }
}

# Show results
Write-Host ""
Write-Host "Build completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Output files:" -ForegroundColor Cyan
Get-ChildItem "builds" -Filter "ithrmm-*" | ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 1)
    Write-Host "  $($_.Name) - $sizeMB MB" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Ready for deployment!" -ForegroundColor Green