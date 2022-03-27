#Wake On LAN BIOS Audit
#Make sure there is "computers.txt" in the same location the script is ran. It should be a list of hostnames you wish to audit, one per line.
#This script will output the results to WBresults.csv

#Get Computer Name
$inputpath = $PSScriptRoot + '\computers.txt'
$computers = Get-Content $inputpath

#Set variable for progress bar
$counter = 0

#Delete Existing Log if it Exists and Create New One
$outputpath = $PSScriptRoot + '\WBresults.csv'
if (Test-Path $outputpath) 
{
  Remove-Item $outputpath
}
Add-Content -Path $outputpath -Value "Hostname, Status"

foreach ($computer in $computers) 
{
    #This handles the progress bar as the loop works through computers.txt
    $counter++
    Write-Progress -Activity 'Writing Results to WBCresults.csv..' -CurrentOperation $computer -PercentComplete (($counter / $computers.count) * 100)
        
        #This returns a string formatted for WBresults.csv - if null a logic operator creates a string below
        #Invoke-Command executes a remote Powershell script on targeted $computer
        $returnedstring = Invoke-Command -ComputerName $computer -ScriptBlock {
            try
            {
                #Connect to the HP_BIOSEnumeration WMI class
                $SettingList = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSEnumeration
                
                #Return the current and available values for a specific setting
                $CurrentSetting = $SettingList | Where-Object Name -eq "Wake On LAN" | Select-Object -ExpandProperty Value
                #Split the current values
                $CurrentSettingSplit = $CurrentSetting.Split(',')
                #Find the currently set value
                $Count = 0
               
               #This grabs only the selected value out of the string returned from the BIOS WMI Class. (eg: "Boot to Network, *Boot to Hard Drive, Disabled" will return "Boot to Hard Drive")
                while($Count -lt $CurrentSettingSplit.Count)
                {
                    if ($CurrentSettingSplit[$Count].StartsWith('*'))
                    {
                        $CurrentValue = $CurrentSettingSplit[$Count]
                        $CurrentValue = $CurrentValue.Trim("*")
                        break
                    }
                    else
                    {
                        $Count++
                    }
                }
                #Return the computer name and selected WOL value as a string   
                $totalstring = $env:COMPUTERNAME+", "+$CurrentValue
                return $totalstring
            }
            #No terminating errors found in this script in testing, this is possibly a useless try/catch block.
            catch{}
         }
    #Mentioned above. If a proper WOL setting isn't returned, then the BIOS Settings can't be read.
    if ($returnedstring -eq $null)
    {
        $returnedstring = $computer+", BIOS Settings Could Not Be Read"
    }
    Write-Output $returnedstring
    Add-Content -Path $outputpath -Value $returnedstring
}
Read-Host -Prompt “Complete! Find the results in: " + $outputpath + ". Press Enter to exit”