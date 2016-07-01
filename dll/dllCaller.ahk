/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
parentPID = %1%
32Or64 = %2%
SetWorkingDir, % A_ScriptDir
if(parentPID && 32Or64)
{
    libraryFileName := "hook " 32Or64 ".dll"

    ; Load the custom dll
    libraryHandle := DllCall("LoadLibrary", "Str", "hook " 32Or64 ".dll", "Ptr")

    ; Get the address of the move desktop callback
    moveDesktopHookHandle := DllCall("GetProcAddress", Ptr, libraryHandle
        , Astr, "GetMsgProc", "Ptr")

    ; Hook up the move desktop callback on WH_GETMESSAGE messages
    WH_GETMESSAGE := 3
    didTheCallSucceed := DllCall("user32.dll\SetWindowsHookEx", "Int"
        , WH_GETMESSAGE, "Ptr", moveDesktopHookHandle, "Ptr"
        , libraryHandle, "Ptr", 0)
    if(!didTheCallSucceed)
    {
        MsgBox the call did not succeed for me`n %A_LastError%
        ExitApp
    }

    Process, waitclose, % parentPID
} else {
    MsgBox "Invalid command line args`nneed a process id and a string"
           . "'64' or '32' %0% args were recieved."
}
ExitApp
