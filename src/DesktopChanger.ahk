class DesktopChanger {
    static MAX_RETRIES := 3 ;; Maximum number of attempts to resync.
    static RESYNC_DELAY := 100 ;; Delay between steps of a resync.

    Functions := { PICK: "pickDesktop"
                 , SWAP: "swapDesktops"
                 , SWAP_PICK: "swapAndPickDesktop" }

    otherDesktop := 1

    __new(dwm, desktopMapper, tooltip) {
        this.dwm := dwm
        this.desktopMapper := desktopMapper
        this.tooltip := tooltip

        this.desktop := desktopMapper.getDesktopNumber()
        this.recentDesktop := (this.desktop == 1) ? 2 : 1
        this.resync()
    }

    swapDesktops(keyCombo := "") {
        Logger.trace("DesktopChanger#swapDesktops: entry")
        wasCritical := A_IsCritical
        Critical

        otherDesktop := this.otherDesktop
        this.otherDesktop := this.desktop
        this._changeDesktop(otherDesktop)

        this.displayDesktop()

        Critical %wasCritical%
        Logger.trace("DesktopChanger#swapDesktops: exit")
    }

    resync(keyCombo := "") {
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

        this.displayDesktop()

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
            this.pickDesktop(this.recentDesktop)
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
    swapAndPickDesktop(newDesktop) {
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

            this.displayDesktop()
        }

        Critical %wasCritical%
    }

    _changeDesktop(newDesktop) {
        direction := newDesktop - this.desktop
        distance := Abs(direction)
        if (direction > 0) {
            quickSend("^#{Right " distance "}")
        } else if (direction < 0) {
            quickSend("^#{Left " distance "}")
        }

        this.desktop := newDesktop

        refocus()
        this.displayDesktop()
    }

    displayDesktop() {
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
        loop % DesktopChanger.MAX_RETRIES {
            Sleep DesktopChanger.RESYNC_DELAY

            nActualDesktops := this.desktopMapper.getNumberOfDesktops()
            nDesktopsToMake := this.dwm.nDesktops - nActualDesktops

            if (nDesktopsToMake == 0) {
                return nActualDesktops
            }
            this._displayTooltip("Wrong desktop count: " . nActualDesktops
                . ". Trying to fix...")

            ;; Go to the last desktop so we add/remove at the right place.
            slowSend("#^{Right " nActualDesktops "}")

            Sleep DesktopChanger.RESYNC_DELAY

            ;; Create desktops if we don't have enough.
            if (nDesktopsToMake > 0) {
                slowSend("#^{d " nDesktopsToMake "}")
            }

            ;; Remove desktops if we have too many.
            if (nDesktopsToMake < 0) {
                n := -nDesktopsToMake
                slowSend("#^{F4 " n "}")
            }
        }
        return nActualDesktops
    }

    _resetCurrentDesktop() {
        loop % this.MAX_RETRIES {
            Sleep this.RESYNC_DELAY

            slowSend("^#{Left " this.nDesktops "}")

            Sleep this.RESYNC_DELAY

            nMove := this.desktop - 1
            slowSend("^#{Right " nMove "}")

            Sleep this.RESYNC_DELAY

            actualDesktop := this.desktopMapper.getDesktopNumber()
            if (actualDesktop == this.desktop) {
                return actualDesktop
            }
        }
        return actualDesktop
    }

    _displayTooltip(message) {
        ToolTip %message%, this.tooltip.x, this.tooltip.y, this.tooltip.id
    }
}
