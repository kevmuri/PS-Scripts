param(
    $outputpath = $PSScriptRoot + '\ADPCsDisabled.csv',
    $OUPath = ""
)

Write-Host "Working..."​

$Parameters = @{
    SearchBase = $OUPath
    Filter = { Enabled -eq $False }
    Properties = @(
        "Name"
        "OperatingSystem"
        "LastLogonDate"
        )
}

[Array]$Computers = Get-ADComputer @Parameters

$Computers | Select -Property $Parameters.Properties | Sort Name | Export-CSV $outputpath -NoTypeInformation -Encoding UTF8
Write-Host "Complete. Find results in '$($outputpath | Convert-Path)'"
