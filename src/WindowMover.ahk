class WindowMover extends CarefulObject {
    __new(dllManager) {
        this.dllManager := dllManager

        this._startUpDLLInjectorsIfNeeded()
    }

    resync() {
        this._startUpDLLInjectorsIfNeeded()
    }

    /*
     * Move the active window to the specified desktop number,
     * returning zero on success or an error code on failure.
     */
    moveActiveToDesktop(desktop) {
        Logger.trace(this.__class "#moveActiveToDesktop: ENTER")
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

        Logger.trace(this.__class "#moveActiveToDesktop: EXIT")
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
