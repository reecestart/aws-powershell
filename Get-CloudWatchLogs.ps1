# Clear the Powershell window
cls

# Import the AWS Powershell modules and initialize the AWS defaults
Import-Module 'C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1'; Initialize-AWSDefaults

# Get all the EC2 Regions
$Regions = Get-EC2Region
$RegionNames = $Regions.RegionName

# The region to run this script against
Do {
    Write-Host ...
    Write-Host Please type the region to process the script against e.g. ap-southeast-2 for Sydney or us-west-2 for Oregon
    $Region = Read-Host
    if($RegionNames -contains $Region) 
        {" Region correct"; $strQuit ="n"}
    else
        {
        cls
        Write-Host Your region input ...
        sleep 1
        Write-Host $Region
        sleep 1
        Write-Host Was not correct.
        sleep 2
        cls
        $strQuit = "."
        }
     } # End of 'Do'
Until ($strQuit -eq "N")

# The CloudWatch Log Group Name for your VPC Flow Logs
# You can get this using the Get-CWLogGroups Command as well
$CWLLogGroups = Get-CWLLogGroups -Region $Region
$CWLLogGroupsNames = $CWLLogGroups.Arn

# The CloudWatch Log Group Name to run this script against
Do {
    Write-Host ...
    Write-Host The following are the CloudWatch Log Groups available in your region
    sleep 1
    foreach ($CWLLogGroupsName in $CWLLogGroupsNames)
    {Write-Host $CWLLogGroupsName}
    sleep 1
    Write-Host Please type the CloudWatch Log Group Name to process the script against - Omit the arn:aws:logs:region:012345678910:log-group: part as well as the :* at the end
    sleep 1
    $CWLGName = Read-Host
    $CWLGNameCheck = $CWLLogGroupsNames.EndsWith("${CWLGName}:*")
    if($CWLGNameCheck -like $True) 
        {" CloudWatch Log Group Name correct"; $strQuit ="n"}
    else
        {
        cls
        Write-Host Your CloudWatch Log Group Name input ...
        sleep 1
        Write-Host $CWLGName
        sleep 1
        Write-Host Was not correct.
        sleep 2
        cls
        $strQuit = "."
        }
     } # End of 'Do'
Until ($strQuit -eq "N")

# Get all Log Streams in the CloudWatch Log Group Name
$LogStreams = Get-CWLLogStreams -LogGroupName $CWLGName
$LogStreamNames = $LogStreams.LogStreamName

# The Log Stream Name to run this script against
Do {
    Write-Host ...
    Write-Host The following are the Elastic Network Interfaces available in your region
    sleep 1
    Write-Host $LogStreamNames
    sleep 1
    Write-Host Please type the Log Stream Name to process the script against
    sleep 1
    $LSName = Read-Host
    if($LogStreamNames -contains $LSName) 
        {" Log Stream Name correct"; $strQuit ="n"}
    else
        {
        cls
        Write-Host Your Log Stream Name input ...
        sleep 1
        Write-Host $LSName
        sleep 1
        Write-Host Was not correct.
        sleep 2
        cls
        $strQuit = "."
        }
     } # End of 'Do'
Until ($strQuit -eq "N")

$Logs = Get-CWLLogEvents -LogStreamName $LSName -LogGroupName $CWLGName

$Logs.Events | Format-Table -AutoSize >CWLogOutput.csv
Invoke-Item CWLogOutput.csv
