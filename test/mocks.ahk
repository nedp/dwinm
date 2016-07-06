#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk

class FunctionMocks {
    static calls := {}

    reset() {
        this.calls := {}
    }

    assert() {
        for function, calls in this.calls {
            msg := "Expectation failed for " function " calls."
            if (!calls.min && !calls.max) {
                continue
            }
            if (calls.min == calls.max) {
                Yunit.assertEq(calls.min, calls.got, msg)
                continue
            }
            if (calls.min) {
                Yunit.assertAtLeast(calls.min, calls.got, msg)
            }
            if (calls.max) {
                Yunit.assertAtMost(calls.max, calls.got, msg)
            }
            for _, arg in calls.argsLike {
                Yunit.fail("never saw an argument like: " arg, -1)
            }
        }
    }

    allow(name, returnValue := "") {
        this.calls[name] := { allow: true, value: returnValue }
    }

    expect(name, nTimes := 1, returnValue := "") {
        this.calls[name] := { allow: true, min: nTimes, max: nTimes
                            , got: 0, value: returnValue }
    }

    expectAtLeast(name, min := 1, returnValue := "") {
        this.calls[name] := { allow: true, min: min, got: 0
                            , value: returnValue }
        return new Expectation(this.calls[name])
    }

    disallow(name) {
        this.calls[name] := { allow: false }
    }

    __call(name, args*) {
        allow := this.calls[name].allow

        Yunit.assert(allow, "unexpected function call: " name, -2)

        for i, want in this.calls[name].argsLike {
            for j, got in args {
                if (want == got || RegExMatch(got, want)) {
                    this.calls[name].argsLike.removeAt(i)
                    args.removeAt(j)
                }
            }
        }

        this.calls[name].got += 1

        return this.calls[name].value
    }
}

refocus() {
    FunctionMocks.__call("refocus")
}

quickSend(keys) {
    FunctionMocks.__call("quickSend", keys)
}

slowSend(keys) {
    FunctionMocks.__call("slowSend", keys)
}

class Mock {

    __new(calls, other) {
        for key, val in other {
            if (!IsObject(key)) {
                this[key] := val
            }
        }
        this.____calls := calls
    }

    __call(name, args*) {
        allow := this.____calls[this, name].allow

        Yunit.assert(allow, "unexpected function call: " name, -2)

        for i, want in this.____calls[this, name].argsLike {
            for j, got in args {
                if (want == got || RegExMatch(got, want)) {
                    this.____calls[this, name].argsLike.removeAt(i)
                    args.removeAt(j)
                }
            }
        }

        this.____calls[this, name].got += 1

        return this.____calls[this, name].value
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
                if (!calls.min && !calls.max) {
                    continue
                }
                if (calls.min == calls.max) {
                    Yunit.assertEq(calls.min, calls.got, msg)
                    continue
                }
                if (calls.min) {
                    Yunit.assertAtLeast(calls.min, calls.got, msg)
                }
                if (calls.max) {
                    Yunit.assertAtMost(calls.max, calls.got, msg)
                }
                for _, arg in calls.argsLike {
                    Yunit.fail("never saw an argument like: " arg)
                }
            }
        }
    }

    allow(target, name, returnValue := "") {
        target.____calls := this.calls
        this.calls[target, name] := { allow: true, value: returnValue }
    }

    expect(target, name, nTimes := 1, returnValue := "") {
        target.____calls := this.calls
        this.calls[target, name] := { allow: true, min: nTimes, max: nTimes
                                    , got: 0, value: returnValue }
    }

    expectAtLeast(target, name, min := 1, returnValue := "") {
        target.____calls := this.calls
        this.calls[target, name] := { allow: true, min: min, got: 0
                                    , value: returnValue }
        return new Expectation(this.calls[target, name])
    }

    disallow(target, name) {
        target.____calls := this.calls
        this.calls[target, name] := { allow: false }
    }
}

class Expectation {

    __new(calls) {
        this.calls := calls
        this.calls.seenArgs := {}
    }

    argsLike(args) {
        this.calls.argsLike := args
    }
}
