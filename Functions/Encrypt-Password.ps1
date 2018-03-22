# This is used to encrypt passwords so they are not sitting in plain text in our Common_ConfigData.
# Read More: https://docs.microsoft.com/en-us/powershell/wmf/5.0/audit_cms

Param(
    [Parameter(Mandatory=$true)]
    [string]$Password
)
$SecretCert = (Get-ChildItem Cert:\LocalMachine\My).where{$_.Thumbprint -eq "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

$Password | Protect-CmsMessage -To $SecretCert


