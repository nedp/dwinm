/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */

debugger(message) {
    ;~ ToolTip, % message
    ;~ sleep 100
    return
}

/* Send keystrokes with minimal delay to mitigate flickering
 * and improve responsiveness.
 */
quickSend(toSend) {
    static quickDelay := 10
    oldDelay := A_KeyDelay
    SetKeyDelay % quickDelay

    Send % toSend

    SetKeyDelay % oldDelay
    return
}

/* Send keystrokes with a delay to improve reliability.
 */
slowSend(toSend) {
    static slowDelay := 60
    oldDelay := A_KeyDelay
    SetKeyDelay % slowDelay

    Send % toSend

    SetKeyDelay % oldDelay
    return
}

closeMultitaskingViewFrame() {
    if (WinActive ahk_class MultitaskingViewFrame) {
        Send #{tab}
    }
}


openMultitaskingViewFrame() {
    if (!WinActive ahk_class MultitaskingViewFrame) {
        Send #{tab}
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

getDesktopNumberFromHotkey(keyCombo) {
    number := RegExReplace(keyCombo, "[^\d]", "")
    return number == 0 ? 10 : number
}

getIndexFromArray(searchFor, array) {
    loop % array.MaxIndex() {
        if (array[A_index] == searchFor) {
            return A_index
        }
    }
    return -1
}

/* Refocuses on the topmost window in the current desktop.
 */
refocus() {
    slowSend("!+{Esc}!{Esc}") ;; quickSend is dodgy with focusing.
}
