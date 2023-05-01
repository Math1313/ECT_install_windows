Optimize-Volume -DriveLetter C
Enable-ComputerRestore -Drive "C:"
vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -PropertyType DWORD -Force
Checkpoint-Computer -Description "1"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Force