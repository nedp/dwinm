/*
 * Copyright 2016 Ned Pummeroy
 */

#UseHook On

#SingleInstance
    VI_TOOLTIP := 1
    VI_TOOLTIP_X := 80
    DESKTOP_TOOLTIP := 2

    NUM_DESKTOPS := 10

    globalDesktopManager := new JPGIncDesktopManagerClass(NUM_DESKTOPS, DESKTOP_TOOLTIP)
    globalDesktopManager.setGoToDesktop("#")
        .setMoveWindowToDesktop("#+")
        .setGoToRecentDesktop("#Tab")
        .setResyncDesktops("#Enter")

    viManager := new ViManager(VI_TOOLTIP, VI_TOOLTIP_X)

    PASSTHROUGH := ViManager.PASSTHROUGH
    NORMAL := ViManager.NORMAL
    SELECT := ViManager.SELECT
    INSERT := ViManager.INSERT

    CoordMode ToolTip, Screen
return

class ViManager
{
    static PASSTHROUGH := "PASSTHROUGH"
    static NORMAL := "NORMAL"
    static SELECT := "SELECT"
    static INSERT := "INSERT"

    mode := ViManager.PASSTHROUGH

    __new(toolTipNumber, tooltipX) {
        this.toolTipNumber := toolTipNumber
        this.clear := ObjBindMethod(this, "_clearTooltip")
        this.tooltipX := tooltipX
    }

    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, %x%, 0, this.toolTipNumber

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

#If viManager.hasMode(PASSTHROUGH)
    !Tab Up::
        Send ^!{Tab}^+!{Tab}
        viManager.setMode(SELECT)
    return

    #+j::viManager.setMode(SELECT)

    #j::Send !{Esc}
    #k::Send !+{Esc}

    #Escape::viManager.setMode(NORMAL)

#If viManager.hasMode(NORMAL)
    *Escape::viManager.setMode(PASSTHROUGH)
    i::viManager.setMode(INSERT)

#If viManager.hasMode(INSERT)
    Escape::viManager.setMode(NORMAL)

#If viManager.hasMode(SELECT)
    ~*Escape::
    ~*Enter::
    ~^c::
    ~^x::
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

#^q::Reload

#Space::LWin

#Enter::Return ; don't like narrator

#Include commonFunctions.ahk
#Include desktopManager.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk
#Include dllWindowMover.ahk
