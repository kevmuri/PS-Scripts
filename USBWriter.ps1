$DriveLetter = (Get-Volume -FileSystemLabel KINGSTON).DriveLetter
$DrivePath = $driveLetter+":\"
Format-Volume -DriveLetter $driveLetter -FileSystem exFat -NewFileSystemLabel KINGSTON -Confirm:$false

#Correct directory to copy files to USB drive
Copy-Item "C:\users\$UserProfile\Desktop\test.txt" "$drivePath"

[console]::beep(500,300)
Write-Output "Complete!"