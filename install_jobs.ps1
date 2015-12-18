#
# installs JOBS on windows
#

Param(
  [Parameter(Mandatory=$True)]
  [string]$installdir
)

Function ExitWithMessage ($ExitMessage)
{
	Write-Host ($ExitMessage)
	Exit
}

Function CheckJAVA_HOMEExists
{
	#check JAVA_HOME environment variable
	if (-Not (Test-Path Env:JAVA_HOME)) 
	{
		ExitWithMessage ("No enviroment variable JAVA_HOME found. Install java and set JAVA_HOME.")
	}
}

Function CheckDistroExists ($jobsdistribution)
{
	#check, if distro is here
	if (-Not (Test-Path $jobsdistribution)) 
	{
		ExitWithMessage ("Distribution {0} doesn't exist" -f $jobsdistribution)
	} 
}

Function CreateInstallDir ($netoriuminstalldir)
{
	#check, if installdir exists. If not, try to create it
	if (-Not (Test-Path $netoriuminstalldir)) 
	{
		#try creating installdir
		New-Item -Path $netoriuminstalldir -ItemType directory
		if ($?.Equals($false))
		{
			ExitWithMessage ("Error creating {0}. ErrorMessage: {1}" -f $netoriuminstalldir, $Error[0])
		}
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

Function PrepareServiceInstaller ($jobsinstalldir)
{
	$wrapperconffile = Join-Path -path $jobsinstalldir -ChildPath "etc\JOBS-Runtime-wrapper.conf"
	$wrapperbatchfile = Join-Path -path $jobsinstalldir -ChildPath "bin\JOBS-Runtime-service.bat"
	$karafdata=Join-Path -path $jobsinstalldir -ChildPath "data"
	$karafetc=Join-Path -path $jobsinstalldir -ChildPath "etc"

	if (-Not (Test-Path $wrapperconffile))
	{
		ExitWithMessage ("File {0} doesn't exist" -f $wrapperconffile)
	}

	if (-Not (Test-Path $wrapperbatchfile))
	{
		ExitWithMessage ("File {0} doesn't exist" -f $wrapperbatchfile)
	}

	#replace some string in conf and batch with actual install path's
	(Get-Content $wrapperconffile) | ForEach-Object { $_ -replace "{java.home}", $javahome `
		-replace "{karaf.home}", $jobsinstalldir -replace "{karaf.data}", $karafdata `
		-replace "{karaf.etc}", $karafetc} | Set-Content $wrapperconffile
	if ($?.Equals($False))
	{
		ExitWithMessage ("Could not adjust values in {0}. ErrorMessage: {1}" -f $wrapperconffile, $Error[0])
    }

	(Get-Content $wrapperbatchfile) | ForEach-Object { $_ -replace "{karaf.base}", $jobsinstalldir `
		-replace "{karaf.etc}", $karafetc} | Set-Content $wrapperbatchfile
	if ($?.Equals($False))
	{
		ExitWithMessage ("Could not adjust values in {0}. ErrorMessage: {1}" -f $wrapperbatchfile, $Error[0])
    }
}

Function HandleServiceInstallErrors ($processexitcode)
{
	if ($processexitcode -eq -0)
	{
		#everything is fine
		return
	}

	if ($processexitcode -eq -8001)
	{
	    ExitWithMessage "karaf install script not found"
	}
	elseif ($processexitcode -eq 8002)
	{
		ExitWithMessage "Error starting service"
	}
	else
	{
		ExitWithMessage ("Error installing service. Exit code {0}" -f $processexitcode)
	}
}

Function InstallWindowsService ($jobsinstalldir)
{
	$serviceinstallscript=Join-Path -path $jobsinstalldir -ChildPath "bin\install_jobs_service.ps1"
	$wrapperbatchfile = Join-Path -path $jobsinstalldir -ChildPath "bin\JOBS-Runtime-service.bat"
	$processresult = start-process powershell.exe -PassThru -Wait -Verb Runas -ArgumentList '-windowstyle', 'Hidden', `
		'-File', $serviceinstallscript, $wrapperbatchfile

	HandleServiceInstallErrors $processresult.ExitCode
}


###### This is the entry point to the script ######

Write-Host "`n###### Installing Netorium JOBS ######`n"

CheckJAVA_HOMEExists

$javahome=(get-Childitem Env:JAVA_HOME).Value
$distributionname="jobs-distribution-0.0.25-SNAPSHOT"
$jobsdistribution=(Join-Path -path $PSScriptRoot -ChildPath $distributionname) + ".zip"
$company="netorium"
$jobsfolder="Jobs"
$netoriuminstalldir=Join-Path -path $installdir -ChildPath $company
$jobsinstalldir=Join-Path -path $netoriuminstalldir -ChildPath $jobsfolder

Write-Host "checking, if distro exists"
CheckDistroExists $jobsdistribution

Write-Host ("checking/creating installdir {0}" -f $netoriuminstalldir)
CreateInstallDir $netoriuminstalldir

Write-Host "extracting distro"
ExtractDistro $jobsdistribution $netoriuminstalldir

#Sometimes renaming doesn't work after extracting. Waiting a little should help
Start-Sleep -Milliseconds 500

Write-Host "rename jobs dir"
RenameToJobsfolder $netoriuminstalldir $distributionname $jobsfolder

Write-Host "prepare service installer"
PrepareServiceInstaller $jobsinstalldir

Write-Host "installing windows service"
InstallWindowsService $jobsinstalldir

Write-Host "`n###### Netorium JOBS installed successfully ######`n"
