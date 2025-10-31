# ITH RMM Agent Code Signing Script
# This script signs the compiled binaries with a code signing certificate

param(
    [string]$CertificatePath = "",
    [string]$CertificatePassword = "",
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

Write-Host "ITH RMM Agent Code Signing Process" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if signtool is available
$signTool = Get-Command "signtool.exe" -ErrorAction SilentlyContinue
if (-not $signTool) {
    Write-Host "Error: signtool.exe not found. Please install Windows SDK." -ForegroundColor Red
    Write-Host "Download from: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/" -ForegroundColor Yellow
    exit 1
}

# Check parameters
if ([string]::IsNullOrEmpty($CertificatePath)) {
    Write-Host "Usage: .\sign-code.ps1 -CertificatePath 'path\to\cert.p12' -CertificatePassword 'password'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example with self-signed certificate:" -ForegroundColor Cyan
    Write-Host ".\sign-code.ps1 -CertificatePath 'ith-medical-cert.p12' -CertificatePassword 'mypassword'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To create a self-signed certificate for testing:" -ForegroundColor Yellow
    Write-Host "New-SelfSignedCertificate -DnsName 'ITH Medical' -Type CodeSigning -CertStoreLocation Cert:\CurrentUser\My" -ForegroundColor Gray
    exit 1
}

# Verify certificate exists
if (-not (Test-Path $CertificatePath)) {
    Write-Host "Error: Certificate file not found: $CertificatePath" -ForegroundColor Red
    exit 1
}

# Files to sign
$filesToSign = @(
    "builds\ithrmm-windows-amd64.exe",
    "builds\ithrmm-windows-386.exe"
)

Write-Host "Certificate: $CertificatePath" -ForegroundColor Cyan
Write-Host "Timestamp Server: $TimestampServer" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $filesToSign) {
    if (Test-Path $file) {
        Write-Host "Signing: $file" -ForegroundColor Yellow
        
        $arguments = @(
            "sign",
            "/f", "`"$CertificatePath`"",
            "/p", "`"$CertificatePassword`"",
            "/t", "`"$TimestampServer`"",
            "/fd", "SHA256",
            "/v",
            "`"$file`""
        )
        
        try {
            & signtool.exe $arguments
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully signed: $file" -ForegroundColor Green
            } else {
                Write-Host "✗ Failed to sign: $file (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "✗ Error signing $file : $_" -ForegroundColor Red
        }
        
        Write-Host ""
    } else {
        Write-Host "⚠ File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "Code signing process completed!" -ForegroundColor Green
Write-Host ""
Write-Host "To verify signatures:" -ForegroundColor Cyan
Write-Host "signtool verify /v /pa `"path\to\signed.exe`"" -ForegroundColor Gray