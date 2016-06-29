/*
 * Copyright 2016 Ned Pummeroy
 */

#UseHook On

#SingleInstance
    globalDesktopManager := new JPGIncDesktopManagerClass()
    globalDesktopManager.setGoToDesktop("#")
        .setMoveWindowToDesktop("#+")
        .setGoToRecentDesktop("#Tab")
        .setResyncDesktop("#Enter")

    viManager := new ViManager(1)

    PASSTHROUGH := ViManager.PASSTHROUGH
    NORMAL := ViManager.NORMAL
    SELECT := ViManager.SELECT
    INSERT := ViManager.INSERT
return

class ViManager
{
    static PASSTHROUGH := "PASSTHROUGH"
    static NORMAL := "NORMAL"
    static SELECT := "SELECT"
    static INSERT := "INSERT"

    mode := ViManager.PASSTHROUGH

    __new(toolTipNumber) {
        this.toolTipNumber := toolTipNumber
        this.clear := ObjBindMethod(this, "_clearTooltip")
    }

    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, 0, 0, this.toolTipNumber

        if (mode == ViManager.PASSTHROUGH) {
            clear := this.clear
            SetTimer %clear%, -1000
        }
    }

    hasMode(modes*) {
        thismode := this.mode
        for _, mode in modes
            if (this.mode == mode)
                return True
        return False
    }

    _clearTooltip() {
        if (this.mode == ViManager.PASSTHROUGH) {
            ToolTip, , 0, 0, this.toolTipNumber
        }
    }
}

#InputLevel 1
    *CapsLock::Send {Esc Down}
    *CapsLock Up::Send {Esc Up}

    *LWin::Send {LAlt Down}
    *LWin Up::Send {LAlt Up}

    *LAlt::Send {LWin Down}
    *LAlt Up::Send {LWin Up}

#InputLevel 0

#If viManager.hasMode(PASSTHROUGH)
    !Tab Up::
        Send ^!{Tab}^+!{Tab}
        viManager.setMode(SELECT)
    return

    #+j::viManager.setMode(SELECT)

    #j::Send !{Esc}
    #k::Send !+{Esc}

    ;#CapsLock Up::
    #Escape Up::
        viManager.setMode(NORMAL)
        refocus()
    return

#If viManager.hasMode(NORMAL)
    CapsLock::
    Escape::
        viManager.setMode(PASSTHROUGH)
    return
    i::viManager.setMode(INSERT)

#If viManager.hasMode(INSERT)
    CapsLock::
    Escape::
        viManager.setMode(NORMAL)
    return

#If viManager.hasMode(SELECT)
    ~CapsLock::
    ~Escape::
    ~Enter::
        viManager.setMode(PASSTHROUGH)
    return

#If viManager.hasMode(NORMAL, SELECT)
    h::Left
    j::Down
    k::Up
    l::Right

#If

;; Close window
#w::Send !{F4}

#^l::Send #l

#Space::LWin

#Enter::Return ; don't like narrator

#Include desktopManager.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include commonFunctions.ahk
#Include hotkeyManager.ahk
#Include dllWindowMover.ahk
