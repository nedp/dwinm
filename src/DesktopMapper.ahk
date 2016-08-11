class DesktopMapper extends CarefulObject {

    static MAX_RETRIES := 3 ;; Maximum number of attempts to change desktop.

    static PATH := "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"

    static NULL_GUID := "{00000000-0000-0000-0000-000000000000}"
    static BAD_CLASS_REGEX := "WorkerW"
                           . "|WindowsForms10\.Window"
                           . "|Shell_TrayWnd"

    __new(virtualDesktopManager) {
        this.virtualDesktopManager := virtualDesktopManager
        this._setupGui()
        this.resync()
        this.syncCurrentDesktop()
    }

    /*
     * Populate the desktopIds array with the current virtual deskops according
     * to the registry key.
     *
     * Costly.
     */
    resync() {
        Logger.debug(this.__class "#resync: ENTRY")
        static REG_ID_LENGTH := 32
        RegRead desktopList, HKEY_CURRENT_USER, % this.PATH, VirtualDesktopIDs

        max := StrLen(desktopList)
        Logger.trace(this.__class "#resync: registry length = " max)
        start := 1
        this.desktopIds := []
        while (start < max) {
            desktopId := SubStr(desktopList, start, REG_ID_LENGTH)
            this.desktopIds.push(this._idFromReg(desktopId))
            start += REG_ID_LENGTH
        }
        Logger.debug(this.__class "#resync: EXIT")
    }

    /*
     * Resynchronise and report the total number of desktops.
     *
     * Costly.
     */
    syncDesktopCount() {
        this.resync()
        maxIndex := this.desktopIds.maxIndex()
        return maxIndex > 0 ? maxIndex : 1
    }

    /*
     * Report the true current desktop by the fastest method which
     * is currently reliable.
     *
     * If a fast but specialised desktop check is available, it will be
     * used, otherwise a slower but more general check is used.
     *
     * Costly.
     */
    syncCurrentDesktop() {
        hwnd := this._fastHwnd()
        this.currentId := hwnd ? this._fastDesktopId(hwnd)
                        : this._fallbackDesktopId()
        return this._indexOfId(this.currentId)
    }

    /*
     * Report the estimated current desktop by finding the
     * desktop of the topmost window.
     *
     * If such a window is not available, the current desktop
     * will be estimated based on operations taken place since
     * the desktop was last reliably checked.
     *
     * Cheap.
     */
    fastCurrentDesktop() {
        hwnd := this._fastHwnd()
        Logger.trace(this.__class "#fastCurrentDesktop: hwnd=" hwnd)
        if (hwnd) {
            this.currendId := this._fastDesktopId(hwnd)
        }
        Logger.trace(this.__class "#fastCurrentDesktop: id=" this.currentId)
        return this._indexOfId(this.currentId)
    }

    /*
     * Send the appropriate keypresses required to go to the
     * specified desktop.
     *
     * Cheap.
     */
    goToDesktop(newDesktop) {
        Logger.trace(this.__class "#goToDesktop: ENTRY")
        Logger.trace("newDesktop=" newDesktop)

        desktop := this.fastCurrentDesktop()
        Logger.trace("initial estimated desktop=" desktop)
        while (desktop != newDesktop && A_Index <= this.MAX_RETRIES) {
            if (newDesktop > desktop) {
                quickSend("^#{Right " (newDesktop - desktop) "}")
            } else {
                quickSend("^#{Left " (desktop - newDesktop) "}")
            }
            this.currentId := this.desktopIds[newDesktop]
            desktop := this.fastCurrentDesktop()
            Logger.trace("estimated desktop=" desktop)
        }
        Logger.trace(this.__class "#goToDesktop: EXIT")
        return this._indexOfId(this.currentId)
    }

    _fastHwnd() {
        hwnd := WinExist("A")

        if (!hwnd) {
            return false
        }

        class := ""
        WinGetClass class, ahk_id %hwnd%
        Logger.trace("hwnd = " hwnd ", class = " class)
        return RegExMatch(class, this.BAD_CLASS_REGEX) ? false : hwnd
    }

    _fastDesktopId(hwnd) {
        Logger.trace(this.__class "#_fastDesktopId: ENTRY")
        guid := this.virtualDesktopManager.getDesktopGuid(hwnd)
        if (!guid || guid == this.NULL_GUID) {
            Logger.warning("Bad GUID: " guid)
        }
        Logger.trace(this.__class "#_fastDesktopId: EXIT")
        return this._idFromGuid(guid)
    }

    _fallbackDesktopId() {
        Logger.trace(this.__class "#_fallbackDesktopId: ENTRY")

        this.resync()
        hwnd := this.hwnd
        Gui %hwnd%:show, NA ;show but don't activate
        winwait, % "Ahk_id " hwnd

        guid := this.virtualDesktopManager.getDesktopGuid(hwnd)

        ;; If you don't wait until it closes (and sleep a little)
        ;; then the desktop the gui is on can get focus
        Gui %hwnd%:hide
        WinWaitClose Ahk_id %hwnd%

        Logger.debug(this.__class "_fallbackDesktopId: hwnd = "
                     . hwnd " -- guid = " guid)
        Logger.trace(this.__class "#_fallbackDesktopId: EXIT")

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
        Logger.trace(this.__class "#_indexOfId: ENTRY")
        for i, id in this.desktopIds {
            Logger.trace(this.__class "_indexOfId: id = " id)
            if (id == guid) {
                Logger.trace(this.__class "#_indexOfId: EXIT")
                return i
            }
        }
        Logger.trace(this.__class "#_indexOfId: EXIT")
        return -1
    }

    _setupGui() {
        Gui, new
        Gui, show
        Gui, +HwndMyGuiHwnd
        this.hwnd := MyGuiHwnd
        Gui, hide
    }
}
