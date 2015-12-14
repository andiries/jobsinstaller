#
# install-jobs.ps1
#

#region Helper functions

Function ExitWithMessage($ExitMessage)
{

	Write-Host ("Distribution {0} doesn't exist!" -f $jobsdistribution)
	Exit
}

#endregion

#$distributionpath="D:\src\netorium\JOBS\jobs-distribution\target\"
$distributionpath="Z:\shared\"
$distributionname="jobs-distribution-0.0.25-SNAPSHOT"
$bobykarname="jobsboby-feature-0.0.25-SNAPSHOT.kar"
#$installbase="D:\programme"
$installbase="c:\Users\andreas ries\programme"
$jobsdistribution=(Join-Path -path $distributionpath -ChildPath $distributionname) + ".zip"
$bobykar=Join-Path -path $distributionpath -ChildPath $bobykarname
$company="netorium"
$Jobsfolder="Jobs"

$installdir=Join-Path -path $installbase -ChildPath $company

if (-Not (Test-Path $jobsdistribution)) 
{
    ExitWithMessage ("Distribution {0} doesn't exist!" -f $jobsdistribution)
} 

#check, if installdir exists
if (-Not (Test-Path $installdir)) 
{
	#try creating installdir
    New-Item -Path $installdir -ItemType directory
	if ($?.Equals($false))
	{
		ExitWithMessage ("Error creating {0}. ErrorMessage: {1}!" -f $installdir, $Error[0])
    }
}

if (-Not (Test-Path $bobykar)) 
{
    ExitWithMessage ("Boby kar file {0} doesn't exist!" -f $bobykar)
}
#Copy-Item $bobykar $installdir

Add-Type -AssemblyName System.IO.Compression.FileSystem

#extracting distribution
[System.IO.Compression.ZipFile]::ExtractToDirectory($jobsdistribution, $installdir)
if ($?.Equals($false))
{
	ExitWithMessage ("Error unzipping distribution. ErrorMessage: {0}!" -f $Error[0])
}

Start-Sleep -Milliseconds 500
Rename-Item -path (Join-Path -path $installdir -ChildPath $distributionname) -NewName $Jobsfolder

$karafscript=[io.path]::combine($installdir, $Jobsfolder, "bin\karaf.bat")
$karafscript="""$karafscript"""

$cmdparams=@("/K";$karafscript)
#Start-Process cmd.exe $cmdparams


Write-Host "JOBS successfully installed"

