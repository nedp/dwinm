#UseHook On
#NoEnv
#Warn
#SingleInstance

SetWorkingDir %A_ScriptDir%
CoordMode ToolTip, Screen
SetTitleMatchMode RegEx
SendMode InputThenPlay

Logger.setLevel(Logger.Levels.NONE)
Logger.tooltip := DWinM.LOGGER_TOOLTIP
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

    ;; Browse windows and desktops.
    ~#Tab::DWM.setMode(DWM.Modes.SELECT)

    ;; Cycle windows.
    !j::Send !{Esc}
    !k::Send !+{Esc}

    ;; Use Windows' pauper tiling.
    !+h::SendEvent #{Left}
    !+j::SendEvent #{Down}
    !+k::SendEvent #{Up}
    !+l::SendEvent #{Right}

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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Basic hardcoded commands.
    ;; TODO Implement repeat/command/movement composition.

#HotString * c ? z si

    ;; Insertion
    i::DWM.enterInsertMode()
    +i::DWM.sendAndInsert("{Home}")
    a::DWM.sendAndInsert("{Right}")
    +a::DWM.sendAndInsert("{End}")

    ;; TODO R

    o::DWM.sendAndInsert("{End}{Enter}")
    +o::DWM.sendAndInsert("{Up}{End}{Enter}")

    ;; Delete
    ::X::
    ::dh::
        Send +{Left}^x
    return

    ::x::
    ::dl::
        Send +{Right}^x
    return

    ::dj::{Up}{End}+{Down 2}+{End}^x
    ::dk::{Down}{Home}+{Up 2}+{Home}^x

    ::dw::+^{Right}^x
    ::db::+^{Left}^x

    ::d0::+{Home}^x

    ::d$::
    ::D::
        Send +{End}^x
    return

    ::dd::
        Send {Home}+{End}^x{BackSpace}{Right}
    return

    ;; Change
    ::ch::
        DWM.sendAndInsert("+{Left}^x")
    return

    s::
    ::cl::
        DWM.sendAndInsert("+{Right}^x")
    return

    ::cj::
        DWM.sendAndInsert("{Up}{End}+{Down 2}+{End}^x{Enter}")
    return
    ::ck::
        DWM.sendAndInsert("{Up}{Home}+{Down}+{End}^x")
    return

    ::cw::
        DWM.sendAndInsert("+^{Right}^x")
    return
    ::cb::
        DWM.sendAndInsert("+^{Left}^x")
    return

    ::c0::
        DWM.sendAndInsert("+{Home}^x")
    return

    +C::
    ::c$::
        DWM.sendAndInsert("+{End}^x")
    return

    +S::
    ::cc::
        DWM.sendAndInsert("{Home}+{End}^x")
    return

    ;; Yank and Put
    ::p::^v
    ::P::{Left}^v

    ::yh::+{Left}^c
    ::yk::+{Right}^c

    ::yj::{Up}{End}+{Down 2}+{End}^c
    ::yk::{Down}{Home}+{Up 2}+{Home}^c

    ::yw::+^{Right}^c
    ::yb::+^{Left}^c

    ::y0::+{Home}^c
    ::y$::+{End}^c

    ::+y::
    ::yy::
        Send {Home}+{End}^c
    return

    ;; History
    ::u::^z
    ^r::^y

    ;; Movement
    ::h::Left
    ::j::Down
    ::k::Up
    ::l::Right

    ::b::^{Left}
    ::w::^{Right}

    ::0::{Home}
    ::$::{End}

    ::/::^f


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

    static DESKTOP_TOOLTIP := {id: 1, x: 0, y: 0}
    static MODE_TOOLTIP := {id: 2, x: 0, y: 20}
    static LOGGER_TOOLTIP := {id: 3, x: 0, y: 40}

    static NUM_DESKTOPS := 9

    static Functions := { RESYNC: "resync" }

    tooltip := this.MODE_TOOLTIP

    mode := this.Modes.DESKTOP

    nDesktops := this.NUM_DESKTOPS

    virtualDesktopManager := new VirtualDesktopManager()
    desktopMapper := new DesktopMapper(this.virtualDesktopManager)

    desktopChanger
        := new DesktopChanger(this, this.desktopMapper, this.DESKTOP_TOOLTIP)
    windowMover := new WindowMover()
    hotkeyManager
        := new HotkeyManager(this.desktopChanger, this.windowMover, this)

    __new() {
    }

    resync() {
        this.desktopMapper.resync()
        this.desktopChanger.resync()
        this.windowMover.resync()
    }

    clear := ObjBindMethod(this, "_clearTooltip")
    setMode(mode) {
        this.mode := mode

        ToolTip %mode% mode, this.tooltip.x, this.tooltip.y, this.tooltip.id

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
            ToolTip, , , , this.tooltip.id
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
