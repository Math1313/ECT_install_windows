$DesktopPath = [Environment]::GetFolderPath("Desktop")
do{
    Write-Host $DesktopPath"\Nextcloud.lnk"
    Start-Sleep -s 2
    Write-Host "YAYAHHAHAYAYHHA"
}
while (!(Get-ItemProperty "C:\Users\Public\Desktop\Nextcloud.lnk" -erroraction 'silentlycontinue'))