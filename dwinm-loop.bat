@echo off
set err_level=0

set DWM_MAX_ATTEMPTS=100

for /L %%i in (1, 1, 100) do (
    echo
    echo Building dwinm...
    .\build.bat
    if errorlevel 1 (
        echo *** dwinm failed ***
        set err_level=1
        exit /b %err_level%
    )
    echo
    echo Running dwinm...
    .\target\dwinm.exe
    @echo off
)

echo dwinm ran %DWINM_MAX_ATTEMPTS% times; stopping now.
exit /b %err_level%
