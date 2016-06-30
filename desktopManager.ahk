/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
class JPGIncDesktopManagerClass
{
    __new(nDesktops, desktopTooltip) {
        this._desktopChanger := new JPGIncDesktopChangerClass(nDesktops, desktopTooltip)
        this._windowMover := new JPGIncWindowMoverClass()
        this.hotkeyManager := new JPGIncHotkeyManager()

        this._setupDefaultHotkeys()
    }

    /*
     * Public API to setup virtual desktop hotkeys and callbacks
     */
    setGoToDesktop(hotkeyKey) {
        this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.goToDesktopCallbackFunctionName, hotkeyKey)
        return this
    }

    setMoveWindowToDesktop(hotkeyKey) {
        this.hotkeyManager.setupNumberedHotkey(this._windowMover, this._windowMover.moveActiveWindowToDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToNextDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.nextDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToPreviousDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.PreviousDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToRecentDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.recentDesktopFunctionName, hotkeyKey)
        return this
    }

    setResyncDesktops(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.resyncDesktopsFunctionName, hotkeyKey)
        return this
    }


    setMoveWindowToNextDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._windowMover, this._windowMover.moveToNextFunctionName, hotkeyKey)
        return this
    }

    setMoveWindowToPreviousDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this._windowMover, this._windowMover.moveToPreviousFunctionName, hotkeyKey)
        return this
    }

    setCloseDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this, "closeDesktop", hotkeyKey)
        return this
    }

    setNewDesktop(hotkeyKey) {
        this.hotkeyManager.setupHotkey(this, "newDesktop", hotkeyKey)
        return this
    }

    /*
     * end public api
     */

    newDesktop(hotkeyCombo := "") {
        slowSend("^#d")
    }

    closeDesktop(hotkeyCombo := "") {
        slowSend("^#{f4}")
    }
}
