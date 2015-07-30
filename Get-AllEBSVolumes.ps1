# Clear the Powershell window
cls

# Import the AWS Powershell modules and initialize the AWS defaults
Import-Module 'C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1'; Initialize-AWSDefaults

# Script Name, Source and Version
Write-Host ScriptName: Get-AllEBSVolumes.ps1
Write-Host Source: https://github.com/reecestart/aws-powershell
Write-Host Version: 1.0 - Ensure you are using the latest version

# Path to save
$PathToSave = "C:\Temp"

# Get all regions
$Regions = (Get-AWSRegion).Region

# Get all Volumes in each region
$Volumes = foreach ($Region in $Regions) {
    Get-EC2Volume -Region $Region
}

#Construct an out-array to use for data export for the Volume Information
$VolumDetailsOutArray = @()
#The computer loop you already have
foreach ($Volume in $Volumes)
    {
        #Construct an object for the Device, Instance ID, State, Volume ID, AZ, Encryption Status, Iops, KMS Key ID, Size, Snapshot ID and Name
        $myobj = "" | Select "Device","InstanceId","State","VolumeId","AvailabilityZone","Encrypted","Iops","KmsKeyId","Size","SnapshotId","Name"
        #Fill the object with the values mentioned above
        $myobj.Device = $Volume.Attachments.Device
        $myobj.InstanceId = $Volume.Attachments.InstanceId
        $myobj.State = $Volume.State
        $myobj.VolumeId = $Volume.VolumeId
        $myobj.AvailabilityZone = $Volume.AvailabilityZone
        $myobj.Encrypted = $Volume.Encrypted
        $myobj.Iops = $Volume.Iops
        $myobj.KmsKeyId = $Volume.KmsKeyId
        $myobj.Size = $Volume.Size
        $myobj.SnapshotId = $Volume.SnapshotId
        $myobj.Name = ($Volume.Tags | ? {$_.Key -EQ "Name"}).Value | Out-String -Stream

        
        #Add the objects to the Volume Out Array
        $VolumDetailsOutArray += $myobj

        #Wipe the temp object just to be sure
        $myobj = $null
    }

#After the loop export the array to CSV and open
if ($VolumDetailsOutArray.Count -eq "0")
    {Write-Host No EBS Volumes were found
    sleep 2
    Exit}
$VolumDetailsOutArray | Export-Csv -NoTypeInformation -Path $PathToSave\VolumeInfo.csv
Invoke-item $PathToSave\VolumeInfo.csv
