/*
 * Logs things to a tooltip, remembering everything it logs.
 *
 * Not meant to be instantiated; just call methods directly on the class.
 */
class Logger {

    /*
     * Higher number is lower priority.
     */
    static Levels := { NONE: -1, -1: "NONE"
                     , FATAL: 0, 0: "FATAL"
                     , ERROR: 1, 1: "ERROR"
                     , WARNING: 2, 2: "WARNING"
                     , INFO: 3, 3: "INFO"
                     , DEBUG: 4, 4: "DEBUG" }

    static level := Logger.Levels.DEBUG

    /*
     * Sets the maximum level for logging.
     *
     * Messages above this level will be suppressed.
     */
    setLevel(level) {
        Logger.level := level
    }

    /*
     * Logs a message at the specified level, if it is below Logger.level.
     */
    logAtLevel(level, message) {
        static log := ""
        if (level > Logger.level) {
            return
        }

        time := ""
        FormatTime time, A_Now, yyyy-MM-dd HH:mm:ss

        log .= time " " this.Levels[level] ": " message

        ToolTip %log%, this.tooltip.x, this.tooltip.y, this.tooltip.id

        log .= "`n"

        return
    }

    /*
     * Logs a message at the FATAL level.
     *
     * Should be used for information about fatal errors.
     */
    fatal(message) {
        Logger.logAtLevel(Logger.Levels.FATAL, message)
    }

    /*
     * Logs a message at the ERROR level.
     *
     * Should be used for information about exceptional cases.
     */
    error(message) {
        Logger.logAtLevel(Logger.Levels.ERROR, message)
    }

    /*
     * Logs a message at the WARNING level.
     *
     * Should be used for information about handled exceptional cases.
     */
    warning(message) {
        Logger.logAtLevel(Logger.Levels.WARNING, message)
    }

    /*
     * Logs a message at the INFO level.
     *
     * Should be used for general course-grain information.
     */
    info(message) {
        Logger.logAtLevel(Logger.Levels.INFO, message)
    }

    /*
     * Logs a message at the DEBUG level.
     *
     * Should be used for fine-grain debugging information.
     */
    debug(message) {
        Logger.logAtLevel(Logger.Levels.DEBUG, message)
    }
}

/*
 * Send keystrokes with minimal delay to mitigate flickering
 * and improve responsiveness.
 */
quickSend(toSend) {
    static quickDelay := 10
    oldDelay := A_KeyDelay
    SetKeyDelay % quickDelay

    SendEvent % toSend

    SetKeyDelay % oldDelay
    return
}

/*
 * Send keystrokes with a delay to improve reliability.
 */
slowSend(toSend) {
    static slowDelay := 60
    oldDelay := A_KeyDelay
    SetKeyDelay % slowDelay

    SendEvent % toSend

    SetKeyDelay % oldDelay
    return
}

closeMultitaskingViewFrame() {
    if (WinActive ahk_class MultitaskingViewFrame) {
        SendEvent #{Tab}
    }
}

openMultitaskingViewFrame() {
    if (!WinActive ahk_class MultitaskingViewFrame) {
        SendEvent #{Tab}
        WinWaitActive ahk_class MultitaskingViewFrame
    }
}

callFunction(possibleFunction) {
    if (IsFunc(possibleFunction)) {
        %possibleFunction%()
    } else if (IsObject(possibleFunction)) {
        possibleFunction.Call()
    } else if (IsLabel(possibleFunction)) {
        gosub % possibleFunction
    }
}

getIndexFromArray(searchFor, array) {
    loop % array.MaxIndex() {
        if (array[A_index] == searchFor) {
            return A_index
        }
    }
    return -1
}

/*
 * Refocus on the topmost window in the current desktop.
 */
refocus() {
    slowSend("!+{Esc}!{Esc}") ;; quickSend is dodgy with focusing.
}
