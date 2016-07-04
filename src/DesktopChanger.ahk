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
        wasCritical := A_IsCritical
        Critical

        otherDesktop := this.otherDesktop
        this.otherDesktop := this.desktop
        this.pickDesktop(otherDesktop)

        Critical %wasCritical%
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
            Logger.warning("The recent desktop is also the current desktop; not switcing")
        }

        Critical %wasCritical%
    }

    /*
     * Swap to the other desktop, then pick the specified desktop.
     *
     * Useful for quickly checking a desktop, then Alt+Tabbing back,
     * if you don't need to keep the preexisting "other" desktop.
     */
    swapAndPickDesktop(newDesktop) {
        wasCritical := A_IsCritical
        Critical

        Logger.trace("DesktopChanger#swapAndPickDesktop: newDesktop=" newDesktop)
        this.swapDesktops()
        if (this.desktop != newDesktop) {
            this._changeDesktop(newDesktop)
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
