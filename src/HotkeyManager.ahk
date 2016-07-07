class HotkeyManager extends CarefulObject {

    __new(desktopPicker, windowMover, dwm) {
        this.desktopPicker := desktopPicker
        this.windowMover := windowMover
        this.dwm := dwm
    }

    /*
     * Set up hotkeys to move the active window to target desktops.
     *
     * Sets up `this.nDesktops` hotkeys of the form `prefix<N>`,
     * where <N> is a number key.
     */
    moveWindowToDesktop(prefix) {
        object := this.windowMover
        method := "moveActiveToDesktop"

        Hotkey If, DWM.hasMode(DWM.Modes.DESKTOP)
        this._setUpNumberedHotkey(prefix, object, method)
        Hotkey If

        return this
    }

    /*
     * Set up hotkeys to pick another desktop.
     *
     * Sets up `this.nDesktops` hotkeys of the form `prefix<N>`,
     * where <N> is a number key.
     */
    pickDesktop(prefix) {
        object := this.desktopPicker
        method := "pickDesktop"

        Hotkey If, DWM.hasMode(DWM.Modes.DESKTOP)
        this._setUpNumberedHotkey(prefix, object, method)
        Hotkey If

        return this
    }

    /*
     * Set up hotkeys to swap to the 'other' desktop and pick a new desktop.
     *
     * Sets up `this.nDesktops` hotkeys of the form `prefix<N>`,
     * where <N> is a number key.
     */
    swapAndPickDesktop(prefix) {
        Logger.trace("HotkeyManager#swapAndPickDesktop: prefix=" prefix)

        object := this.desktopPicker
        method := "hardPickDesktop"

        Hotkey If, DWM.hasMode(DWM.Modes.DESKTOP)
        this._setUpNumberedHotkey(prefix, object, method)
        Hotkey If

        return this
    }

    /*
     * Set up a hotkey to go to the 'other' desktop.
     */
    swapDesktops(hotkeyKey) {
        object := this.desktopPicker
        method := "swapDesktops"

        Hotkey If, DWM.hasMode(DWM.Modes.DESKTOP)
        callback := ObjBindMethod(object, method)
        Hotkey %hotkeyKey%, %callback%, On, 1
        Hotkey If

        return this
    }

    /*
     * Set up a hotkey to resynchronise the system.
     */
    resync(hotkeyKey) {
        object := this.dwm
        method := "resync"

        Hotkey If, DWM.hasMode(DWM.Modes.DESKTOP)
        callback := ObjBindMethod(object, method)
        Hotkey %hotkeyKey%, %callback%, On, 1
        Hotkey If

        return this
    }

    ;; Set up `nDesktops` hotkeys of the form `prefix<N>`, where <N> is
    ;; a number key.
    ;;
    ;; The hotkeys will call the specified method on the specified
    ;; object.
    ;; There will be one argument matching <N>, except when N=0;
    ;; the argument for N=0 will be 10.
    _setUpNumberedHotkey(prefix, object, methodName) {
        static modKeyRegex := "[#!^+<>*~$]*"
        static alreadyHasAmpersand := ".*&\s*^"
        if (!RegExMatch(prefix, modKeyRegex "|" alreadyHasAmpersand)) {
            prefix .= " & "
        }
        loop % this.dwm.nDesktops > 9 ? 9 : this.dwm.nDesktops {
            key := prefix . A_Index
            Logger.trace("HotkeyManager#_setUpNumberedHotkey: Adding " key "->" methodName "(" A_Index ")")
            callback := ObjBindMethod(object, methodName, A_Index)
            Hotkey, %key%, %callback%, On, 1
        }
        if (this.dwm.nDesktops >= 10) {
            key := prefix . 0
            Logger.trace("HotkeyManager#_setUpNumberedHotkey: Adding " key "->" methodName "(0)")
            callback := ObjBindMethod(object, methodName, 10)
            Hotkey %key%, %callback%, On, 1
        }
    }
}
