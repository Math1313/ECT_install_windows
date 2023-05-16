

#Remove-Item -Path "$wallpaperPath\TranscodedWallpaper"
#Remove-Item -Path "$wallpaperPath\CachedFiles" -Recurse

$wallpaperPath = ".\extension\wallpaper.jpg"
$imagesPath = "$env:USERPROFILE\Pictures"
Copy-Item -Path "$wallpaperPath" -Destination "$imagesPath\wallpaper.jpg"

# Définit le chemin d'accès de l'image comme fond d'écran
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value "$imagesPath\wallpaper.jpg"
Write-Host "$imagesPath"

# Rafraîchit le fond d'écran
$signature = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
$systemParametersInfo = Add-Type -MemberDefinition $signature -Name WallpaperUtils -Namespace "Wallpaper" -PassThru
$result = $systemParametersInfo::SystemParametersInfo(0x0014, 0, "$imagesPath\wallpaper.jpg", 0x01)

# Vérifie le résultat
if ($result -eq 0) {
    Write-Host "Échec du changement du fond d'écran."
} else {
    Write-Host "Le fond d'écran a été changé avec succès."
}
