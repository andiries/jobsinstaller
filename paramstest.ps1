#
# paramstest.ps1
#

Param(
  [Parameter(Mandatory=$True)]
  [string]$distributionpath,
  [Parameter(Mandatory=$True)]
  [string]$installbase,
  [switch]$debugmode

)

Write-Host $distributionpath
Write-Host $installbase
Write-Host $debugmode