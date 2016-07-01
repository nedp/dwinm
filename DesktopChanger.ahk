/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */

class DesktopChanger {
    static MAX_RETRIES := 3 ;; Maximum number of attempts to resync.
    static RESYNC_DELAY := 100 ;; Delay between steps of a resync.

    functions := { PICK: "pickDesktop"
                 , SWAP: "swapDesktops"
                 , RESYNC: "resyncDesktops" }

    otherDesktop := 1

    desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
    desktop := this.desktopMapper.getDesktopNumber()

    __new(nDesktops, tooltipParams) {
        this.nDesktopsTarget := nDesktops
        this.tooltip := tooltipParams
        this.resyncDesktops()
    }

    swapDesktops(keyCombo := "") {
        otherDesktop := this.otherDesktop
        this.otherDesktop := this.desktop
        this.pickDesktop(otherDesktop)
    }

    resyncDesktops(keyCombo := "") {
        ToolTip Synchronising..., 0, 0, this.tooltipNumber

        this.nDesktops := this._resetDesktopCount()
        if (this.nDesktops < this.desktop) {
            this.desktop := this.nDesktops
        }
        this.desktop := this._resetCurrentDesktop()

        refocus()
        this.displayDesktop()
    }

    /* Swap to the given virtual desktop number.
     */
    pickDesktop(newDesktop) {
        if (this.desktop != newDesktop) {
            this._changeDesktop(newDesktop)
        }
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
        message := this.desktop
        if (this.nDesktops != this.nDesktopsTarget) {
            message .= "/" . this.nDesktops
        }
        this._displayTooltip(message)
    }

    ;; Ensure that the number of desktops matches `this.nDesktops`.
    _resetDesktopCount() {
        loop % DesktopChanger.MAX_RETRIES {
            Sleep DesktopChanger.RESYNC_DELAY

            nActualDesktops := this.desktopMapper.getNumberOfDesktops()
            nDesktopsToMake := this.nDesktopsTarget - nActualDesktops

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
        loop % DesktopChanger.MAX_RETRIES {
            Sleep DesktopChanger.RESYNC_DELAY

            nTotal := this.nDesktops
            slowSend("^#{Left " nTotal "}")

            Sleep DesktopChanger.RESYNC_DELAY

            nMove := this.desktop - 1
            slowSend("^#{Right " nMove "}")

            Sleep DesktopChanger.RESYNC_DELAY

            actualDesktop := this.desktopMapper.getDesktopNumber()
            if (actualDesktop == this.desktop) {
                return actualDesktop
            }
        }
        return actualDesktop
    }

    _displayTooltip(message) {
        ToolTip %message%, (this.tooltip.x), 0, (this.tooltip.id)
    }
}
