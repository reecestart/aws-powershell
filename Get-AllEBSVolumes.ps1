# Clear the Powershell window
cls

# Import the AWS Powershell modules and initialize the AWS defaults
Import-Module 'C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1'; Initialize-AWSDefaults

# Script Name, Source and Version
Write-Host ScriptName: Get-AllEBSVolumes.ps1
Write-Host Source: https://github.com/reecestart/aws-powershell
Write-Host Version: 1.2 - Ensure you are using the latest version

# Path to save
New-Item -Name Temp -ItemType Directory -ErrorAction SilentlyContinue
$PathToSave = "C:\Temp"


# Get all regions
$Regions = (Get-AWSRegion).Region

# Get all Volumes in each region
$Volumes = foreach ($Region in $Regions) {
    Get-EC2Volume -Region $Region
}

# EC2 Instances Types Supported for Encryption
$SupportedInstanceTypes = @("m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge", "m4.large", "m4.xlarge", "m4.2xlarge", "m4.4xlarge", "m4.10xlarge", "t2.large", "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge", "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge", "cr1.8xlarge", "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge", "d2.xlarge", "d2.2xlarge", "d2.4xlarge", "d2.8xlarge", "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge", "g2.2xlarge", "g2.8xlarge")

#Construct an out-array to use for data export for the Volume Information
$VolumDetailsOutArray = @()
#The computer loop you already have
foreach ($Volume in $Volumes)
    {
        #Construct an object for the Device, Instance ID, State, Volume ID, AZ, Encryption Status, Iops, KMS Key ID, Size, Snapshot ID and Name
        $myobj = "" | Select "Device","InstanceId","State","VolumeId","AvailabilityZone","Encrypted","Iops","KmsKeyId","Size","SnapshotId","Name","InstanceState","SupportedForEncryption"
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
        if ($Volume.State -eq "available")
            {}
        else
            {
            if (($Volume.AvailabilityZone -eq "ap-southeast-2a") -or ($Volume.AvailabilityZone -eq "ap-southeast-2b"))
                {
                $Instance = Get-EC2Instance -Instance $Volume.Attachments.InstanceId -Region ap-southeast-2
                $myobj.InstanceState = $Instance.Instances.State.Name.Value
                $InstanceType = $Instance.Instances.InstanceType.Value
                if ($SupportedInstanceTypes -ccontains "$InstanceType")
                    {
                    $myobj.SupportedForEncryption = "Yes"
                    }
                else
                    {
                    $myobj.SupportedForEncryption = "No"
                    }
                }
            else
                {
                $Instance = Get-EC2Instance -Instance $Volume.Attachments.InstanceId -Region us-west-2
                $myobj.InstanceState = $Instance.Instances.State.Name.Value
                $InstanceType = $Instance.Instances.InstanceType.Value
                if ($SupportedInstanceTypes -ccontains "$InstanceType")
                    {
                    $myobj.SupportedForEncryption = "Yes"
                    }
                else
                    {
                    $myobj.SupportedForEncryption = "No"
                    }
                }
            }
        
        #Add the objects to the Volume Out Arrays
        $VolumDetailsOutArray += $myobj

        #Wipe the temp object just to be sure
        $myobj = $null
    }

if ($Volumes.Count -eq 0)
    {
    Write-Host No Volumes in the account -ForegroundColor Yellow
    }
else
    {
    #After the loop export the array to CSV and open
    $VolumDetailsOutArray | Export-Csv -NoTypeInformation -Path $PathToSave\VolumeInfo.csv
    Invoke-item $PathToSave\VolumeInfo.csv
    }
