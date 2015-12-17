#
# updates JOBS on windows
#

Function FindJobsInstallation ($jobsserviceid)
{
	#check if JOBS windows service runs and return the path to the service exe
	$jobsservice=(gwmi win32_service|?{$_.name -eq $jobsserviceid})

	if ($jobsservice -eq $null)
	{
		ExitWithMessage ("Can't find a JOBS installation. No Service JOBS-Runtime installed")
	}

	return $jobsservice.pathname
}

Function ExtractNetoriumPath ($serviceexepath, $serviceexename)
{
    $pos=$serviceexepath.LastIndexOf($serviceexename)
	if ($pos -eq -1)
	{
		ExitWithMessage ("Couldn't find the string {0} in path {1}. Can't find the path of the JOBS installation" `
			-f $serviceexename, $serviceexepath)
	}

	$netoriuminstalldir=$serviceexepath.Substring(0, $pos - 1)
	return $netoriuminstalldir
}

Function CopyDatabase ($jobsinstalldir, $netoriuminstalldir, $distributionname)
{
	$dbpath=Join-Path -Path $jobsinstalldir -ChildPath "data\elasticsearch\jobs"
	$dbtargetpath=Join-Path (Join-Path -Path $netoriuminstalldir -ChildPath $distributionname) -ChildPath "data\elasticsearch"
	Copy-Item $dbpath -Destination $dbtargetpath -Recurse
	if ($?.Equals($False))
	{
		ExitWithMessage ("Could not copy data {0} to {1}. ErrorMessage: {2}" -f $dbpath, $dbtargetpath, $Error[0])
    }
}

Function StartStopService ($jobsserviceid, $dostart)
{
	$startstopparam
	if ($dostart -eq $True)
	{
		$startstopparam="-dostartservice"
	}
	else
	{
		$startstopparam="-dostopservice"
	}
    $processresult = Start-Process powershell.exe -PassThru -Wait -Verb Runas -ArgumentList '-windowstyle', 'Hidden', `
	    '-File', "D:\tmp\powershell\jobsinstaller\servicehelper.ps1", $jobsserviceid, $startstopparam

	#TODO replace with variable script location
	#TODO Error handling
}


###### This is the entry point to the script ######

Write-Host "`n###### Updating Netorium JOBS ######`n"

Import-Module .\installhelpers.psm1

$jobsserviceid="JOBS-Runtime"
$jobsfolder="Jobs"
$serviceexename=Join-Path -Path $jobsfolder -ChildPath "bin\JOBS-Runtime-wrapper.exe"
$distributionname="jobs-distribution-0.0.25-SNAPSHOT"
$jobsdistribution=(Join-Path -Path $PSScriptRoot -ChildPath $distributionname) + ".zip"

Write-Host "checking, if distro exists"
CheckDistroExists $jobsdistribution

Write-Host "trying to find a JOBS installation"
$serviceexepath=FindJobsInstallation $jobsserviceid

$netoriuminstalldir=ExtractNetoriumPath $serviceexepath $serviceexename
$jobsinstalldir=Join-Path -Path $netoriuminstalldir -ChildPath $jobsfolder
Write-Host ("found a JOBS installation in {0}" -f $jobsinstalldir)

Write-Host "extracting distro"
ExtractDistro $jobsdistribution $netoriuminstalldir

Write-Host "stopping windows service"
StartStopService $jobsserviceid $False

Write-Host "copying data"
CopyDatabase $jobsinstalldir $netoriuminstalldir $distributionname

#Sometimes removing doesn't work after copying. Waiting a little should help
Start-Sleep -Milliseconds 500
Remove-Item $jobsinstalldir -Recurse

RenameToJobsfolder $netoriuminstalldir $distributionname $jobsfolder

Write-Host "starting windows service"
StartStopService $jobsserviceid $True

Write-Host "`n###### Netorium JOBS updated successfully ######`n"