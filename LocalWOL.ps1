 Write-Host "Attempting to read BIOS settings. The current WOL configuration is selected with an asterisk (*):"

       
        $SettingList = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSEnumeration
        ($SettingList | Where-Object Name -eq "Wake On LAN").Value

        #Would you like to change this setting?
        Write-Host ""
        $confirmation = Read-Host "Would you like to change the WOL settings on this PC to BOOT TO HARD DRIVE? (y/n)"
        if ($confirmation -eq 'y') 
        {
            $Interface = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSSettingInterface

            $Interface.SetBIOSSetting("Wake On LAN","Boot to Hard Drive")
            Write-Host "BIOS settings have been updated."
            Read-Host -Prompt “Press Enter to exit”
        }