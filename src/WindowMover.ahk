class WindowMover {
    __new(dllManager) {
        this.dllManager := dllManager

        this._startUpDLLInjectorsIfNeeded()
    }

    /*
     * Check whether both the 32 and 64 bit dll injectors are available.
     */
    isAvailable() {
        return this.dllManager.is32BitMoverAvailable()
            && this.dllManager.is64BitMoverAvailable()
    }

    resync() {
        this._startUpDLLInjectorsIfNeeded()
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

    _startUpDLLInjectorsIfNeeded() {
        wasCritical := A_IsCritical
        Critical

        if (!this.dllManager.is32BitMoverAvailable()) {
            this.dllManager.start32BitMover()
        }
        if (!this.dllManager.is64BitMoverAvailable()) {
            this.dllManager.start64BitMover()
        }

        Critical %wasCritical%
    }
}
