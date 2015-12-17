#
# installhelpers.psm1
#

Function ExitWithMessage ($ExitMessage)
{
	Write-Host ($ExitMessage)
	Exit
}

Function CheckDistroExists ($jobsdistribution)
{
	#check, if distro is here
	if (-Not (Test-Path $jobsdistribution)) 
	{
		ExitWithMessage ("Distribution {0} doesn't exist" -f $jobsdistribution)
	} 
}

Function ExtractDistro ($jobsdistribution, $netoriuminstalldir)
{
	#extracting distribution
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	[System.IO.Compression.ZipFile]::ExtractToDirectory($jobsdistribution, $netoriuminstalldir)
	if ($?.Equals($False))
	{
		ExitWithMessage ("Error unzipping distribution. ErrorMessage: {0}" -f $Error[0])
	}
}

Function RenameToJobsfolder ($netoriuminstalldir, $distributionname, $jobsfolder)
{
	Rename-Item -path (Join-Path -path $netoriuminstalldir -ChildPath $distributionname) -NewName $jobsfolder
	if ($?.Equals($False))
	{
		ExitWithMessage ("Could not rename extracted folder. ErrorMessage: {0}" -f $Error[0])
    }
}