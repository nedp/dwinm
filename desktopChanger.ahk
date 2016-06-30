/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */

class DesktopChanger {
    static MAX_RETRIES := 3 ;; Maximum number of attempts to resync.
    static RESYNC_DELAY := 100 ;; Delay between steps of a resync.

    functions := { GO_TO: "goToDesktop"
                 , OTHER: "goToOtherDesktop"
                 , RESYNC: "resyncDesktops" }

    otherDesktop := 1

    desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
    currentDesktop := this.desktopMapper.getDesktopNumber()

    __new(nDesktops, tooltipParams) {
        this.nDesktops := nDesktops
        this.tooltip := tooltipParams
        this.resyncDesktops()
    }

    goToNextDesktop(keyCombo := "") {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        this.recentDesktop := currentDesktop
        Send ^#{right}
    }

    goToPreviousDesktop(keyCombo := "") {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        this.recentDesktop := currentDesktop
        Send ^#{left}
    }

    goToRecentDesktop(keyCombo := "") {
        this.goToDesktop(this.recentDesktop)
    }

    resyncDesktops(keyCombo := "") {
        ToolTip Synchronising..., 0, 0, this.tooltipNumber

        this._resetDesktopCount()

        desktop := this._resetCurrentDesktop()

        if (this.currentDesktop != desktop) {
            this.recentDesktop := this.currentDesktop
            this.currentDesktop := desktop
        }
        this._displayTooltip(desktop)
    }

    /* Swap to the given virtual desktop number.
     */
    goToDesktop(newDesktop) {
        if (this.currentDesktop != newDesktop) {
            this._changeDesktop(newDesktop)
        }
        this.doPostGoToDesktop()
    }

    _changeDesktop(newDesktop) {
        direction := newDesktop - this.currentDesktop
        distance := Abs(direction)
        if (direction > 0) {
            quickSend("^#{Right " distance "}")
        } else {
            quickSend("^#{Left " distance "}")
        }

        this.recentDesktop := this.currentDesktop
        this.currentDesktop := newDesktop

        this._displayTooltip(newDesktop)
    }

    ;; Ensure that the number of desktops matches `this.nDesktops`.
    _resetDesktopCount() {
        loop % this.MAX_RETRIES {
            Sleep this.RESYNC_DELAY

            nActualDesktops := this.desktopMapper.getNumberOfDesktops()
            nDesktopsToMake := this.nDesktops - nActualDesktops

            if (nDesktopsToMake == 0) {
                return
            }

            ;; Go to the last desktop so we add/remove at the right place.
            slowSend("#^{Right " nActualDesktops "}")

            Sleep this.RESYNC_DELAY

            ;; Create desktops if we don't have enough.
            if (nDesktopsToMake > 0) {
                slowSend("#^{d " nDesktopsToMake "}")
            }

            ;; Remove desktops if we have too many.
            if (nDesktopsToMake < 0) {
                n := -nDesktopsToMake
                slowSend("#^{F4 " nDesktopsToMake "}")
            }
        }
    }

    _resetCurrentDesktop() {
        loop % this.MAX_RETRIES {
            Sleep this.RESYNC_DELAY

            nTotal := this.nDesktops
            slowSend("^#{Left " nTotal "}")

            Sleep this.RESYNC_DELAY

            nMove := this.currentDesktop - 1
            slowSend("^#{Right " nMove "}")

            Sleep this.RESYNC_DELAY

            actual := this.desktopMapper.getDesktopNumber()
            if (actual == this.currentDesktop) {
                return actual
            }
        }
        return actual
    }

    _displayTooltip(message) {
        ToolTip %message%, (this.tooltip.x), 0, (this.tooltip.id)
    }
}
