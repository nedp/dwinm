/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
class JPGIncDesktopChangerClass {
    goToDesktopCallbackFunctionName := "goToDesktop"
    nextDesktopFunctionName := "goToNextDesktop"
    recentDesktopFunctionName := "goToRecentDesktop"
    resyncDesktopFunctionName := "resyncDesktop"
    previousDesktopFunctionName := "goToPreviousDesktop"
    _postGoToDesktopFunctionName := ""

    __new() {
        this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
        this.goToDesktop(1)
        this.currentDesktop := this.desktopMapper.getDesktopNumber()
        this.recentDesktop := 2
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

    goToRecentDesktop(keyCombo := "")
    {
        return this.goToDesktop(this.recentDesktop)
    }

    resyncDesktop(keyCombo := "") {
        currentDesktop := this.currentDesktop
        recentDesktop := this.recentDesktop
        send("^#{Left 10}")
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
        this._makeDesktopsIfRequired(newDesktopNumber)

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

    _makeDesktopsIfRequired(minimumNumberOfDesktops) {
        currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
        loop, % minimumNumberOfDesktops - currentNumberOfDesktops {
            send("#^d")
        }

        return this
    }

    doPostGoToDesktop() {
        refocus()
        callFunction(this.postGoToDesktopFunctionName)
        return this
    }
}
