#The first machine must always be done manually in a batch install. This way we get the license key (line 37: 'extpack install --replace $path --accept-license=$LICENSEKEY')

#Get Computer Name
$inputpath = $PSScriptRoot + '\computers.txt'
$computers = Get-Content $inputpath

#Set variable for progress bar
$counter = 0

#Delete Existing Log if it Exists and Create New One
$outputpath = $PSScriptRoot + '\VBResults.csv'
if (Test-Path $outputpath) 
{
  Remove-Item $outputpath
}
Add-Content -Path $outputpath -Value "Hostname, Status"

foreach ($computer in $computers) 
{
    #This handles the progress bar as the loop works through computers.txt
    $counter++
    Write-Progress -Activity 'Writing Results to VBCresults.csv..' -CurrentOperation $computer -PercentComplete (($counter / $computers.count) * 100)
        
        #This returns a string formatted for VBresults.csv - if null a logic operator creates a string below
        #Invoke-Command executes a remote Powershell script on targeted $computer

        New-Item "\\$Computer\C$\VboxTemp" -ItemType Directory -Force -ErrorAction Continue
       
	#Insert path to vbox file below
	Copy-Item $PathToVbox "\\$Computer\C$\VboxTemp"
	
	#Insert path to vbox extension pack below
        Copy-Item $PathToExtensionPack "\\$Computer\C$\VboxTemp\"

        try
        {
            Invoke-Command -ComputerName $computer -ScriptBlock {
                Start-Process -FilePath 'C:\VboxTemp\Virtual Box.exe' -ArgumentList "--silent" -Wait
                Start-Process -FilePath 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' -ArgumentList 'extpack install --replace C:\VboxTemp\Oracle_VM_VirtualBox_Extension_Pack-6.1.26.vbox-extpack --accept-license=33d7284dc4a0ece381196fda3cfe2ed0e1e8e7ed7f27b9a9ebc4ee22e24bd23c' -Wait
                Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
                Start-Process -Filepath "cmd.exe" -ArgumentList '/c netsh interface set interface "Virtualbox Host-Only Network" DISABLE' -wait
        }
    
    if (Test-Path "\\$Computer\C$\Program Files\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack")# -and (Test-Path "\\$Computer\C$\VboxTemp\success.txt"))
    {
        $returnedstring = $computer+", Success"
    }
    else
    {
        $returnedstring = $computer+", Failure"
    }
    
    Write-Output $returnedstring
    Add-Content -Path $outputpath -Value $returnedstring
        }
        catch{}
}
Read-Host -Prompt “Complete! Find the results in: $outputpath. Press Enter to exit”