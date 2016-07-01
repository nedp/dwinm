#UseHook On
#NoEnv
#Warn

#SingleInstance
    PASSTHROUGH := ViManager.PASSTHROUGH
    NORMAL := ViManager.NORMAL
    SELECT := ViManager.SELECT
    INSERT := ViManager.INSERT

    CoordMode ToolTip, Screen

    dwm := new DWinM()

    vim := new ViManager(dwm)
return

class DWinM {
    static DESKTOP_TOOLTIP := 1
    static VI_TOOLTIP := 2

    static DESKTOP_TOOLTIP_X := 62
    static VI_TOOLTIP_X := 81

    static NUM_DESKTOPS := 9

    functions := { RESYNC: "resync" }

    nDesktops := this.NUM_DESKTOPS

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

    mode := ViManager.PASSTHROUGH
    clear := ObjBindMethod(this, "_clearTooltip")

    __new(tooltip) {
        this.tooltip := tooltip
    }

    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, this.tooltip.x, 0, this.id

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

#Include helpers.ahk

#Include DesktopChanger.ahk
#Include DesktopMapper.ahk
#Include HotkeyManager.ahk
#Include MonitorMapper.ahk
#include VirtualDesktopManager.ahk
#Include WindowMover.ahk
