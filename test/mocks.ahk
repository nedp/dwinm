#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk

FunctionMocks.base := new CarefulObject()

class FunctionMocks {
    static calls := {}

    reset() {
        this.calls := {}
    }

    assert() {
        for function, calls in this.calls {
            for _, arg in calls.argsLike {
                Yunit.fail("never saw an argument like: " arg, -1)
            }
            if (calls.impl) {
                FileAppend DEBUG, *
                calls.impl.assert()
            }
            if (!calls.min && !calls.max) {
                continue
            }
            msg := "Expectation failed for " function " calls."
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
        }
    }

    allow(name, returnValue := "") {
        this.calls[name] := { allow: true }
        return new Expectation(this.calls[name])
    }

    expect(name, nTimes := 1, returnValue := "") {
        this.calls[name] := { allow: true, min: nTimes, max: nTimes, got: 0 }
        return new Expectation(this.calls[name])
    }

    expectAtLeast(name, min := 1, returnValue := "") {
        this.calls[name] := { allow: true, min: min, got: 0 }
        return new Expectation(this.calls[name])
    }

    disallow(name) {
        this.calls[name] := { allow: false }
    }

    __call(name, args*) {
        Yunit.assert(IsObject(this.calls[name])
            , "unknown function call: " name, -1)

        allow := this.calls[name].allow
        Yunit.assert(allow, "unexpected function call: " name, -2)

        if (this.calls[name].onlyArgsLike) {
            for _, got in args {
                ok := false
                for _, want in calls.onlyArgsLike {
                    if (want == got || RegExMatch(got, want)) {
                        ok := true
                    }
                }
                Yunit.assert(ok, "received unexpected argument: " got, -2)
            }
        }

        for i, want in this.calls[name].argsLike {
            for j, got in args {
                if (want == got || RegExMatch(got, want)) {
                    this.calls[name].argsLike.removeAt(i)
                    args.removeAt(j)
                }
            }
        }

        this.calls[name].got += 1

        return this.calls[name].impl ? this.calls[name].impl.call()
                                     : this.calls[name].value
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

sleep(milliseconds) {
    Yunit.assert(milliseconds < 2000, "Slept for too long: " milliseconds, -2)
}

class Mock {

    __new(calls, other := "", name := "<anonymous mock>") {
        this.name := name
        for key, val in other {
            if (!IsObject(key)) {
                this[key] := val
            }
        }
        this.____calls := calls
    }

    __call(name, args*) {
        Yunit.assert(IsObject(this.____calls[this, name])
            , "unknown method call: " this.name "#" name, -1)

        allow := this.____calls[this, name].allow
        Yunit.assert(allow, "unexpected method call: " this "#" name, -1)

        for i, want in this.____calls[this, name].argsLike {
            for j, got in args {
                if (want == got || RegExMatch(got, want)) {
                    this.____calls[this, name].argsLike.removeAt(i)
                    args.removeAt(j)
                }
            }
        }

        this.____calls[this, name].got += 1

        return this.____calls[this, name].impl
            ? this.____calls[this, name].impl.call()
            : this.____calls[this, name].value
    }

    __get(name, _*) {
        Yunit.fail("unexpected property access: " name, -1)
    }
}

class HotMocks extends CarefulObject {

    calls := {}
    returnValue := {}

    new(other := "", name := "<anonymous mock>") {
        return new Mock(this.calls, other, name)
    }

    assert() {
        for mock, methods in this.calls {
            for method, calls in methods {
                for _, arg in calls.argsLike {
                    Yunit.fail("never saw an argument like: " arg)
                }
                if (calls.impl) {
                    calls.impl.assert()
                }

                if (!calls.min && !calls.max) {
                    continue
                }

                msg := "Expectation failed for " method " calls."
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
            }
        }
    }

    allow(target, name) {
        this.calls[target, name] := { allow: true }
        return new Expectation(this.calls[target, name])
    }

    expect(target, name, nTimes := 1) {
        this.calls[target, name] := { allow: true, min: nTimes, max: nTimes
                                    , got: 0 }
        return new Expectation(this.calls[target, name])
    }

    expectAtLeast(target, name, min := 1) {
        this.calls[target, name] := { allow: true, min: min, got: 0 }
        return new Expectation(this.calls[target, name])
    }

    disallow(target, name) {
        this.calls[target, name] := { allow: false }
    }
}

class Expectation extends CarefulObject {
    __new(calls) {
        this.calls := calls
        this.calls.seenArgs := {}
    }

    withArgsLike(args) {
        this.calls.argsLike := args
        return this
    }

    withOnlyArgsLike(args) {
        this.calls.onlyArgsLike := args
        return this
    }

    andCall(callable) {
        Yunit.assert(IsObject(callable) && IsObject(callable.call)
            , "Expectation#andCall passed an invalid callable.", -2)
        this.calls.impl := callable
    }

    andReturn(value) {
        this.calls.value := value
    }
}

class CarefulObject {
    __call(name, _*) {
        throw Exception("A nonexisting method was invoked. "
            . "Specifically: " this.__class "#" name, -1)
    }
}

class Flag extends CarefulObject {

    __new(value) {
        this.value := value
    }

    call() {
        return this.value
    }

    assert() {
    }

}

class Fuse extends CarefulObject {

    __new(flag, nRemaining, newValue) {
        this.flag := flag
        this.nRemaining := nRemaining
        this.newValue := newValue
    }

    call() {
        if (this.nRemaining == 0) {
            this.flag.value := this.newValue
        }
        this.nRemaining -= 1
    }

    assert() {
    }

}

class PatternQuota extends CarefulObject {

    nTimes := 0

    __new(quota, default, pattern, subGroup, actionName := "do something") {
        this.quota := quota
        this.default := default
        this.pattern := pattern
        this.subGroup := subGroup
        this.actionName := actionName
    }

    call(arg) {
        iTimes := 0
        if (RegExMatch(arg, pattern)) {
            iTimes := this.RegExReplace(arg, pattern, "$" this.subGroup)
            if (iTimes = "") {
                iTimes := this.default
            }
        }
        this.nTimes += iTimes
    }

    assert() {
        Yunit.assertEq(this.quota, this.nTimes
            , "didn't " this.actionName " the correct number of times")
    }
}
