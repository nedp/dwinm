/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
class JPGIncDesktopChangerClass {
    goToDesktopCallbackFunctionName := "goToDesktop"
    nextDesktopFunctionName := "goToNextDesktop"
    recentDesktopFunctionName := "goToRecentDesktop"
    resyncDesktopsFunctionName := "resyncDesktops"
    previousDesktopFunctionName := "goToPreviousDesktop"
    _postGoToDesktopFunctionName := ""

    __new(nDesktops) {
        this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
        this.previousDesktop := 1
        this.currentDesktop := this.desktopMapper.getDesktopNumber()
        this.nDesktops := nDesktops

        this.resyncDesktops()
        return this
    }

    goToNextDesktop(keyCombo := "") {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        this.recentDesktop := currentDesktop
        send("^#{right}")
        return this.doPostGoToDesktop()
    }

    goToPreviousDesktop(keyCombo := "") {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        this.recentDesktop := currentDesktop
        send("^#{left}")
        return this.doPostGoToDesktop()
    }

    goToRecentDesktop(keyCombo := "") {
        return this.goToDesktop(this.recentDesktop)
    }

    resyncDesktops(keyCombo := "") {
        currentDesktop := this.currentDesktop
        recentDesktop := this.recentDesktop

        this._resetDesktopCount()

        send("^#{Left " this.nDesktops "}")
        send("^#{Right " (recentDesktop - 1) "}")
        this.currentDesktop := recentDesktop

        return this._changeDesktop(currentDesktop)
    }

    /*
     *    swap to the given virtual desktop number
     */
    goToDesktop(newDesktopNumber) {
        if (this.currentDesktop != newDesktopNumber) {
            this._changeDesktop(newDesktopNumber)
        }
        this.doPostGoToDesktop()
        return this
    }

    _changeDesktop(newDesktopNumber) {
        direction := newDesktopNumber - this.currentDesktop
        distance := Abs(direction)
        if(direction > 0) {
            send("^#{right " distance "}")
        } else {
            send("^#{left " distance "}")
        }
        this.recentDesktop := this.currentDesktop
        this.currentDesktop := newDesktopNumber

        return this
    }

    ;; Ensure that the number of desktops matches `this.nDesktops`.
    _resetDesktopCount() {
        nActualDesktops := this.desktopMapper.getNumberOfDesktops()
        nDesktopsToMake := this.nDesktops - nActualDesktops

        ;; Create desktops if we don't have enough.
        if (nDesktopsToMake > 0) {
            send("#^{d " nDesktopsToMake "}")
        }

        ;; Remove desktops if we have too many.
        if (nDesktopsToMake < 0) {
            send("#^{Right " nActualDesktops "}")
            send("#^{F4 " -nDesktopsToMake "}")
        }
    }

    doPostGoToDesktop() {
        refocus()
        callFunction(this.postGoToDesktopFunctionName)
        return this
    }
}
