$ErrorActionPreference = 'Stop'

# 'Musica' con acento construido desde su codigo de caracter (U+00FA = u-acentuada)
# para que este .ps1 quede 100% ASCII y no dependa del encoding del archivo.
$musica = 'M' + [char]0xFA + 'sica'

$src = $PSScriptRoot
$dst = Join-Path $src "..\zombies\assets\Sonido\$musica"

if (-not (Test-Path -LiteralPath $dst)) {
    throw "No existe la carpeta destino: $dst"
}

Copy-Item -LiteralPath (Join-Path $src 'assets\en el juego.mp3')     -Destination $dst -Force
Copy-Item -LiteralPath (Join-Path $src 'assets\Michael Jackson.mp3') -Destination $dst -Force

Write-Host "Musica copiada a $dst"
