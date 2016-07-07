/*
 * A function to sleep for a specified amount of time.
 */
sleep(milliseconds) {
    Sleep, milliseconds
}

class CarefulObject {
    __call(name, _*) {
        throw Exception("A nonexisting method was invoked. "
            . "Specifically: " this.__class "#" name, -1)
    }

    __get(name, _*) {
        throw Exception("A nonexisting property was accessed. "
            . "Specifically: " this.__class "#" name, -1)
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
    ;; Suspends hotkeys because the simulated shift can cause windows
    ;; to be moved and it's a real pain in the arse.
    ;; TODO fix it so this isn't required.
    ;; The clunkiness of having hotkeys suspended is only slightly less
    ;; of a pain in the arse.
    wasCritical := A_IsCritical
    Critical
    wasSuspended := A_IsSuspended
    Suspend

    slowSend("!+{Esc}!{Esc}") ;; quickSend is dodgy with focusing.

    if (!wasSuspended) {
        Suspend Off
    }
    Critical %wasCritical%
}
