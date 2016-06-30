/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
class WindowMover
{
    functions := {MOVE_ACTIVE: ObjBindMethod(this, "moveActiveToDesktop")}

    __new()
    {
        this.dllWindowMover := new JPGIncDllWindowMover()
        this.desktopMapper
            := new DesktopMapperClass(new VirtualDesktopManagerClass())
        this.monitorMapper := new MonitorMapperClass()
    }

    /* Move the active window to the specified desktop via the best
     * available method.
     */
    moveActiveToDesktop(targetDesktop, follow := false)
    {
        if (this.dllWindowMover.isAvailable()) {
            this.dllWindowMover.moveActiveWindowToDesktop(targetDesktop)
        } else {
            this._moveActiveToDesktopManually(targetDesktop)
        }

        Send !+{Esc}!{Esc} ;; Refocus the next remaining window.
        return this
    }

    ;; Move the active window to the specified desktop via keypresses.
    _moveActiveToDesktopManually(targetDesktop) {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        if (currentDesktop == targetDesktop) {
            return
        }

        openMultitaskingViewFrame()

        ;; Press tab to pick the active monitor.
        nTabs := this.monitorMapper.getRequiredTabCount(WinActive("A"))
        slowSend("{Tab " nTabs "}")

        ;; Open the context menu and press down to pick the desktop.
        nDowns := currentDesktop - 1
        ;; The current desktop doesn't appear in the menu.
        if (targetDesktop > currentDesktop) nDowns -= 1
        slowSend("{Appskey}m{Down " nDown "}{Enter}")

        closeMultitaskingViewFrame()
    }
}
