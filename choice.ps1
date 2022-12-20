####################
# Prerequisite check
####################
if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Administrator priviliges are required. Please restart this script with elevated rights." -ForegroundColor Red
    Pause
    Throw "Administrator priviliges are required. Please restart this script with elevated rights."
	}
#OpenSSL needs to be in your windows path.
#This is a block for asking user input
 $genCSRcertq = New-Object System.Management.Automation.Host.ChoiceDescription '&1 Generate CSR with certreq ', 'Generate CSR with certreq'
 $genCSRopenssl = New-Object System.Management.Automation.Host.ChoiceDescription '&2 Generate CSR with openssl ', 'Generate CSR with certreq'
 $exportPKCS12 = New-Object System.Management.Automation.Host.ChoiceDescription '&3 Export PKCS12', 'Export PKCS12'
 $options = [System.Management.Automation.Host.ChoiceDescription[]]($genCSRcertq,$genCSRopenssl,$exportPKCS12)
 $title = 'Swedbank'
 $message = "Tarvi Tihhanov home work"
 $result = $host.ui.PromptForChoice($title, $message, $options, 0)
 if ($result -eq 0) {
     $choice = "Generate CSR with certreq"
$request = @{}
Write-Host "Provide the Subject details required for the Certificate Signing Request" -ForegroundColor Yellow
$commonName = Read-Host -Prompt "Provide the domain or name you're generating a certificate for [www.swedbank.ee or Your Name]"
$org = Read-Host -Prompt "Provide the organisation unit for the certificate [Cellar Dwellers Unit 1337]"
$company = Read-Host -Prompt "Provide the company for the certificate [Swedbank]"
$locality = Read-Host -Prompt "Provide the city the company is located in [Tallinn]"
$state = Read-Host -Prompt "Provide the state the company is located in [Harjumaa]"
$country = Read-Host -Prompt "Provide the country code [EE]"
$dir = Get-Location
$newfolder = $dir.tostring() + "\" +$commonName
$null = new-item $newfolder -itemtype directory
$files = @{}
$files['settings'] = $newfolder+ "\" +$commonName +"-settings.inf";
$files['csr'] = $newfolder+ "\" +$commonName +".csr"

#########################
# Create the settings.inf
#########################
$settingsInf = "
[Version] 
Signature=`"`$Windows NT`$ 
[NewRequest] 
KeyLength =  2048
Exportable = TRUE 
MachineKeySet = TRUE 
SMIME = FALSE
RequestType =  PKCS10 
ProviderName = `"Microsoft RSA SChannel Cryptographic Provider`" 
ProviderType =  12
HashAlgorithm = sha256
;Variables
Subject = `"CN={{CN}},OU={{OU}},O={{O}},L={{L}},S={{S}},C={{C}}`"
[Extensions]
;Certreq info
;http://technet.microsoft.com/en-us/library/dn296456.aspx
;CSR Decoder
;https://certlogik.com/decoder/
;https://ssltools.websecurity.symantec.com/checker/views/csrCheck.jsp
"

$settingsInf = $settingsInf.Replace("{{CN}}",$commonName).Replace("{{O}}",$org).Replace("{{OU}}",$company).Replace("{{L}}",$locality).Replace("{{S}}",$state).Replace("{{C}}",$country)

# Save settings to file in temp
$settingsInf > $files['settings']

# Done, we can start with the CSR
Clear-Host

#################################
# CSR TIME
#################################

# Display summary
Write-Host "Certificate information
Common name: $($commonName)
Organisation: $($org)
Organisational unit: $($company)
City: $($locality)
State: $($state)
Country: $($country)
Signature algorithm: SHA256
Key algorithm: RSA
Key size: 2048
" -ForegroundColor Yellow

certreq -new $files['settings'] $files['csr'] > $null

# Output the CSR
$CSR = Get-Content $files['csr']
Write-Output $CSR
Write-Host ""

# Set the Clipboard (Optional)
Write-Host "CSR has been copied to your clipboard!" -ForegroundColor Yellow 
Write-Host "The CSR is located here:" $files['csr']
$csr | clip

 }
 elseif ($result -eq 1) {
	 $choice = "Generate CSR with OpenSSL"
	 # Define the default parameters on the certificate
$request = @{}
Write-Host "Provide the Subject details required for the Certificate Signing Request" -ForegroundColor Yellow
$commonName = Read-Host -Prompt "Provide the domain or name you're generating a certificate for [www.swedbank.ee or Your Name]"
$org = Read-Host -Prompt "Provide the organisation unit for the certificate [Cellar Dwellers Unit 1337]"
$company = Read-Host -Prompt "Provide the company for the certificate [Swedbank]"
$locality = Read-Host -Prompt "Provide the city the company is located in [Tallinn]"
$state = Read-Host -Prompt "Provide the state the company is located in [Harjumaa]"
$country = Read-Host -Prompt "Provide the country code [EE]"
$Signature = '$Windows NT$' 
$dir = Get-Location
$newfolder = $dir.tostring() + "\" +$commonName
$null = new-item $newfolder -itemtype directory
$CSRPath = $newfolder + "\" +$commonName + ".csr"
$keyPath = $newfolder + "\" +$commonName + ".key"
$subject = "/C=$country/ST=$state/L=$locality/O=$org/OU=$company/CN=$commonName"

# Generate the key and csr

openssl req -new -nodes -sha256 -new -keyout $keyPath -out $CSRPath -newkey rsa:2048 -verify -newhdr -subj $subject
write-output "Certificate Request and private Key has been saved to $newfolder"
 
 # Output the CSR
$CSR = Get-Content $CSRPath
Write-Output $CSR
Write-Host ""
# Set the Clipboard (Optional)
Write-Host "CSR has been copied to your clipboard!" -ForegroundColor Yellow
Write-Host "The CSR is located here: $CSRPath"
$csr | clip
}
 elseif ($result -eq 2) {
     $choice = "Export PKCS12'"
	 # Script to export certificate from LocalMachine store along with private key
$AskPass = Read-Host "Enter Password to be used for PKCS conteiner encryption" #password to access certificate after exporting
$Certname = Read-Host "Enter Certificate Name"
$Certexpirey = Read-Host "Enter Certificate validity end date"
$RootCertName = Read-Host "Enter ROOT Certificate Name" # root certificate (the Issuer)
$CertRootexpirey = Read-Host "Enter ROOT Certificate validity end date"
$dir = Get-Location
$newfolder = $dir.tostring() + "\" +$Certname
$null = new-item $newfolder -itemtype directory

$RootCert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $RootCertname -friendlyname $RootCertname -subject "CN=$RootCertname,O=$RootCertname,OU=$RootCertname" -keylength 4096 -keyalgorithm RSA -hashalgorithm SHA256 -keyexportpolicy Exportable -KeyUsage CertSign,CRLSign,DigitalSignature -KeyUsageProperty All -NotAfter (Get-Date).AddYears($CertRootexpirey)
$ROOTthumbprint = $RootCert.Thumbprint
$Cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $Certname -friendlyname $Certname -subject "CN=$Certname,O=$Certname,OU=$Certname" -keyexportpolicy Exportable -Signer cert:\localMachine\my\$ROOTthumbprint -NotAfter (Get-Date).AddYears($Certexpirey)
$thumbprint = $Cert.Thumbprint
$CertDestPath = Join-Path -Path $newfolder -ChildPath "Chain.pfx"
$SecurePassword = ConvertTo-SecureString -String $AskPass -Force -AsPlainText

# Export PFX certificate along with private key
Export-PfxCertificate -Cert cert:\localMachine\my\$thumbprint -FilePath $CertDestPath -ChainOption BuildChain -Password $SecurePassword
Write-Host "The PKX container is located here: $CertDestPath"
 }
 else {
     $choice = "Try again"
 }