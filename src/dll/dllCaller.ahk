/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
parentPID = %1%
32or64 = %2%

WH_GETMESSAGE := 3

SetWorkingDir %A_ScriptDir%

if (parentPID && 32or64) {
    libraryFileName := "hook-" 32or64 ".dll"

    ;; Load the custom dll
    libraryHandle := DllCall("LoadLibrary", "Str", "hook-" 32or64 ".dll", "Ptr")

    ;; Get the address of the move desktop callback
    moveDesktopHookHandle := DllCall("GetProcAddress", Ptr, libraryHandle
        , Astr, "GetMsgProc", "Ptr")

    ;; Hook up the move desktop callback on WH_GETMESSAGE messages
    ok := DllCall("user32.dll\SetWindowsHookEx", "Int"
        , WH_GETMESSAGE, "Ptr", moveDesktopHookHandle, "Ptr"
        , libraryHandle, "Ptr", 0)
    if (!ok) {
        MsgBox The call did not succeed:`n %A_LastError%
        ExitApp
    }

    Process, waitclose, % parentPID
} else {
    MsgBox "Invalid command line args!`n"
       . "Need 1) a PID and 2) either '64' or '32'.`n"
       . %0% " args were recieved."
}

ExitApp
