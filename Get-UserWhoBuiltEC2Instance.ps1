# Clear the PowerShell Window
cls
# Script Name, Source and Version
Write-Host ScriptName: Get-UserWhoBuiltEC2Instance.ps1
Write-Host Source: https://github.com/reecestart/aws-powershell
Write-Host Version: 1.0 - Ensure you are using the latest version
# The Instance ID we will search for you launched the server
$InstanceID = Read-Host 'What is your Instance ID?'
Write-Host 1. We are searching for who launched the EC2 Instance with Instance ID $InstanceID -ForegroundColor Green
# Import the Splunk Module for PowerShell
Write-Host 2. We are importing the Splunk Module for PowerShell -ForegroundColor Cyan
Import-Module -Name Splunk
# Check if the correct version of Splunk is present
Write-Host 3. We are checking if version 0.2.0 of the Splunk Module is present -ForegroundColor Gray
$SplunkModule = Get-Module -Name Splunk
if ($SplunkModule.Version -eq "0.2.0")
    {Write-Host 3.a. Splunk is ready -ForegroundColor Cyan
    # Disabling cert verification if Splunk uses a self-signed certificate
    Disable-CertificateValidation}
else
    {Write-Host 3.a. Splunk is not ready - install from http://dev.splunk.com/view/splunk-powershell-resource-kit/SP-CAAADRU
    Exit}
# Get the account details the user has for connecting to Splunk
Write-Host 4. Need your account details - the ones you connect to Splunk with -ForegroundColor DarkYellow
sleep 3
$creds = Get-Credential
# This is the Splunk server
$splunkserver = Read-Host 'What is your Splunk server?'
# Connect to the Splunk server
Write-Host 5. We are connecting to the Splunk server $splunkserver with your secure credentials -ForegroundColor Yellow
Connect-Splunk -Credential $creds –ComputerName $splunkserver
$Splunkd = Get-Splunkd
if ($Splunkd.ComputerName -eq $splunkserver)
    {Write-Host 5.a. Splunk Server connected -ForegroundColor Yellow }
else
    {Write-Host 5.a. We were unable to connect to the Splunk Server - $splunkserver - please check your credentials -ForegroundColor Magenta
    Exit}
# Issue the search command
Write-Host 6. We are now searching Splunk to see who launched $InstanceID -ForegroundColor DarkYellow
$SearchResult = Search-Splunk -Search $InstanceID' eventName=RunInstances'
$Splits = $SearchResult.raw -split '"'
foreach ($Split in $Splits)
    {
    if ($Split -like "*arn:aws:sts::*")
        {
        Write-Host 6.a. $Split built this server -ForegroundColor Red
        }
    }
