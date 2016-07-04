/*
 * Logs things to stdout if compiled, otherwise to a tooltip.
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
                     , DEBUG: 4, 4: "DEBUG"
                     , TRACE: 5, 5: "TRACE" }

    static level := Logger.Levels.WARNING

    static log := "Reload dwinm to clear this log:"

    /*
     * Sets the maximum level for logging.
     *
     * Messages above this level will be suppressed.
     */
    setLevel(level) {
        Logger.level := level
        this._log("Logging level set to " this.Levels[level])
    }

    /*
     * Logs a message at the specified level, if it is below Logger.level.
     */
    logAtLevel(level, message) {
        if (level <= Logger.level) {
            this._log(this.Levels[level] ": " message)
        }
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
     * Should be used for debugging information.
     */
    debug(message) {
        Logger.logAtLevel(Logger.Levels.DEBUG, message)
    }

    /*
     * Logs a message at the TRACE level.
     *
     * Should be used for tracing execution while debugging.
     */
    trace(message) {
        Logger.logAtLevel(Logger.Levels.TRACE, message)
    }

    _log(message) {
        time := ""
        FormatTime time, A_Now, yyyy-MM-dd HH:mm:ss

        msg := "`n" time " " message

        if (A_IsCompiled) {
            FileAppend %msg%, *
        } else {
            this.log .= msg
            ToolTip % this.log, this.tooltip.x, this.tooltip.y, this.tooltip.id
        }
    }

}
