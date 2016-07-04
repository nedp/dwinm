class WindowMover {
    static MAX_RESYNC_ATTEMPTS := 3

    static has32bit
    static has64bit

    __new() {
        if (!this.isAvailable()) {
            this._startUpDLLInjectors()
        }
    }

    /*
     * Check whether both the 32 and 64 bit dll injectors are available.
     */
    isAvailable() {
        return this.has32bit && this.has64bit
    }

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

    /*
     * Resynchronise to ensure that the injectors are running.
     */
    resync := this.__new

    _startUpDLLInjectors() {
        wasCritical := A_IsCritical
        Critical

        loop % this.MAX_RESYNC_ATTEMPTS {
            ;; Use guards so we only call dlls which we haven't called already.
            if (!this.has32bit) {
                Logger.info("Starting the hook-32.dll")
                this.has32bit := DllCaller.callDll(32)
            }
            if (!this.has64bit) {
                Logger.info("Starting the hook-64.dll")
                this.has64bit := DllCaller.callDll(64)
            }
            if (this.has32bit && this.has64bit) {
                goto cleanup
            }
        }

        cleanup:
            Critical %wasCritical%
    }
}
