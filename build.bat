@echo off
set err_level=0

rem http://stackoverflow.com/questions/138497/iterate-all-files-in-a-directory-using-a-for-loop for file loops
rem "C:/Program Files/AutoHotkey/AutoHotkeyU32.exe" /ErrorStdOut "testMain.ahk" 2>&1 |more

echo Cleaning
rm -rf target

echo Creating target diretory
mkdir target

echo Copying dlls to the target directory.
cp dll/* target

start "Building executable" /B /wait "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in src\dwinm.ahk /out target\dwinm.exe 2>&1 | tee buildoutput.txt

if errorlevel 1000 (
    echo *** Build failed ***
    set err_level=1
)

exit /b %err_level%
