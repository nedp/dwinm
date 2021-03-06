﻿;taken from optimist__prime https://autohotkey.com/boards/viewtopic.php?t=9224
class MonitorMapperClass extends CarefulObject {
    ; This part figures out how many times we need to hit Tab to get to the
    ; monitor with the window we are trying to send to another desktop.
    getRequiredTabCount(hwnd) {
        activemonitor := this.getWindowsMonitorNumber(hwnd)

        SysGet, monitorcount, MonitorCount
        SysGet, primarymonitor, MonitorPrimary

        If (activemonitor > primarymonitor)
        {
            tabCount := activemonitor - primarymonitor
        }
        else If (activemonitor < primarymonitor)
        {
            tabCount := monitorcount - primarymonitor + activemonitor
        }
        else
        {
            tabCount := 0
        }
        tabCount *= 2

        return tabCount
    }

    /*
     * This function returns the monitor number of the window with the given hwnd
     */
    getWindowsMonitorNumber(hwnd) {
        WinGetPos, x, y, width, height, % "Ahk_id" hwnd
        Logger.debug("Window Position/Size:`nX: " X "`nY: " Y "`nWidth: " width "`nHeight: " height)
        SysGet, monitorcount, MonitorCount
        SysGet, primarymonitor, MonitorPrimary
        Logger.debug("Monitor Count: " MonitorCount)
        Loop %monitorcount%
        {
            SysGet, mon, Monitor, %a_index%
            Logger.debug("Primary Monitor: " primarymonitor "`nDistance between monitor #" a_index "'s right border and Primary monitor's left border (Left < 0, Right > 0):`n" monRight "px")
            If (x < monRight - width / 2 || monitorcount = a_index)
            {
                return %a_index%
            }
        }
    }
}
