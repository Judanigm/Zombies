$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$dst = Join-Path $src '..\zombies\assets\Bala'

if (-not (Test-Path -LiteralPath $dst)) {
    throw "No existe la carpeta destino: $dst"
}

Copy-Item -LiteralPath (Join-Path $src 'assets\bala_clean.png') -Destination $dst -Force

Write-Host "Bala copiada a $dst"
