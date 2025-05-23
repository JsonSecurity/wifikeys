$output = "claves_wifi.txt"

"CLAVES DE RED GUARDADAS EN ESTE EQUIPO" | Out-File -FilePath $output -Encoding utf8
"===========================================" | Out-File -Append -FilePath $output -Encoding utf8

$profiles_raw = netsh wlan show profiles

$profiles = $profiles_raw | Where-Object { $_ -match 'Perfil de todos los usuarios\s+:\s(.+)$' } | ForEach-Object {
    $matches = [regex]::Match($_, 'Perfil de todos los usuarios\s+:\s(.+)$')
    $matches.Groups[1].Value.Trim()
}

if ($profiles.Count -eq 0) {
    Write-Host "No se encontraron perfiles de red Wi-Fi guardados."
    "No se encontraron perfiles de red Wi-Fi guardados." | Out-File -Append -FilePath $output -Encoding utf8
} else {
    Write-Host "Perfiles encontrados: $($profiles.Count)"
    Write-Host "Perfiles: $($profiles -join ', ')"
}

foreach ($profile in $profiles) {
    Write-Host "Procesando perfil: $profile"
    "`n==============================" | Out-File -Append -FilePath $output -Encoding utf8
    "Nombre de red: $profile" | Out-File -Append -FilePath $output -Encoding utf8

    $keyOutput = netsh wlan show profile name="$profile" key=clear
    $key = ($keyOutput | Where-Object { $_ -match 'Contenido de la clave\s+:\s(.+)$' }) | ForEach-Object {
        $matches = [regex]::Match($_, 'Contenido de la clave\s+:\s(.+)$')
        $matches.Groups[1].Value.Trim()
    }

    if ($key) {
        "Clave: $key" | Out-File -Append -FilePath $output -Encoding utf8
    } else {
        "Clave: [No se encontró o no está disponible]" | Out-File -Append -FilePath $output -Encoding utf8
    }
    "`n==============================" | Out-File -Append -FilePath $output -Encoding utf8
}

Write-Host "Proceso terminado. Revisa el archivo: $output"
