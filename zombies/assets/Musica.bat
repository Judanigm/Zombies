@echo off
rem %~dp0 detecta automaticamente la carpeta donde esta este script

set "archivo1=%~dp0 + \_Modificaciones\Music\en el juego.mp3"
set "archivo2=%~dp0 + \assets\Sonido\Música\en el juego.mp3"

rem Paso 1: Crear una copia del Archivo1 como respaldo temporal
copy "%archivo1%" "%archivo1%.temporal"

rem Paso 2: Sobrescribir el Archivo1 con el Archivo2
move /Y "%archivo2%" "%archivo1%"

rem Paso 3: Renombrar el respaldo temporal como Archivo2
move /Y "%archivo1%.temporal" "%archivo2%"

echo ¡Los archivos han sido intercambiados en esta misma carpeta!
pause