#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk

class FunctionMocks {
    static calls := {}

    reset() {
        this.calls := {}
    }

    assert() {
        for function, calls in this.calls {
            msg := "Expectation failed for " function " calls."
            Yunit.assertEq(calls.want, calls.got, msg)
        }
    }

    allow(name, returnValue := "") {
        this.calls[name] := { allow: true, value: returnValue }
    }

    expect(name, nTimes, returnValue := "") {
        this.calls[name] := { want: nTimes, got: 0, value: returnValue }
    }

    disallow(name) {
        this.calls[name] := { allow: false }
    }

    __call(name, _*) {
        value := this.calls[name].value
        if (this.calls[name].allow) {
            return value
        }

        want := this.calls[name].want

        Yunit.assert(want, "unexpected function call: " name, -2)

        this.calls[name].got += 1
        got := this.calls[name].got

        Yunit.assertLessOrEq(got, want , "too many " name " calls.")
        return value
    }
}

refocus() {
    FunctionMocks.__call("refocus")
}

quickSend(keys) {
    FunctionMocks.__call("quickSend")
}

slowSend(keys) {
    FunctionMocks.__call("slowSend")
}

class Mock {

    __new(calls, other) {
        for key, val in other {
            if (!IsObject(key)) {
                this[key] := val
            }
        }
    }

    __call(name, _*) {
        value := this.____calls[this, name].value
        if (this.____calls[this, name].allow) {
            return value
        }

        want := this.____calls[this, name].want

        Yunit.assert(want, "unexpected method call: " name, -1)

        this.____calls[this, name].got += 1
        got := this.____calls[this, name].got

        Yunit.assertLessOrEq(got, want , "too many " name " calls.")
        return value
    }

    __get(name, _*) {
        Yunit.fail("unexpected property access: " name, -1)
    }
}

class HotMocks {

    calls := {}
    returnValue := {}

    assert() {
        for mock, methods in this.calls {
            for method, calls in methods {
                msg := "Expectation failed for " method " calls."
                Yunit.assertEq(calls.want, calls.got, msg)
            }
        }
    }

    allow(target, name, returnValue := "") {
        target.____calls := this.calls
        this.calls[target, name] := { allow: true, value: returnValue }
    }

    expect(target, name, nTimes, returnValue := "") {
        target.____calls := this.calls
        this.calls[target, name] := { want: nTimes, got: 0, value: returnValue }
    }

    disallow(target, name) {
        target.____calls := this.calls
        this.calls[target, name] := { allow: false }
    }
}
