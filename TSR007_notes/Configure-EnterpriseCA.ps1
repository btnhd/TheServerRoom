# Determine where to do the logging 
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$logPath = $tsenv.Value("LogPath") 
$logFile = "$logPath\$($myInvocation.MyCommand).log" 

# Start the logging 
Start-Transcript $logFile 
Write-Host "Logging to $logFile" 

# Configure Enterprise CA
Install-AdcsCertificationAuthority `    –CAType EnterpriseRootCA `    –CACommonName "BTNHD" `    –KeyLength 2048 `    –HashAlgorithm SHA1 `    –CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `    -ValidityPeriod Years `    -ValidityPeriodUnits 5 `
    -Force

# Stop logging 
Stop-Transcript

