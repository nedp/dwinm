class DesktopPicker extends CarefulObject {
    static MAX_RETRIES := 3 ;; Maximum number of attempts to resync.
    static RESYNC_DELAY := 100 ;; Delay between steps of a resync.

    otherDesktop := 1

    /*
     * `dwm : DWinM`
     * `desktopMapper : DesktopMapper`
     * `tooltip : {x: int, y: int, id int}`.
     *
     * Calls #_resetDesktopCount but not _resetCurrentDesktop.
     * Since we have no preexisting desktop to reset to, a full
     * resync would be wasteful.
     */
    __new(dwm, desktopMapper, tooltip) {
        this.dwm := dwm
        this.desktopMapper := desktopMapper
        this.tooltip := tooltip

        wasCritical := A_IsCritical
        Critical

        this.nDesktops := this._resetDesktopCount()
        this.desktop := desktopMapper.currentDesktop()
        Logger.debug("DesktopPicker#__new: this.desktop = " this.desktop)
        this.recentDesktop := 1

        this._displayDesktop()

        Critical %wasCritical%
    }

    swapDesktops() {
        Logger.trace("DesktopPicker#swapDesktops: entry")
        wasCritical := A_IsCritical
        Critical

        otherDesktop := this.otherDesktop
        this.otherDesktop := this.desktop
        this._changeDesktop(otherDesktop)

        Critical %wasCritical%
        Logger.trace("DesktopPicker#swapDesktops: exit")
    }

    resync() {
        wasCritical := A_IsCritical
        Critical

        ToolTip Synchronising...
            , this.tooltip.x, this.tooltip.y, this.tooltip.id

        this.nDesktops := this._resetDesktopCount()
        if (this.nDesktops < this.desktop) {
            this.desktop := this.nDesktops
        }
        this.desktop := this._resetCurrentDesktop()

        refocus()

        this._displayDesktop()

        Critical %wasCritical%
    }

    /*
     * Swap to the given virtual desktop number.
     */
    pickDesktop(newDesktop) {
        wasCritical := A_IsCritical
        Critical

        if (this.desktop != newDesktop) {
            this.recentDesktop := this.desktop
            this._changeDesktop(newDesktop)
        } else if (this.desktop != this.recentDesktop) {
            recentDesktop := this.recentDesktop
            this.recentDesktop := this.desktop
            this._changeDesktop(recentDesktop)
        } else {
            Logger.debug("the recent desktop is also the current desktop; not switching")
        }

        Critical %wasCritical%
    }

    /*
     * Hard pick the specified desktop.
     *
     * This leaves the "recent" desktop unchanged, but sets the "other"
     * desktop to the original desktop instead.
     *
     * Useful for activating a desktop when you want to keep your
     * recent desktop but you don't care about your preexisting "other"
     * desktop.
     */
    hardPickDesktop(newDesktop) {
        wasCritical := A_IsCritical
        Critical

        ;; If we aren't already on the desired desktop.
        if (this.desktop != newDesktop) {
            ;; Push out the old "other" desktop.
            this.otherDesktop := this.desktop

            ;; Pick the new desktop, but don't return if it's the same.
            this._changeDesktop(newDesktop)

            Logger.trace("hardPickDesktop: recentDesktop = "
                        . this.recentDesktop)
            Logger.trace("hardPickDesktop: currentDesktop = "
                        . this.desktop)
        }

        Critical %wasCritical%
    }

    _changeDesktop(newDesktop) {
        this.desktop := this.desktopMapper.goToDesktop(newDesktop)
        refocus()
        this._displayDesktop()
    }

    _displayDesktop() {
        message := ""
        loop % this.nDesktops {
            message .= (A_index == this.desktop)       ? "[" A_Index "]"
                     : (A_Index == this.otherDesktop)  ? "." A_Index "."
                     : (A_Index == this.recentDesktop) ? "'" A_Index "'"
                                                       : " " A_Index " "
        }
        this._displayTooltip(message)
    }

    ;; Ensure that the number of desktops matches `this.nDesktops`.
    _resetDesktopCount() {
        static BUFFER := 2

        nActualDesktops := this.desktopMapper.syncDesktopCount()
        nDesktopsToMake := this.dwm.nDesktops - nActualDesktops
        if (nDesktopsToMake == 0) {
            return nActualDesktops
        }

        ;; Go to the last desktop so we add/remove at the right place.
        actualDesktop := this.desktopMapper.currentDesktop()
        slowSend("#^{Right " (nActualDesktops - actualDesktop + BUFFER) "}")
        sleep(this.RESYNC_DELAY)

        while (nDesktopsToMake != 0 && A_Index < this.MAX_RETRIES) {
            this._displayTooltip("Fixing wrong desktop count (" nActualDesktops ")")

            ;; Create/remove desktops if we have too many/few.
            keys := nDesktopsToMake > 0 ? "#^{d " nDesktopsToMake "}"
                                        : "#^{F4 " (-nDesktopsToMake) "}"
            slowSend(keys)
            sleep(this.RESYNC_DELAY)

            nActualDesktops := this.desktopMapper.syncDesktopCount()
            nDesktopsToMake := this.dwm.nDesktops - nActualDesktops
        }
        return nActualDesktops
    }

    ;; Doesn't resync the desktopMapper!
    _resetCurrentDesktop() {
        Logger.trace(this.__class "#_resetCurrentDesktop: ENTRY")
        static BUFFER := 2

        actualDesktop := this.desktopMapper.currentDesktop()

        Logger.trace("actualDesktop = " actualDesktop)

        while (actualDesktop != this.desktop && A_Index < this.MAX_RETRIES) {
            Logger.trace("#_resetCurrentDesktop: LOOP")
            ;; Overshooting is reliable because there's no negative desktops.
            slowSend("^#{Left " (actualDesktop + BUFFER) "}")
            sleep(this.RESYNC_DELAY)
            slowSend("^#{Right " (this.desktop - 1) "}")
            sleep(this.RESYNC_DELAY)

            actualDesktop := this.desktopMapper.currentDesktop()
            Logger.trace("actualDesktop = " actualDesktop)
        }
        Logger.trace(this.__class "#_resetCurrentDesktop: EXIT")
        return actualDesktop
    }

    _displayTooltip(message) {
        ToolTip %message%, this.tooltip.x, this.tooltip.y, this.tooltip.id
    }
}
