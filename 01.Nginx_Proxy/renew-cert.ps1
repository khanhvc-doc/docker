
# ============================================================
# Let's Encrypt Certificate Auto Renew
# Windows + Docker Desktop + Certbot Container + Nginx Docker
#
# Logic:
#   - Chạy mỗi ngày bằng Task Scheduler
#   - Chỉ renew certificate khi còn <= 5 ngày
#   - Chỉ reload Nginx nếu có ít nhất 1 cert renew thành công
# ============================================================

$ErrorActionPreference = "Continue"

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

$ProjectPath = "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy"

$CertbotWww  = Join-Path $ProjectPath "certbot\www"
$CertbotConf = Join-Path $ProjectPath "certbot\conf"

$NginxContainer = "nginx-proxy-v2"

# Renew khi còn <= số ngày này
$RenewThresholdDays = 5

# Các certificate do script quản lý
# pit2 không cần thêm riêng vì đang nằm trong SAN của cert pit3
$ManagedCerts = @(
    "pit3.hansollvina.com",
    "sims3.hansollvina.com",
    "subcon3.hansollvina.com"
)

# Log
$LogFile = Join-Path $ProjectPath "logs\cert-renew.log"


# ------------------------------------------------------------
# FUNCTION: WRITE LOG
# ------------------------------------------------------------

