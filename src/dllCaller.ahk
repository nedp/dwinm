/*
 * Calls DLLs for moving windows between desktops.
 */
class DllCaller {
    callDll(nBits) {
        static WH_GETMESSAGE := 3

        if (!nBits) {
            Logger.error("DllCaller#callDll: Invalid arg! Need either 64 or 32")
            return false
        }

        libraryFileName := "..\dll\hook-" nBits ".dll"

        ;; Load the custom dll
        libraryHandle := DllCall("LoadLibrary", "Str", libraryFileName, "Ptr")
        if (ErrorLevel != 0) {
            Logger.error("DllCaller#callDll: Failed to load library: " A_LastError)
            return false
        }

        ;; Get the address of the move desktop callback
        moveDesktopHookHandle := DllCall("GetProcAddress", Ptr, libraryHandle
            , Astr, "GetMsgProc", "Ptr")
        if (ErrorLevel != 0) {
            Logger.error("DllCaller#callDll: Failed to get hook handle: " A_LastError)
            return false
        }

        ;; Hook up the move desktop callback on WH_GETMESSAGE messages
        DllCall("user32.dll\SetWindowsHookEx", "Int"
            , WH_GETMESSAGE, "Ptr", moveDesktopHookHandle, "Ptr"
            , libraryHandle, "Ptr", 0)
        if (ErrorLevel != 0) {
            Logger.error("DllCaller#callDll: Failed to set up callback: " A_LastError)
            return false
        }

        return true
    }
}
