class WindowMover {
    static MAX_RESYNC_ATTEMPTS := 3

    static 32BitPID
    static 64BitPID

    __new() {
        wasCritical := A_IsCritical
        Critical

        if (!this.isAvailable()) {
            this._startUpDLLInjectors()
        }

        Critical %wasCritical%
    }

    /*
     * Check whether both the 32 and 64 bit dll injectors are available.
     */
    isAvailable() {
        if (this.32BitPID) {
            process exist, % this.32BitPID
            if (ErrorLevel == 0) {
                this.32BitPID := false
                Logger.info(this.__class ": 32 bit dll missing")
            }
        }
        if (this.64BitPID) {
            process exist, % this.64BitPID
            if (ErrorLevel == 0) {
                this.64BitPID := false
                Logger.info(this.__class ": 64 bit dll missing")
            }
        }
        return !!this.32BitPID && !!this.64BitPID
    }

    resync := this.__new

    /*
     * Move the active window to the specified desktop number,
     * returning zero on success or an error code on failure.
     */
    moveActiveToDesktop(desktop) {
        wasCritical := A_IsCritical
        Critical

        desktop -= 1 ;; The dll is zero-indexed.
        hwnd := WinExist("A")

        marker := 43968 ; 0xABC0
        wParam := desktop | marker
        lParam := hwnd

        WM_SYSCOMMAND := 274

        PostMessage %WM_SYSCOMMAND%,  %wParam%, %lParam%, , ahk_id %hwnd%

        refocus()

        Critical %wasCritical%

        return ErrorLevel
    }

    _startUpDLLInjectors() {
        static LOADER := A_ScriptDir "\..\dll\dllCaller.ahk"
        myPID := DllCall("GetCurrentProcessId")

        path := ""
        pid := ""
        SplitPath A_AhkPath, _, path

        while (!this.32BitPid && A_Index <= this.MAX_RESYNC_ATTEMPTS) {
            Logger.info(this.__class ": creating 32bit dll")

            Run %path%\AutoHotkeyU32.exe %LOADER% %myPID% 32, %A_ScriptDir%
                , useerrorlevel, pid
            if (ErrorLevel) {
                Logger.debug("Error starting 32bit dllCaller: " A_LastError)
            }
            this.32BitPid := pid
            Logger.info("32bit hook created with pid: " this.32BitPid)
        }

        while (!this.64BitPid && A_Index <= this.MAX_RESYNC_ATTEMPTS) {
            Logger.info(this.__class ": creating 64bit dll")
            Run %path%\AutoHotkeyU64.exe %LOADER% %myPID% 64, %A_ScriptDir%
                , useerrorlevel, pid
            if (ErrorLevel) {
                Logger.debug("Error starting 64bit dllCaller: " A_LastError)
            }
            this.64BitPID := pid
            Logger.info("64bit hook created with pid: " this.64BitPID)
        }
    }
}
