#UseHook On
#NoEnv
#Warn
#SingleInstance

SetWorkingDir %A_ScriptDir%
CoordMode ToolTip, Screen
SetTitleMatchMode RegEx

DWM := new DWinM()

DWM.hotkeyManager
    .swapDesktops("!Tab")
    .pickDesktop("!")
    .moveWindowToDesktop("!+")
    .resync("!0")

#If DWM.hasMode(DWM.Modes.DESKTOP)
    ;; Change modes.
    !s::DWM.setMode(DWM.Modes.SELECT)
    !Escape::DWM.setMode(DWM.Modes.NORMAL)
    !i::DWM.setMode(DWM.Modes.PASSTHROUGH)

    ;; Browse windows.
    ^!Tab::
        Send ^!{Tab}^+!{Tab}
        DWM.setMode(DWM.Modes.SELECT)
    return

    ;; Cycle windows.
    !j::Send !{Esc}
    !k::Send !+{Esc}

    ;; Close window.
    !w::Send !{F4}

    ;; Lock the screen.
    !^l::Run rundll32.exe user32.dll LockWorkStation, %A_Windir%\System32

    ;; Open the start menu.
    !Space::Send ^{Escape}

    ;; Reload dwinm.
    !^q::Reload

#If DWM.hasMode(DWM.Modes.NORMAL)
    ;; Change modes.
    *Escape::DWM.setMode(DWM.Modes.DESKTOP)
    i::DWM.setMode(DWM.Modes.INSERT)

    ;; Use Windows' pauper tiling.
    #h::#Left
    #j::#Down
    #k::#Up
    #l::#Right

#If DWM.hasMode(DWM.Modes.INSERT)
    ;; Change modes.
    ::kj::
    ::jk::
        DWM.setMode(DWM.Modes.NORMAL)
    return

    ^w::Send +^{Left}^x
    ^u::Send +{Home}^x

#If DWM.hasMode(DWM.Modes.SELECT)
    ;; Change modes.
    ~*Escape::
    ~*Enter::
    ~*Space::
    ~^c::
    ~^x::
        DWM.setMode(DWM.Modes.DESKTOP)
    return

    ;; Movement
    h::Left
    j::Down
    k::Up
    l::Right

#If DWM.hasMode(DWM.Modes.PASSTHROUGH)
    ;; Change modes.
    ^!Escape::DWM.setMode(DWM.Modes.DESKTOP)

#IfWinActive ahk_exe chrome.exe|firefox.exe|explorer.exe
    ;; Emacsish bindings for a) easier URL entry and b)
    ;; avoiding accidentally nuking windows with ^w.

    ^f::Right
    !f::^Right
    ^b::Left
    !b::^Left

    ^a::Home
    ^e::End

    ^n::Down
    ^p::Up

    ^h::Send +{Left}^x
    ^w::Send +^{Left}^x

    ^d::Send +{Right}^x
    !d::Send +^{Right}^x

    ^k::Send +{End}^x
    ^u::Send {Home}+{End}^x

    ^y::^v

#If

class DWinM {
    static Modes := { DESKTOP: "DESKTOP"
                    , NORMAL: "NORMAL"
                    , SELECT : "SELECT"
                    , INSERT: "INSERT"
                    , PASSTHROUGH: "PASSTHROUGH" }

    static TOOLTIP_TIMEOUT := 1000

    mode := this.Modes.DESKTOP

    static DESKTOP_TOOLTIP := 1
    static MODE_TOOLTIP := 2

    static DESKTOP_TOOLTIP_X := 62
    static MODE_TOOLTIP_X := 81

    static NUM_DESKTOPS := 9

    Functions := { RESYNC: "resync" }

    nDesktops := this.NUM_DESKTOPS

    virtualDesktopManager := new VirtualDesktopManager()
    desktopMapper := new DesktopMapper(this.virtualDesktopManager)

    desktopChanger := new DesktopChanger(this, this.desktopMapper
        , {id: this.DESKTOP_TOOLTIP, x: this.DESKTOP_TOOLTIP_X})
    windowMover := new WindowMover()
    hotkeyManager
        := new HotkeyManager(this.desktopChanger, this.windowMover, this)

    resync() {
        this.desktopMapper.resync()
        this.desktopChanger.resync()
        this.windowMover.resync()
    }

    clear := ObjBindMethod(this, "_clearTooltip")
    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, this.MODE_TOOLTIP_X, 0, this.MODE_TOOLTIP

        if (mode == this.Modes.DESKTOP) {
            clear := this.clear
            SetTimer %clear%, % -this.TOOLTIP_TIMEOUT
        }
    }

    enterInsertMode() {
        this.setMode(this.Modes.INSERT)
    }

    sendAndInsert(sendKeys) {
        Send %sendKeys%
        this.enterInsertMode()
    }

    hasMode(modes*) {
        thismode := this.mode
        for _, mode in modes {
            if (this.mode == mode) {
                return true
            }
        }
        return false
    }

    _clearTooltip() {
        if (this.mode == this.Modes.DESKTOP) {
            ToolTip, , , , this.MODE_TOOLTIP
        }
    }
}

#InputLevel 0

#Include %A_ScriptDir%/helpers.ahk

#Include %A_ScriptDir%/DesktopChanger.ahk
#Include %A_ScriptDir%/DesktopMapper.ahk
#Include %A_ScriptDir%/HotkeyManager.ahk
#Include %A_ScriptDir%/MonitorMapper.ahk
#include %A_ScriptDir%/VirtualDesktopManager.ahk
#Include %A_ScriptDir%/WindowMover.ahk
