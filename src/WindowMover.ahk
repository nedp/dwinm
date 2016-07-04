class WindowMover {
    static MAX_RESYNC_ATTEMPTS := 3

    static 32BitPID
    static 64BitPID

    Functions := { MOVE_ACTIVE: "moveActiveToDesktop" }

    __new() {
        if (!this.isAvailable()) {
            this._startUpDLLInjectors()
        }
    }

    /*
     * Check whether both the 32 and 64 bit dll injectors are available.
     */
    isAvailable() {
        if (this.32BitPID) {
            process exist, % this.32BitPID
            if (ErrorLevel == 0) {
                this.32BitPID := false
            }
        }
        if (this.64BitPID) {
            process exist, % this.64BitPID
            if (ErrorLevel == 0) {
                this.64BitPID := false
            }
        }
        return !!this.32BitPID && !!this.64BitPID
    }

    /*
     * Move the active window to the specified desktop number,
     * returning zero on success or an error code on failure.
     */
    moveActiveToDesktop(desktop) {
        desktop -= 1 ;; The dll is zero-indexed.
        hwnd := WinExist("A")

        marker := 43968 ; 0xABC0
        wParam := desktop | marker
        lParam := hwnd

        WM_SYSCOMMAND := 274

        PostMessage %WM_SYSCOMMAND%,  %wParam%, %lParam%, , ahk_id %hwnd%

        refocus()

        return ErrorLevel
    }

    /*
     * Resynchronise to ensure that the injectors are running.
     */
    resync := this.__new

    _startUpDLLInjectors() {
        loop % this.MAX_RESYNC_ATTEMPTS {
            myPID := DllCall("GetCurrentProcessId")

            ;; Use guards so we only start processes which aren't already running.
            if (!this.32BitPid) {
                run, AutoHotkeyU32.exe dll/dllCaller.ahk %myPID% 32,
                    , useerrorlevel, pid
                this.32BitPid := pid
            }
            if (!this.64BitPid) {
                run, AutoHotkeyU64.exe dll/dllCaller.ahk %myPID% 64,
                    , useerrorlevel, pid
                this.64BitPID := pid
            }
            if (this.32BitPid && this.64BitPid) {
                return
            }
        }
    }
}
