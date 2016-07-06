/*
 * A function to sleep for a specified amount of time.
 */
sleep(milliseconds) {
    Sleep, milliseconds
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
