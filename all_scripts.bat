@echo off
echo ======================================
echo Esporto progetto Godot...
echo ======================================

set PROJECT_DIR=%~dp0

echo.
echo [1/3] Esporto tutti gli script...

powershell -Command "Get-ChildItem -Path '%PROJECT_DIR%' -Recurse -Filter *.gd | Where-Object { $_.FullName -notmatch '\\.godot\\' } | ForEach-Object { \"`n====================\"; \"FILE: $($_.FullName)\"; \"====================`n\"; Get-Content $_.FullName } | Out-File '%PROJECT_DIR%\Export\scripts.txt' -Encoding UTF8"

echo [1/3] Terminato.

echo.
echo [2/3] Esporto tutte le scene...

powershell -Command "Get-ChildItem -Path '%PROJECT_DIR%' -Recurse -Filter *.tscn | Where-Object { $_.FullName -notmatch '\\.godot\\' } | ForEach-Object { \"`n====================\"; \"FILE: $($_.FullName)\"; \"====================`n\"; Get-Content $_.FullName } | Out-File '%PROJECT_DIR%\Export\scenes.txt' -Encoding UTF8"

echo [2/3] Terminato.

echo.
echo [3/3] Genero struttura scene...

powershell -ExecutionPolicy Bypass -File export_scene_tree.ps1

echo.
echo [3/3] Terminato.
echo ======================================
echo FATTO!

pause