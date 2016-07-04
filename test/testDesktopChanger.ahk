; #Include <Yunit\Yunit>
; #Include <Yunit\StdOut>
#Include %A_ScriptDir%\mocks.ahk

#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\lib\Yunit\StdOut.ahk

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

#Include %A_ScriptDir%\..\src\DesktopChanger.ahk

class DesktopChangerTest {

    class Constructor {

        begin() {
            FunctionMocks.reset()
            this.hotMocks := new HotMocks()

            this.desktop := 1
            this.nDesktops := 2

            this.desktopMapper := new Mock(this.hotMocks)
            this.hotMocks.allow(this.desktopMapper, "getDesktopNumber"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "getNumberOfDesktops"
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

    }

    class Resync {

        begin() {
            FunctionMocks.reset()
            this.hotMocks := new HotMocks()

            this.desktop := 1
            this.nDesktops := 2
            this.desktopMapper := new Mock(this.hotMocks)
            this.hotMocks.allow(this.desktopMapper, "getDesktopNumber"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "getNumberOfDesktops"
                , this.nDesktops)

            this.dwm := new Mock(this.hotMocks, {nDesktops: this.nDesktops})

            this.tooltip := new Mock(this.hotMocks, {x: 3, y: 4, id: 5})

            this.target := new DesktopChanger(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        makesNoChangesIfAllOk() {
            ;; Read only operations are ok.
            this.hotMocks.allow(this.desktopMapper, "getDesktopNumber"
                , this.desktop)
            this.hotMocks.allow(this.desktopMapper, "getNumberOfDesktops"
                , this.nDesktops)

            ;; Refocusing is ok.
            FunctionMocks.allow("refocus")

            this.target.resync()

            this.hotMocks.assert()
            FunctionMocks.assert()
        }

    }

}

