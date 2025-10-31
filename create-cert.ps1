# Create Self-Signed Certificate for ITH Medical Code Signing
# This creates a test certificate for development/testing purposes

Write-Host "Creating ITH Medical Code Signing Certificate" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Certificate details
$certSubject = "CN=ITH Medical, O=ITH Medical, C=FR"
$certFriendlyName = "ITH Medical Code Signing Certificate"
$certPath = "ith-medical-cert.p12"
$certPassword = "ITHMedical2025!"

Write-Host "Certificate Subject: $certSubject" -ForegroundColor Cyan
Write-Host "Certificate File: $certPath" -ForegroundColor Cyan
Write-Host "Certificate Password: $certPassword" -ForegroundColor Cyan
Write-Host ""

try {
    # Create the certificate
    Write-Host "Creating self-signed certificate..." -ForegroundColor Yellow
    $cert = New-SelfSignedCertificate -Subject $certSubject -Type CodeSigning -CertStoreLocation Cert:\CurrentUser\My -FriendlyName $certFriendlyName -NotAfter (Get-Date).AddYears(5)
    
    Write-Host "✓ Certificate created with thumbprint: $($cert.Thumbprint)" -ForegroundColor Green
    
    # Export to PFX file
    Write-Host "Exporting certificate to PFX file..." -ForegroundColor Yellow
    $securePwd = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $securePwd | Out-Null
    
    Write-Host "✓ Certificate exported to: $certPath" -ForegroundColor Green
    
    # Install to Trusted Root (for testing)
    Write-Host "Installing certificate to Trusted Root store..." -ForegroundColor Yellow
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "CurrentUser")
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()
    
    Write-Host "✓ Certificate installed to Trusted Root store" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Certificate creation completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To sign your binaries, use:" -ForegroundColor Cyan
    Write-Host ".\sign-code.ps1 -CertificatePath '$certPath' -CertificatePassword '$certPassword'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⚠ Note: This is a self-signed certificate for testing only." -ForegroundColor Yellow
    Write-Host "  For production, use a certificate from a trusted CA." -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ Error creating certificate: $_" -ForegroundColor Red
    exit 1
}