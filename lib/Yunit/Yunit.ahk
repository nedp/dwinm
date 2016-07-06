class Yunit {
    static Modules := [Yunit.StdOut]

    static NO_EXPECTED_EXCEPTION := Exception("expected exception not seen")

    class Tester extends Yunit {
        __New(Modules) {
            this.Modules := Modules
        }
    }

    Use(Modules*) {
        return new this.Tester(Modules)
    }

    ;; Static
    Test(classes*) {
        instance := new this("")
        instance.results := {}
        instance.classes := classes
        instance.Modules := []
        for key, module in instance.base.Modules {
            instance.Modules[key] := new module(instance)
        }
        for i, cls in classes {
            instance.current := i
            instance.results[cls.__class] := obj := {}
            instance.TestClass(obj, cls)
        }
        return instance
    }

    update(category, test, result) {
        for key, module in this.modules {
            module.update(category, test, result)
        }
    }

    TestClass(results, cls) {
        environment := new cls() ; calls __New
        for key,val in cls {
            if (!IsObject(val)) {
                continue
            }
            if (!IsFunc(val) && ObjHasKey(val, "__class")) {
                ; New category
                this.classes.InsertAt(++this.current, val)
                continue
            }
            if (!IsFunc(val)) {
                continue
            }
            ;; Ignore case
            if (SubStr(key, 1, 4) != "test") {
                continue
            }
            result := 0
            if (ObjHasKey(cls, "Begin") && IsFunc(cls.Begin)) {
                result := this.try(environment, environment.begin)
            }
            if (result == 0) {
                result := this.try(environment, val)
            }
            if (ObjHasKey(cls, "End") && IsFunc(cls.End)) {
                result := result !== 0 ? result
                                       : this.try(environment, environment.end)
            }
            if (result) {
                this.didFail := true
            }
            results[key] := result
            this.update(cls.__class, SubStr(key, 5), result)
            ObjRemove(environment, "ExpectedException")
        }
    }

    try(environment, method) {
        try {
            %method%(environment)
            if (ObjHasKey(environment, "ExpectedException")) {
                throw this.NO_EXPECTED_EXCEPTION
            }
        } catch error {
            if (error != environment.ExpectedException) {
                error.message := "during #" method ": " error.message
                return error
            }
        }
        return 0
    }

    fail(message := "FAIL", level := 0) {
        throw Exception(message, level - 1)
    }

    assert(guard, message := "FAIL", level := 0) {
        if (!guard) {
            throw Exception(message, level - 1)
        }
    }

    assertEq(want, got, message := "", level := 0) {
        if (want != got) {
            throw Exception(message "`n`twant: " want "`n`tgot: " got
                , level - 1)
        }
    }

    assertLessThan(max, got, message := "", level := 0) {
        if (got >= max) {
            throw Exception(message . "`n`texpected strictly less than: "
                . max "`n`tgot: " got , level - 1)
        }
    }

    assertAtMost(max, got, message := "", level := 0) {
        if (got > max) {
            throw Exception(message . "`n`texpected at most: "
                . max "`n`tgot: " got, level - 1)
        }
    }

    assertGreaterThan(min, got, message := "", level := 0) {
        if (got <= min) {
            throw Exception(message . "`n`texpected strictly greater than: "
                . min "`n`tgot: " got , level - 1)
        }
    }

    assertAtLeast(min, got, message := "", level := 0) {
        if (got < min) {
            throw Exception(message . "`n`texpected at least: "
                . min "`n`tgot: " got, level - 1)
        }
    }

    CompareValues(v1, v2) {
        ; Support for simple exceptions. May need to be extended in the future.
        if !IsObject(v1) || !IsObject(v2)
            return v1 = v2   ; obey StringCaseSense
        if !ObjHasKey(v1, "Message") || !ObjHasKey(v2, "Message")
            return False
        return v1.Message = v2.Message
    }
}
