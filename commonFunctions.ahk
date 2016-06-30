/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */

debugger(message) {
    ;~ ToolTip, % message
    ;~ sleep 100
    return
}

/* Send keystrokes with no delay to mitigate flickering
 * and improve responsiveness.
 */
quickSend(toSend) {
    oldDelay := A_KeyDelay
    SetKeyDelay 0

    Send % toSend

    SetKeyDelay % oldDelay
    return
}

/* Send keystrokes with a delay to improve reliability.
 */
slowSend(toSend) {
    static SEND_DELAY := 60
    oldDelay := A_KeyDelay
    SetKeyDelay % SEND_DELAY

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
