#
# Script1.ps1
#

$debugmode=$True
$karafscript="c:\Users\andreas ries\programme\netorium\bin\karaf.bat"
if($debugmode.Equals($True))
{
	$karafscript=$karafscript + " debug"
}
$karafscript="""$karafscript"""

#Start-Process -Verb Runas cmd.exe "/K"
Write-Host "Erfolg"