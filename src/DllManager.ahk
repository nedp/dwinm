/*
 * Responsible for managing the interface between the main
 * process and external autohotkey processes which run DLLs.
 */
class DllManager {

    static LOADER := A_ScriptDir "\..\dll\dllCaller.ahk"

    static ahkPath := ""
    static pid := DllCall("GetCurrentProcessId")

    static 32BitMoverPID := 0
    static 64BitMoverPID := 0

    __new() {
        SplitPath A_AhkPath, _, path
        this.ahkPath := path
    }

    is32BitAvailable() {
        if (this.32BitMoverPID != 0) {
            process exist, % this.32BitMoverPID
            if (ErrorLevel == 0) {
                this.32BitMoverPID := 0
                Logger.info(this.__class ": 32 bit mover missing")
            }
        }
        return this.32BitMoverPID != 0
    }

    is64BitAvailable() {
        if (this.64BitMoverPID != 0) {
            process exist, % this.64BitMoverPID
            if (ErrorLevel == 0) {
                this.64BitMoverPID := 0
                Logger.info(this.__class ": 64 bit mover missing")
            }
        }
        return this.64BitMoverPID != 0
    }

    start32BitMover() {
        Logger.info(this.__class ": creating 32bit mover")

        Run % this.ahkPath "\AutoHotkeyU32.exe " this.LOADER " " this.pid " 32"
            , %A_ScriptDir%, useerrorlevel, pid
        if (ErrorLevel) {
            Logger.debug("Error starting 32bit dllCaller: " A_LastError)
            return false
        }
        this.32BitMoverPid := pid
        Logger.info("32bit mover created with pid: " this.32BitMoverPid)

        return true
    }

    start64BitMover() {
        Logger.info(this.__class ": creating 64bit mover")

        Run % this.ahkPath "\AutoHotkeyU64.exe " this.LOADER " " this.pid " 64"
            , %A_ScriptDir%, useerrorlevel, pid
        if (ErrorLevel) {
            Logger.debug("Error starting 64bit dllCaller: " A_LastError)
            return false
        }
        this.64BitMoverPid := pid
        Logger.info("64bit mover created with pid: " this.64BitMoverPid)

        return true
    }
}
