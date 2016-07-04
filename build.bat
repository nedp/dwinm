@echo off
set err_level=0

echo Cleaning
rm -rf target

echo Creating target diretory
mkdir target

echo Copying dlls to the target directory.
cp dll/* target

start "Building executable" /B /wait "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in src\dwinm.ahk /out target\dwinm.exe 2>&1 | tee buildoutput.txt

if errorlevel 1 (
    echo *** Build failed ***
    set err_level=1
)

exit /b %err_level%
