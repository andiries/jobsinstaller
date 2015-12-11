#
# install-jobs.ps1
#

$jobsdistribution="D:\src\netorium\JOBS\jobs-distribution\target\jobs-distribution-0.0.25-SNAPSHOT.zip"
$bobykar="D:\src\netorium\JOBS\jobsboby\jobsboby-feature\target\jobsboby-feature-0.0.25-SNAPSHOT.kar"
$basedir="D:\programme"
$company="netorium"
$installdir=Join-Path -path $basedir -ChildPath $company

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

Add-Type -AssemblyName System.IO.Compression.FileSystem

#extracting distribution
[System.IO.Compression.ZipFile]::ExtractToDirectory($jobsdistribution, $installdir)
if ($?.Equals($false))
{
	ExitWithMessage ("Error unzipping distribution. ErrorMessage: {0}!" -f $Error[0])
}





#Copy-Item $bobykar $installdir

Write-Host "JOBS successfully installed"


Function ExitWithMessage($ExitMessage)
{

	Write-Host ("Distribution {0} doesn't exist!" -f $jobsdistribution)
	Exit
}