﻿/*
 * Unmodified work Copyright 2016 Joshua Graham
 */
class JPGIncWindowMoverClass
{
    moveActiveWindowToDesktopFunctionName := "moveActiveWindowToDesktop"
    moveToNextFunctionName := "moveActiveWindowToNextDesktop"
    moveToPreviousFunctionName := "moveActiveWindowToPreviousDesktop"

    __new()
    {
        this.dllWindowMover := new JPGIncDllWindowMover()
        this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
        this.monitorMapper := new MonitorMapperClass()
        return this
    }

    doPostMoveWindow()
    {
        callFunction(this._postMoveWindowFunctionName)
        return this
    }

    moveActiveWindowToDesktop(targetDesktop, follow := false)
    {
        if(this.dllWindowMover.isAvailable())
        {
            this.dllWindowMover.moveActiveWindowToDesktop(targetDesktop)
            Send !+{Esc}!{Esc}
        } else
        {
            currentDesktop := this.desktopMapper.getDesktopNumber()
            if(currentDesktop == targetDesktop)
            {
                return this
            }
            numberOfTabsNeededToSelectActiveMonitor := this.monitorMapper.getRequiredTabCount(WinActive("A"))
            numberOfDownsNeededToSelectDesktop := this.getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)

            openMultitaskingViewFrame()
            slowSend("{tab " numberOfTabsNeededToSelectActiveMonitor "}")
            slowSend("{Appskey}m{Down " numberOfDownsNeededToSelectDesktop "}{Enter}")
            closeMultitaskingViewFrame()
        }

        this.doPostMoveWindow()

        return    this
    }

    moveActiveWindowToNextDesktop(follow := false)
    {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        return this.moveActiveWindowToDesktop(currentDesktop + 1, follow)
    }

    moveActiveWindowToPreviousDesktop(follow := false)
    {
        currentDesktop := this.desktopMapper.getDesktopNumber()
        if(currentDesktop == 1)
        {
            return this
        }
        return this.moveActiveWindowToDesktop(currentDesktop - 1, follow)
    }

    getNumberOfDownsNeededToSelectDesktop(targetDesktop, currentDesktop)
    {
        ; This part figures out how many times we need to push down within the context menu to get the desktop we want.
        if (targetDesktop > currentDesktop)
        {
            targetDesktop -= 2
        }
        else
        {
            targetdesktop--
        }
        return targetDesktop
    }
}
