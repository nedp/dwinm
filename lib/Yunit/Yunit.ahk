;#NoEnv

class Yunit
{
    static Modules := [Yunit.StdOut]

    class Tester extends Yunit
    {
        __New(Modules)
        {
            this.Modules := Modules
        }
    }

    Use(Modules*)
    {
        return new this.Tester(Modules)
    }

    Test(classes*) ; static method
    {
        instance := new this("")
        instance.results := {}
        instance.classes := classes
        instance.Modules := []
        for key,module in instance.base.Modules
            instance.Modules[key] := new module(instance)
        while (A_Index <= (A_AhkVersion < "2" ? classes.MaxIndex() : classes.Length()))
        {
            cls := classes[A_Index]
            instance.current := A_Index
            instance.results[cls.__class] := obj := {}
            instance.TestClass(obj, cls)
        }
        return instance
    }

    Update(Category, Test, Result)
    {
        for key,module in this.Modules
            module.Update(Category, Test, Result)
    }

    TestClass(results, cls)
    {
        environment := new cls() ; calls __New
        for key,val in cls
        {
            if IsObject(val) && IsFunc(val) ;test
            {
                if (key = "Begin") or (key = "End")
                    continue
                if ObjHasKey(cls,"Begin")
                && IsFunc(cls.Begin)
                    environment.Begin()
                result := 0
                try
                {
                    %val%(environment)
                    if ObjHasKey(environment, "ExpectedException")
                        throw Exception("ExpectedException")
                }
                catch error
                {
                    if !ObjHasKey(environment, "ExpectedException")
                    || !this.CompareValues(environment.ExpectedException, error)
                        result := error
                }
                results[key] := result
                ObjRemove(environment, "ExpectedException")
                this.Update(cls.__class, key, results[key])
                if ObjHasKey(cls,"End")
                && IsFunc(cls.End)
                    environment.End()
            }
            else if IsObject(val)
            && ObjHasKey(val, "__class") ;category
            {
                if (A_AhkVersion < "2")
                   this.classes.Insert(++this.current, val)
                else
                   this.classes.InsertAt(++this.current, val)
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
            throw Exception(message
                . "`n`texpected strictly less than: " max
                . "`n`tgot: " got , level - 1)
        }
    }

    assertLessOrEq(max, got, message := "", level := 0) {
        if (got > max) {
            throw Exception(message
                . "`n`texpected less than or equal to: " want
                . "`n`tgot: " got, level - 1)
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
