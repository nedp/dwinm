﻿/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
class JPGIncDesktopManagerClass
{
    __new(nDesktops)
    {
        this._desktopChanger := new JPGIncDesktopChangerClass(nDesktops)
        this._windowMover := new JPGIncWindowMoverClass()
        this.hotkeyManager := new JPGIncHotkeyManager()

        this._setupDefaultHotkeys()
        return this
    }

    /*
     * Public API to setup virtual desktop hotkeys and callbacks
     */
    setGoToDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.goToDesktopCallbackFunctionName, hotkeyKey)
        return this
    }
    setMoveWindowToDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupNumberedHotkey(this._windowMover, this._windowMover.moveActiveWindowToDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToNextDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.nextDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToPreviousDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.PreviousDesktopFunctionName, hotkeyKey)
        return this
    }

    setGoToRecentDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.recentDesktopFunctionName, hotkeyKey)
        return this
    }

    setResyncDesktops(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._desktopChanger, this._desktopChanger.resyncDesktopsFunctionName, hotkeyKey)
        return this
    }


    setMoveWindowToNextDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._windowMover, this._windowMover.moveToNextFunctionName, hotkeyKey)
        return this
    }

    setMoveWindowToPreviousDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this._windowMover, this._windowMover.moveToPreviousFunctionName, hotkeyKey)
        return this
    }

    setCloseDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this, "closeDesktop", hotkeyKey)
        return this
    }

    setNewDesktop(hotkeyKey)
    {
        this.hotkeyManager.setupHotkey(this, "newDesktop", hotkeyKey)
        return this
    }

    afterGoToDesktop(functionLabelOrClassWithCallMethodName)
    {
        this._desktopChanger.postGoToDesktopFunctionName := functionLabelOrClassWithCallMethodName
        return this
    }

    afterMoveWindowToDesktop(functionLabelOrClassWithCallMethodName)
    {
        this._windowMover.postMoveWindowFunctionName := functionLabelOrClassWithCallMethodName
        return this
    }

    /*
     * end public api
     */

    newDesktop(hotkeyCombo := "")
    {
        send("^#d")
        return this
    }

    closeDesktop(hotkeyCombo := "")
    {
        send("^#{f4}")
        return this
    }

    _setupDefaultHotkeys()
    {
        Hotkey, IfWinActive, ahk_class MultitaskingViewFrame
        this.hotkeyManager.setupNumberedHotkey(this._desktopChanger, this._desktopChanger.goToDesktopCallbackFunctionName, "")
        Hotkey, If
        return this
    }
}
