/*
 * Copyright 2016 Ned Pummeroy
 */
class HotkeyManager {
    __new(desktopChanger, windowMover, nDesktops) {
        this.nDesktops := nDesktops
        this.desktopChanger := desktopChanger
        this.windowMover := windowMover
    }

    /* Set up hotkeys to move the active window to target desktops.
     *
     * Sets up ten hotkeys of the form `prefix<N>`, where <N> is
     * a number key.
     */
    moveWindowToDesktop(prefix) {
        object := this.windowMover
        method := object.functions.MOVE_ACTIVE
        this._setUpNumberedHotkey(prefix, object, method)
        return this
    }

    /* Set up hotkeys to move the active window to target desktops.
     *
     * Sets up ten hotkeys of the form `prefix<N>`, where <N> is
     * a number key.
     */
    goToDesktop(prefix) {
        object := this.desktopChanger
        method := object.functions.PICK
        this._setUpNumberedHotkey(prefix, object, method)
        return this
    }

    /* Set up a hotkey to go to the 'other' desktop.
     */
    goToOtherDesktop(hotkeyKey) {
        object := this.desktopChanger
        method := object.functions.SWAP
        callback := ObjBindMethod(object, method)
        Hotkey %hotkeyKey%, %callback%, On
        return this
    }

    /* Set up a hotkey to resynchronise the desktop changer.
     */
    resyncDesktops(hotkeyKey) {
        object := this.desktopChanger
        method := object.functions.RESYNC
        callback := ObjBindMethod(object, method)
        Hotkey %hotkeyKey%, %callback%, On
        return this
    }

    /* Set up ten hotkeys of the form `prefix<N>`, where <N> is
     * a number key.
     *
     * The hotkeys will call the specified method on the specified
     * object.
     * There will be one argument matching <N>, except when N=0;
     * the argument for N=0 will be 10.
     */
    _setUpNumberedHotkey(prefix, object, methodName) {
        static modKeyRegex := "[#!^+<>*~$]"
        if (!RegExMatch(modKeyRegex, prefix)) {
            prefix .= " & "
        }
        loop % this.nDesktops > 9 ? 9 : this.nDesktops {
            key := prefix . A_Index
            callback := ObjBindMethod(object, methodName, A_Index)
            Hotkey, %key%, %callback%, On
        }
        if (this.nDesktops >= 10) {
            key := prefix . 0
            callback := ObjBindMethod(object, methodName, 10)
            Hotkey %prefix%0, %callback%, On
        }
    }
}
