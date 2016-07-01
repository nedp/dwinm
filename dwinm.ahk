#UseHook On
#NoEnv
#Warn
#SingleInstance

PASSTHROUGH := ViManager.PASSTHROUGH
NORMAL := ViManager.NORMAL
SELECT := ViManager.SELECT
INSERT := ViManager.INSERT

SetWorkingDir %A_ScriptDir%
CoordMode ToolTip, Screen

DWM := new DWinM()

return

class DWinM {
    static DESKTOP_TOOLTIP := 1
    static VI_TOOLTIP := 2

    static DESKTOP_TOOLTIP_X := 62
    static VI_TOOLTIP_X := 81

    static NUM_DESKTOPS := 9

    functions := { RESYNC: "resync" }

    nDesktops := this.NUM_DESKTOPS

    vim := new ViManager({id: this.VI_TOOLTIP, x: this.VI_TOOLTIP_X})

    virtualDesktopManager := new VirtualDesktopManager()
    desktopMapper := new DesktopMapper(this.virtualDesktopManager)

    desktopChanger := new DesktopChanger(this, this.desktopMapper
        , {id: this.DESKTOP_TOOLTIP, x: this.DESKTOP_TOOLTIP_X})
    windowMover := new WindowMover()
    hotkeyManager
        := new HotkeyManager(this.desktopChanger, this.windowMover, this)

    __new() {
        this.hotkeyManager
            .goToDesktop("#")
            .moveWindowToDesktop("#+")
            .goToOtherDesktop("#Tab")
            .resync("#0")
    }

    resync() {
        this.desktopMapper.resync()
        this.desktopChanger.resync()
        this.windowMover.resync()
    }
}

class ViManager {
    static PASSTHROUGH := "PASSTHROUGH"
    static NORMAL := "NORMAL"
    static SELECT := "SELECT"
    static INSERT := "INSERT"

    static TOOLTIP_TIMEOUT := 1000

    mode := ViManager.PASSTHROUGH
    clear := ObjBindMethod(this, "_clearTooltip")

    __new(tooltip) {
        this.tooltip := tooltip
    }

    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, this.tooltip.x, 0, this.tooltip.id

        if (mode == ViManager.PASSTHROUGH) {
            clear := this.clear
            SetTimer %clear%, % -this.TOOLTIP_TIMEOUT
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
            ToolTip, , , , this.tooltip.id
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

#If DWM.vim.hasMode(PASSTHROUGH)
    !Tab Up::
        Send ^!{Tab}^+!{Tab}
        DWM.vim.setMode(SELECT)
    return

    #+j::DWM.vim.setMode(SELECT)

    #j::Send !{Esc}
    #k::Send !+{Esc}

    #Escape::DWM.vim.setMode(NORMAL)

#If DWM.vim.hasMode(NORMAL)
    *Escape::DWM.vim.setMode(PASSTHROUGH)
    i::DWM.vim.setMode(INSERT)

#If DWM.vim.hasMode(INSERT)
    Escape::DWM.vim.setMode(NORMAL)

#If DWM.vim.hasMode(SELECT)
    ~*Escape::
    ~*Enter::
    ~^c::
    ~^x::
        DWM.vim.setMode(PASSTHROUGH)
    return

#If DWM.vim.hasMode(NORMAL, SELECT)
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

#Include %A_ScriptDir%/helpers.ahk

#Include %A_ScriptDir%/DesktopChanger.ahk
#Include %A_ScriptDir%/DesktopMapper.ahk
#Include %A_ScriptDir%/HotkeyManager.ahk
#Include %A_ScriptDir%/MonitorMapper.ahk
#include %A_ScriptDir%/VirtualDesktopManager.ahk
#Include %A_ScriptDir%/WindowMover.ahk
