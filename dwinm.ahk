/*
 * Copyright 2016 Ned Pummeroy
 */

#UseHook On
#NoEnv
#Warn

#SingleInstance
    PASSTHROUGH := ViManager.PASSTHROUGH
    NORMAL := ViManager.NORMAL
    SELECT := ViManager.SELECT
    INSERT := ViManager.INSERT

    CoordMode ToolTip, Screen

    main := new DWM()
    vim := new ViManager()
return

class DWM {
    static DESKTOP_TOOLTIP := 1
    static VI_TOOLTIP := 2

    static DESKTOP_TOOLTIP_X := 64
    static VI_TOOLTIP_X := 80

    static NUM_DESKTOPS := 10

    desktopChanger := new DesktopChanger(DWM.NUM_DESKTOPS
            , {id: DWM.DESKTOP_TOOLTIP, x: DWM.DESKTOP_TOOLTIP_X})
    windowMover := new WindowMover()
    hotkeyManager := new HotkeyManager(this.desktopChanger, this.windowMover)

    __new() {
        this.hotkeyManager
            .goToDesktop("#")
            .moveWindowToDesktop("#+")
            .goToOtherDesktop("#Tab")
            .resyncDesktops("#Enter")
    }
}

class ViManager {
    static PASSTHROUGH := "PASSTHROUGH"
    static NORMAL := "NORMAL"
    static SELECT := "SELECT"
    static INSERT := "INSERT"

    mode := ViManager.PASSTHROUGH
    clear := ObjBindMethod(this, "_clearTooltip")

    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, DWM.VI_TOOLTIP_X, 0, DWM.VI_TOOLTIP

        if (mode == ViManager.PASSTHROUGH) {
            clear := this.clear
            SetTimer %clear%, -1000
        }
    }

    hasMode(modes*) {
        thismode := this.mode
        for _, mode in modes {
            if (this.mode == mode) {
                return True
            }
        }
        return False
    }

    _clearTooltip() {
        if (this.mode == ViManager.PASSTHROUGH) {
            ToolTip, , , , this.toolTipNumber
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

#If vim.hasMode(PASSTHROUGH)
    !Tab Up::
        Send ^!{Tab}^+!{Tab}
        vim.setMode(SELECT)
    return

    #+j::vim.setMode(SELECT)

    #j::Send !{Esc}
    #k::Send !+{Esc}

    #Escape::vim.setMode(NORMAL)

#If vim.hasMode(NORMAL)
    *Escape::vim.setMode(PASSTHROUGH)
    i::vim.setMode(INSERT)

#If vim.hasMode(INSERT)
    Escape::vim.setMode(NORMAL)

#If vim.hasMode(SELECT)
    ~*Escape::
    ~*Enter::
    ~^c::
    ~^x::
        vim.setMode(PASSTHROUGH)
    return

#If vim.hasMode(NORMAL, SELECT)
    h::Left
    j::Down
    k::Up
    l::Right

#If

;; Close window
#w::Send !{F4}

#^l::Send #l

#^q::Reload

#Space::LWin

#Enter::Return ; don't like narrator

#Include commonFunctions.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk
#Include dllWindowMover.ahk
