# installing and staring JOBS as a windows service
#
# calls a batchfile provided by karaf to install the service 'JOBS-Runtime'and the starts the service

$wrapperbatchfile=$args[0]
$servicid="JOBS-Runtime"

if (-Not (Test-Path $wrapperbatchfile)) 
{
	Write-Host ("File {0} doesn't exist!" -f $wrapperbatchfile)
	Exit -8001
} 

$cmdparams=@("/C";"""$wrapperbatchfile"""; "install")
$installserviceprocess = Start-Process -Wait -PassThru cmd.exe $cmdparams
if (-Not ($installserviceprocess.ExitCode -eq 0))
{
    Write-Host ("Error installing Windows Service. Installscript {0} returns exit code {1}" `
        -f $wrapperbatchfile, $installserviceprocess.ExitCode)
	Exit $installserviceprocess.ExitCode
}
else
{
	Write-Host("WindowsService {0} installed" -f $servicid)
}

Start-Service -Name $servicid

if ($?.Equals($false))
{
    Write-Host ("Error starting service {0}. ErrorMessage: {1}!" -f $servicid, $Error[0])
	Exit -8002
}
else
{
	Write-Host("WindowsService {0} started" -f $servicid)
	Exit 0
}
