# aws-powershell

[![Join the chat at https://gitter.im/reecestart/aws-powershell](https://badges.gitter.im/reecestart/aws-powershell.svg)](https://gitter.im/reecestart/aws-powershell?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
A repository of some AWS PowerShell scripts I wrote and use which you might find useful.

## Requirements

Please note you will need to set your execution policy to `RemoteSigned` and have the latest [AWS PowerShell Tools](https://aws.amazon.com/powershell/) installed.

## Copy-RedshiftClusterBetweenRegions-Form.ps1

[Copy-RedshiftClusterBetweenRegions-Form.ps1](../master/Copy-RedshiftClusterBetweenRegions-Form.ps1)

![alt tag](https://raw.githubusercontent.com/reecestart/aws-powershell/master/Images/Copy.Redshift.Cluster.Between.Regions.Complete.png)


### Steps

|Step|Description|Comments|
| ---|-----------|--------|
|1|Select Region of source Redshift Cluster||
|2|Select source Redshift Cluster||
|3|Enter a unique Snapshot Identifier||
|4|Select destination Region for copied Redshift Cluster||
|5|Select the unique Snapshot Copy Grant that is created based on your username and date & time|Snapshot copy between regions will take time|
|6|Select a VPC Security Group||
|7|Enter a unique Redsift Cluster Identifier||


#### NOTE: Update Lines 7, 8, and 9 for MailMe Function
```powershell
####### Please set these values ######
$Global:smtpserver = "smtp.company.org"
$Global:from ="no-reply@redshiftclustermigrator.company.com"
$Global:CompanySuffix = "@company.com"
####### Please set these values ######
```
