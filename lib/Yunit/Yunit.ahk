;#NoEnv

class Yunit
{
    static Modules := [Yunit.StdOut]

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
        while (A_Index <= (A_AhkVersion < "2" ? classes.MaxIndex() : classes.Length())) {
            cls := classes[A_Index]
            instance.current := A_Index
            instance.results[cls.__class] := obj := {}
            instance.TestClass(obj, cls)
        }
        return instance
    }

    Update(Category, Test, Result) {
        for key,module in this.Modules {
            module.Update(Category, Test, Result)
        }
    }

    TestClass(results, cls) {
        environment := new cls() ; calls __New
        for key,val in cls {
            if (IsObject(val) && IsFunc(val)) {
                ;; Ignore case
                if (key = "Begin" || key = "End") {
                    continue
                }
                result := 0
                if (ObjHasKey(cls, "Begin") && IsFunc(cls.Begin)) {
                    try {
                        environment.begin()
                    } catch error {
                        error.message
                            := "during #begin: " error.message
                        result := error
                    }
                }
                if (result == 0) {
                    try {
                        %val%(environment)
                        if (ObjHasKey(environment, "ExpectedException")) {
                            throw Exception("ExpectedException")
                        }
                    } catch error {
                        e := environment.ExpectedException
                        if (!ObjHasKey(environment, "ExpectedException")
                            || !this.CompareValues(e, error)) {
                            result := error
                        }
                    }
                    if (ObjHasKey(cls,"End") && IsFunc(cls.End)) {
                        try {
                            environment.end()
                        } catch error {
                            error.message
                                := "during #end: " error.message
                            result := error
                        }
                    }
                }
                results[key] := result
                ObjRemove(environment, "ExpectedException")
                this.Update(cls.__class, key, results[key])
            } else if (IsObject(val) && ObjHasKey(val, "__class")) {
                ;category
                if (A_AhkVersion < "2") {
                   this.classes.Insert(++this.current, val)
                } else {
                   this.classes.InsertAt(++this.current, val)
                }
            }
        }
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
