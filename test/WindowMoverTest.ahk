#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\lib\Yunit\StdOut.ahk

#Include %A_ScriptDir%\mocks.ahk
#Include %A_ScriptDir%\globals.ahk

#Include %A_ScriptDir%\..\src\WindowMover.ahk

#Warn

ExitApp, % Yunit.Use(YunitStdOut).Test(WindowMoverTest).didFail
return

class WindowMoverTest {

    begin(tester := "") {
        this.tester := tester
        this.tester.helpers := new Helpers(tester)

        FunctionMocks.reset()
        this.tester.hotMocks := new HotMocks()
        hotMocks := this.tester.hotMocks

        this.tester.dllManager := hotMocks.new("dllManager")
    }

    end() {
        this.tester.hotMocks.assert()
        FunctionMocks.assert()
    }

    MOVE_RIGHT_ARG := "i)(\^#|#\^){Right\s+\d*}"

    class Constructor {
        __new() {
            this.outer := new WindowMoverTest()
        }

        begin() {
            this.outer.begin(this)
        }

        end() {
            this.outer.end()
        }

        testStartBothIfUnavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitUnavailable()

            this.hotMocks.expectAtLeast(this.dllManager, "start32BitMover")
                .andReturn(true)
            this.hotMocks.expectAtLeast(this.dllManager, "start64BitMover")
                .andReturn(true)

            new WindowMover(this.dllManager)
        }

        testStart32IfUnavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitAvailable()

            this.hotMocks.expect(this.dllManager, "start32BitMover", 1)
                .andReturn(true)
            this.hotMocks.disallow(this.dllManager, "start64BitMover")

            new WindowMover(this.dllManager)
        }

        testStart64IfUnavailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitUnavailable()

            this.hotMocks.disallow(this.dllManager, "start32BitMover")
            this.hotMocks.expect(this.dllManager, "start64BitMover")
                .andReturn(true)

            new WindowMover(this.dllManager)
        }

        testDoNothingIfAvailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitAvailable()

            this.hotMocks.disallow(this.dllManager, "start32BitMover")
            this.hotMocks.disallow(this.dllManager, "start64BitMover")

            new WindowMover(this.dllManager)
        }
    }

    class Resync {
        __new() {
            this.outer := new WindowMoverTest()
        }

        begin() {
            this.outer.begin(this)

            this.helpers.given32BitAvailable()
            this.helpers.given64BitAvailable()
            this.target := new WindowMover(this.dllManager)
        }

        end() {
            this.outer.end()
        }

        testStartBothIfUnavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitUnavailable()

            this.hotMocks.expectAtLeast(this.dllManager, "start32BitMover")
                .andReturn(true)
            this.hotMocks.expectAtLeast(this.dllManager, "start64BitMover")
                .andReturn(true)

            this.target.resync()
        }

        testStart32IfUnavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitAvailable()

            this.hotMocks.expect(this.dllManager, "start32BitMover", 1)
                .andReturn(true)
            this.hotMocks.disallow(this.dllManager, "start64BitMover")

            this.target.resync()
        }

        testStart64IfUnavailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitUnavailable()

            this.hotMocks.disallow(this.dllManager, "start32BitMover")
            this.hotMocks.expect(this.dllManager, "start64BitMover")
                .andReturn(true)

            this.target.resync()
        }

        testDoNothingIfAvailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitAvailable()

            this.hotMocks.disallow(this.dllManager, "start32BitMover")
            this.hotMocks.disallow(this.dllManager, "start64BitMover")

            this.target.resync()
        }
    }

    class IsAvailable {
        __new() {
            this.outer := new WindowMoverTest()
        }

        begin() {
            this.outer.begin(this)

            this.helpers.given32BitAvailable()
            this.helpers.given64BitAvailable()
            this.target := new WindowMover(this.dllManager)
        }

        end() {
            this.outer.end()
        }

        testBothUnavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitUnavailable()

            Yunit.assert(!this.target.isAvailable())
        }

        test32Unavailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitUnavailable()

            Yunit.assert(!this.target.isAvailable())
        }

        test64Unavailable() {
            this.helpers.given32BitUnavailable()
            this.helpers.given64BitAvailable()

            Yunit.assert(!this.target.isAvailable())
        }

        testBothAvailable() {
            this.helpers.given32BitAvailable()
            this.helpers.given64BitAvailable()

            Yunit.assert(this.target.isAvailable())
        }
    }
}

class Helpers extends CarefulObject {
    __new(tester) {
        this.tester := tester
    }

    given32BitAvailable() {
        this.tester.hotMocks.allow(this.tester.dllManager
            , "is32BitMoverAvailable").andReturn(true)
    }

    given64BitAvailable() {
        this.tester.hotMocks.allow(this.tester.dllManager
            , "is64BitMoverAvailable").andReturn(true)
    }

    given32BitUnavailable() {
        this.tester.hotMocks.allow(this.tester.dllManager
            , "is32BitMoverAvailable").andReturn(false)
    }

    given64BitUnavailable() {
        this.tester.hotMocks.allow(this.tester.dllManager
            , "is64BitMoverAvailable").andReturn(false)
    }
}
