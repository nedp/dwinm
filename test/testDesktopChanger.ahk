; #Include <Yunit\Yunit>
; #Include <Yunit\StdOut>
#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\lib\Yunit\StdOut.ahk

#Include %A_ScriptDir%\mocks.ahk
#Include %A_ScriptDir%\globals.ahk

#Include %A_ScriptDir%\..\src\DesktopChanger.ahk

#Warn

t := Yunit.Use(YunitStdOut).Test(DesktopChangerTest)

; loop through the results, check if there was a FAIL case
errorcode := 0
for k, v in t.results {
    if IsObject(v){
        for k2, v2 in v {
            if (v2 != "0")
                errorcode := 1
        }
    }
}
ExitApp, % errorcode
return

class DesktopChangerTest {

    class __new {

        begin() {
            FunctionMocks.reset()
            this.hotMocks := new HotMocks()

            this.desktop := 10
            this.nDesktops := 20

            this.desktopMapper := new Mock(this.hotMocks)
            this.hotMocks.allow(this.desktopMapper, "currentDesktop"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "syncDesktopCount"
                , this.nDesktops)

            this.dwm := new Mock(this.hotMocks, {nDesktops: this.nDesktops})

            this.tooltip := new Mock(this.hotMocks, {x: 3, y: 4, id: 5})
        }

        injectsProperties() {
            target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)

            Yunit.assertEq(target.dwm, this.dwm)
            Yunit.assertEq(target.desktopMapper, this.desktopMapper)
            Yunit.assertEq(target.tooltip, this.tooltip)
        }

        derivesProperties() {
            target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)

            Yunit.assertEq(target.desktop, this.desktop)
            Yunit.assertEq(target.nDesktops, this.nDesktops)
        }

        makesNoChangesIfAllOk() {
            ;; Read only operations from #begin are ok.

            target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

        addsDesktopsIfNeeded() {
            nDiff := 5
            ;; We want nDiff more than we have.
            this.dwm.nDesktops := this.nDesktops + nDiff

            ;; Desktops are added via slowSend, at the end.
            FunctionMocks.expectAtLeast("slowSend")
                .argsLike([ this.addDesktopsArg(nDiff)
                          , this.MOVE_RIGHT_ARG ]) ;; at the end

            target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

        removeDesktopsIfNeeded() {
            nDiff := 5
            ;; We have nDiff more than we want.
            this.hotMocks.allow(this.desktopMapper, "syncDesktopCount"
                , this.nDesktops + nDiff)

            ;; Desktops are deleted via slowSend, at the end.
            FunctionMocks.expectAtLeast("slowSend")
                .argsLike([ this.deleteDesktopsArg(nDiff)
                          , this.MOVE_RIGHT_ARG ]) ;; at the end

            target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

    }

    class Resync {

        begin() {
            FunctionMocks.reset()
            this.hotMocks := new HotMocks()

            this.desktop := 10
            this.nDesktops := 20

            this.desktopMapper := new Mock(this.hotMocks)
            this.hotMocks.allow(this.desktopMapper, "currentDesktop"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "syncDesktopCount"
                , this.nDesktops)

            this.dwm := new Mock(this.hotMocks, {nDesktops: this.nDesktops})

            this.tooltip := new Mock(this.hotMocks, {x: 3, y: 4, id: 5})

            this.target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        makesNoChangesIfAllOk() {
            ;; Read only operations are ok.
            this.hotMocks.allow(this.desktopMapper, "currentDesktop"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "syncDesktopCount"
                , this.nDesktops)

            ;; Refocusing is ok.
            FunctionMocks.allow("refocus")

            this.target.resync()

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

        addsDesktopsIfNeeded() {
            nDiff := 5
            ;; We have nDiff fewer than we want.
            this.hotMocks.allow(this.desktopMapper, "syncDesktopCount"
                , this.nDesktops - nDiff)

            ;; Desktops are added via slowSend, at the end.
            FunctionMocks.expectAtLeast("slowSend")
                .argsLike([ this.deleteDesktopsArg(nDiff)
                          , this.MOVE_RIGHT_ARG ]) ;; at the end

            ;; Refocusing is ok.
            FunctionMocks.allow("refocus")

            this.target.resync()

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

        removeDesktopsIfNeeded() {
            nDiff := 5
            ;; We want nDiff fewer than we have.
            this.dwm.nDesktops := this.nDesktops - nDiff

            ;; Desktops are deleted via slowSend, at the end.
            FunctionMocks.expectAtLeast("slowSend")
                .argsLike([ this.deleteDesktopsArg(nDiff)
                          , this.MOVE_RIGHT_ARG ]) ;; at the end

            ;; Refocusing is ok.
            FunctionMocks.allow("refocus")

            this.target.resync()

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

    }

    addDesktopsArg(count) {
        return "i)(\^#|#\^){d\s+" count "}"
    }

    deleteDesktopsArg(count) {
        return "i)(\^#|#\^){F4\s+" count "}"
    }

    MOVE_RIGHT_ARG := "i)(\^#|#\^){Right\s+\d*}"

}
