class DesktopMapper {

    static PATH := "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"

    __new(virtualDesktopManager) {
        this.virtualDesktopManager := virtualDesktopManager
        this._setupGui()

        this.resync()
    }

    /*
     * Populate the desktopIds array with the current virtual deskops according
     * to the registry key
     */
    resync() {
        static REG_ID_LENGTH := 32
        RegRead desktopList, HKEY_CURRENT_USER, % this.PATH, VirtualDesktopIDs

        max := StrLen(desktopList)
        start := 1
        this.desktopIds := []
        while (start < max) {
            desktopId := SubStr(desktopList, start, REG_ID_LENGTH)
            this.desktopIds.push(this._idFromReg(desktopId))
            start += REG_ID_LENGTH
        }
    }

    syncDesktopCount() {
        this.resync()
        return this.desktopIds.maxIndex()
    }

    /*
     * returns the number of the current desktop
     */
    currentDesktop() {
        this.resync()
        currentId := this._currentDesktopId()
        return this._indexOfId(currentId)
    }

    _currentDesktopId() {
        hwnd := this.hwnd
        Gui %hwnd%:show, NA ;show but don't activate
        winwait, % "Ahk_id " hwnd

        guid := this.virtualDesktopManager.getDesktopGuid(hwnd)

        Gui %hwnd%:hide

        ;; If you don't wait until it closes (and sleep a little)
        ;; then the desktop the gui is on can get focus
        WinWaitClose Ahk_id %hwnd%

        return this._idFromGuid(guid)
    }

    /*
     * takes an ID from the registry and extracts the last 16 characters (which matches the last 16 characters of the GUID)
     */
    _idFromReg(regString) {
        return SubStr(regString, 17)
    }

    /*
     * takes an ID from microsofts IVirtualDesktopManager and extracts the last 16 characters (which matches the last 16 characters of the ID from the registry)
     */
    _idFromGuid(guidString) {
        return SubStr(RegExReplace(guidString, "[-{}]"), 17)
    }

    _indexOfId(guid) {
        for i, id in this.desktopIds {
            if (id == guid) {
                return i
            }
        }
        return -1
    }

    _setupGui() {
        Gui, new
        Gui, show
        Gui, +HwndMyGuiHwnd
        this.hwnd := MyGuiHwnd
        Gui, hide
        return this
    }
}