function Write-Log {
    param(
        [string]$Message
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "[$TimeStamp] $Message"

    Write-Host $Line
    Add-Content -Path $LogFile -Value $Line
}


# ------------------------------------------------------------
# START
# ------------------------------------------------------------

Write-Log "============================================================"
Write-Log "Starting certificate renewal check."
Write-Log "Renew threshold: <= $RenewThresholdDays days"


# ------------------------------------------------------------
# CHECK DOCKER
# ------------------------------------------------------------

$null = docker info 2>&1
$DockerInfoExitCode = $LASTEXITCODE

if ($DockerInfoExitCode -ne 0) {
    Write-Log "ERROR: Docker Desktop is not running or Docker is unavailable."
    exit 1
}

Write-Log "Docker is running."


# ------------------------------------------------------------
# CHECK NGINX CONTAINER EXISTS
# ------------------------------------------------------------

$ContainerName = docker ps `
    --filter "name=^/${NginxContainer}$" `
    --format "{{.Names}}" 2>$null

if ($ContainerName -ne $NginxContainer) {
    Write-Log "ERROR: Nginx container '$NginxContainer' is not running."
    exit 1
}

Write-Log "Nginx container '$NginxContainer' is running."


# ------------------------------------------------------------
# GET CERTBOT CERTIFICATE INFORMATION
# ------------------------------------------------------------

Write-Log "Reading certificates from Certbot..."

$CertOutput = & docker run --rm `
    -v "${CertbotConf}:/etc/letsencrypt" `
    certbot/certbot certificates 2>&1

$CertListExitCode = $LASTEXITCODE

if ($CertListExitCode -ne 0) {

    Write-Log "ERROR: Unable to read certificate information."

    foreach ($Line in $CertOutput) {
        Write-Log "CERTBOT: $Line"
    }

    exit 1
}


# ------------------------------------------------------------
# PARSE CERTIFICATE NAME + EXPIRY DATE
# ------------------------------------------------------------

$Certificates = @()
$CurrentName = $null

foreach ($Line in $CertOutput) {

    $TextLine = $Line.ToString()

    if ($TextLine -match "Certificate Name:\s*(.+)$") {

        $CurrentName = $Matches[1].Trim()
        continue
    }

    if (
        $CurrentName -and
        $TextLine -match "Expiry Date:\s*(.+?)\s+\("
    ) {

        try {

            $ExpiryText = $Matches[1].Trim()

            $Expiry = [DateTimeOffset]::Parse(
                $ExpiryText,
                [System.Globalization.CultureInfo]::InvariantCulture
            )

            $Certificates += [PSCustomObject]@{
                Name   = $CurrentName
                Expiry = $Expiry
            }

        }
        catch {

            Write-Log "WARNING: Cannot parse expiry date for certificate: $CurrentName"
        }

        $CurrentName = $null
    }
}


if ($Certificates.Count -eq 0) {
    Write-Log "ERROR: No certificates were parsed from Certbot output."
    exit 1
}


# ------------------------------------------------------------
# SHOW CERTIFICATES FOUND
# ------------------------------------------------------------

Write-Log "Certificates found:"

foreach ($Cert in $Certificates) {

    $Remaining = $Cert.Expiry - [DateTimeOffset]::UtcNow
    $DaysLeft  = [Math]::Ceiling($Remaining.TotalDays)

    Write-Log "  $($Cert.Name) | Expiry: $($Cert.Expiry.ToString('yyyy-MM-dd HH:mm:ss zzz')) | Days left: $DaysLeft"
}


# ------------------------------------------------------------
# CHECK EACH MANAGED CERTIFICATE
# ------------------------------------------------------------

$AnyRenewed = $false
$RenewFailed = $false

foreach ($CertName in $ManagedCerts) {

    Write-Log "------------------------------------------------------------"
    Write-Log "Checking certificate: $CertName"

    $Cert = $Certificates |
        Where-Object { $_.Name -eq $CertName } |
        Select-Object -First 1

    if (-not $Cert) {

        Write-Log "WARNING: Certificate not found: $CertName"
        continue
    }


    # --------------------------------------------------------
    # CALCULATE DAYS LEFT
    # --------------------------------------------------------

    $Remaining = $Cert.Expiry - [DateTimeOffset]::UtcNow

    $DaysLeft = [Math]::Ceiling($Remaining.TotalDays)

    Write-Log "Expiry    : $($Cert.Expiry.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
    Write-Log "Days left : $DaysLeft"


    # --------------------------------------------------------
    # CERTIFICATE ALREADY EXPIRED
    # --------------------------------------------------------

    if ($Remaining.TotalSeconds -le 0) {

        Write-Log "WARNING: Certificate is already expired."
    }


    # --------------------------------------------------------
    # CERT STILL SAFE
    # --------------------------------------------------------

    if ($DaysLeft -gt $RenewThresholdDays) {

        Write-Log "SKIP: More than $RenewThresholdDays days remaining."
        continue
    }


    # --------------------------------------------------------
    # RENEW CERTIFICATE
    # --------------------------------------------------------

    Write-Log "RENEW: Certificate has <= $RenewThresholdDays days remaining."
    Write-Log "Starting Certbot renewal for $CertName..."


    $RenewOutput = & docker run --rm `
        -v "${CertbotWww}:/var/www/certbot" `
        -v "${CertbotConf}:/etc/letsencrypt" `
        certbot/certbot renew `
        --cert-name $CertName `
        --force-renewal 2>&1


    $RenewExitCode = $LASTEXITCODE


    foreach ($RenewLine in $RenewOutput) {

        Write-Log "CERTBOT: $RenewLine"
    }


    if ($RenewExitCode -eq 0) {

        Write-Log "SUCCESS: Certificate renewed: $CertName"

        $AnyRenewed = $true
    }
    else {

        Write-Log "ERROR: Certificate renewal failed: $CertName"

        $RenewFailed = $true
    }
}


# ------------------------------------------------------------
# RELOAD NGINX ONLY WHEN CERTIFICATE WAS RENEWED
# ------------------------------------------------------------

Write-Log "------------------------------------------------------------"

if ($AnyRenewed) {

    Write-Log "At least one certificate was renewed."
    Write-Log "Testing Nginx configuration..."


    $NginxTestOutput = & docker exec `
        $NginxContainer `
        nginx -t 2>&1

    $NginxTestExitCode = $LASTEXITCODE


    foreach ($Line in $NginxTestOutput) {

        Write-Log "NGINX: $Line"
    }


    if ($NginxTestExitCode -ne 0) {

        Write-Log "ERROR: nginx -t failed."
        Write-Log "Nginx WILL NOT be reloaded."

        exit 1
    }


    Write-Log "Nginx configuration OK."
    Write-Log "Reloading Nginx..."


    $NginxReloadOutput = & docker exec `
        $NginxContainer `
        nginx -s reload 2>&1

    $NginxReloadExitCode = $LASTEXITCODE


    foreach ($Line in $NginxReloadOutput) {

        Write-Log "NGINX: $Line"
    }


    if ($NginxReloadExitCode -eq 0) {

        Write-Log "SUCCESS: Nginx reloaded successfully."
    }
    else {

        Write-Log "ERROR: Failed to reload Nginx."

        exit 1
    }
}
else {

    Write-Log "No certificate requires renewal."
    Write-Log "Nginx reload is not required."
}


# ------------------------------------------------------------
# FINAL STATUS
# ------------------------------------------------------------

if ($RenewFailed) {

    Write-Log "WARNING: One or more certificate renewals failed."
    Write-Log "Certificate renewal check completed with warnings."
    Write-Log "============================================================"

    exit 2
}


Write-Log "Certificate renewal check completed successfully."
Write-Log "============================================================"

exit 0
```
