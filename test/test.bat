@echo off
set err_level=0

rem http://ss64.com/nt/start.html
rem http://stackoverflow.com/questions/138497/iterate-all-files-in-a-directory-using-a-for-loop for file loops
rem "C:/Program Files/AutoHotkey/AutoHotkeyU32.exe" /ErrorStdOut "testMain.ahk" 2>&1 |more

rem Loop over all ahk files in tests directory
for /r %%i in (*Test.ahk) do (
	echo ** Running %%~nxi **
	start "testing" /B /wait "C:\Program Files\AutoHotkey\AutoHotkeyU32.exe" /ErrorStdOut %%~nxi
	if errorlevel 1 (
		echo *** TEST FILE %%~nxi FAILED ***
		set err_level=1
	)
	echo.
)


rem EXIT SCRIPT
exit /b %err_level%
