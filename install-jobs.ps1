#
# install-jobs.ps1
#

Param(
  [Parameter(Mandatory=$True)]
  [string]$distributionpath,
  [Parameter(Mandatory=$True)]
  [string]$installdir,
  [switch]$debugmode
)

#region Helper functions

Function ExitWithMessage($ExitMessage)
{

	Write-Host ($ExitMessage)
	Exit
}

#endregion

#$distributionpath="D:\src\netorium\JOBS\jobs-distribution\target\"
#$distributionpath="Z:\shared\"
#$installdir="D:\programme"
#$installdir="c:\Users\andreas ries\programme"

$distributionname="jobs-distribution-0.0.25-SNAPSHOT"
$bobykarname="jobsboby-feature-0.0.25-SNAPSHOT.kar"
$jobsdistribution=(Join-Path -path $distributionpath -ChildPath $distributionname) + ".zip"
$bobykar=Join-Path -path $distributionpath -ChildPath $bobykarname
$company="netorium"
$jobsfolder="Jobs"

$netoriuminstalldir=Join-Path -path $installdir -ChildPath $company

if (-Not (Test-Path $jobsdistribution)) 
{
    ExitWithMessage ("Distribution {0} doesn't exist!" -f $jobsdistribution)
} 

#check, if installdir exists
if (-Not (Test-Path $netoriuminstalldir)) 
{
	#try creating installdir
    New-Item -Path $netoriuminstalldir -ItemType directory
	if ($?.Equals($false))
	{
		ExitWithMessage ("Error creating {0}. ErrorMessage: {1}!" -f $netoriuminstalldir, $Error[0])
    }
}

if (-Not (Test-Path $bobykar)) 
{
    ExitWithMessage ("Boby kar file {0} doesn't exist!" -f $bobykar)
}
#Copy-Item $bobykar $netoriuminstalldir

Add-Type -AssemblyName System.IO.Compression.FileSystem

#extracting distribution
[System.IO.Compression.ZipFile]::ExtractToDirectory($jobsdistribution, $netoriuminstalldir)
if ($?.Equals($False))
{
	ExitWithMessage ("Error unzipping distribution. ErrorMessage: {0}!" -f $Error[0])
}

Start-Sleep -Milliseconds 500
Rename-Item -path (Join-Path -path $netoriuminstalldir -ChildPath $distributionname) -NewName $jobsfolder

$karafscript=[io.path]::combine($netoriuminstalldir, $jobsfolder, "bin\karaf.bat")
$karafscript="""$karafscript"""

$cmdparams=@("/K";$karafscript)

if($debugmode.Equals($True))
{
	$cmdparams.Add("debug")
}

Start-Process cmd.exe $cmdparams

Write-Host "JOBS successfully installed"

