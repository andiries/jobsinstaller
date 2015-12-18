#
# start_jobs_debug.ps1
#


$distributionpath="""D:\src\netorium\JOBS\jobs-distribution\target\"""
$installdir="""D:\programme\netorium"""
$distributionname="""jobs-distribution-0.0.25-SNAPSHOT"""
$bobykarpath="""D:\src\netorium\JOBS\jobsboby\jobsboby-feature\target\jobsboby-feature-0.0.25-SNAPSHOT.kar"""
$jobsfolder="""B_Develop"""
$debugmode=$True

$scriptparams="-distributionpath $distributionpath -installdir $installdir -distributionname $distributionname -bobykarpath $bobykarpath -jobsfolder $jobsfolder -debugmode $debugmode"
$expression= """D:\tmp\powershell\jobsinstaller\start_jobs_from_distro.ps1"" $scriptparams"
Invoke-Expression """$expression"""