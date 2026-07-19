#Requires -Version 5.1
param(
  [Parameter(Mandatory = $true)]
  [string]$Subject,
  [Parameter(Mandatory = $true)]
  [string]$BodyFile
)

$to = "baitpait@gmail.com"
$body = Get-Content -Path $BodyFile -Raw -Encoding UTF8
$mailto = "mailto:$to?subject=$([uri]::EscapeDataString($Subject))&body=$([uri]::EscapeDataString($body))"

Write-Host "Opening email draft to $to ..."
Start-Process $mailto
Write-Host "If no mail app opens, copy the report from: $BodyFile"
