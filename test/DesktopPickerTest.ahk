#Include %A_ScriptDir%\..\lib\Yunit\Yunit.ahk
#Include %A_ScriptDir%\..\lib\Yunit\StdOut.ahk

#Include %A_ScriptDir%\mocks.ahk
#Include %A_ScriptDir%\globals.ahk

#Include %A_ScriptDir%\..\src\DesktopPicker.ahk

#Warn

ExitApp, % Yunit.Use(YunitStdOut).Test(DesktopPickerTest).didFail
return

class DesktopPickerTest {

    begin(tester) {
        this.tester := tester

        FunctionMocks.reset()
        hotMocks := new HotMocks()
        tester.hotMocks := hotMocks

        tester.desktop := 10
        tester.nDesktops := 20

        tester.desktopMapper := hotMocks.new()

        tester.dwm := hotMocks.new({nDesktops: tester.nDesktops})

        tester.tooltip := hotMocks.new({x: 3, y: 4, id: 5})

        FunctionMocks.allow("refocus")
    }

    end() {
        this.tester.hotMocks.assert()
        FunctionMocks.assert()
    }

    MOVE_RIGHT_ARG := "i)(\^#|#\^){Right\s+\d*}"

    class Constructor {
        __new() {
            this.outer := new DesktopPickerTest()
            this.helper := new Helper(this)
        }

        begin() {
            this.outer.begin(this)
            this.hotMocks.allow(this.desktopMapper, "syncCurrentDesktop")
                .andReturn(this.desktop)
        }

        end() {
            this.outer.end()
        }

        shouldInjectProperties() {
            this.helper.givenCorrectDesktopCount()

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)

            Yunit.assertEq(target.dwm, this.dwm)
            Yunit.assertEq(target.desktopMapper, this.desktopMapper)
            Yunit.assertEq(target.tooltip, this.tooltip)
        }

        shouldDeriveProperties() {
            this.helper.givenCorrectDesktopCount()

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)

            Yunit.assertEq(this.desktop, target.desktop)
            Yunit.assertEq(this.nDesktops, target.nDesktops)
            Yunit.assertEq(1, target.recentDesktop)
            Yunit.assertEq(1, target.otherDesktop)
        }

        shouldMakeNoChangesIfAllOk() {
            this.helper.givenCorrectDesktopCount()

            this.helper.expectNoChanges()

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        shouldAddDesktopsIfNeeded() {
            nDiff := 5
            this.helper.givenMoreDesktopsWanted(nDiff)

            this.helper.expectAddDesktops(nDiff)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        shouldRemoveDesktopsIfNeeded() {
            nDiff := 5
            this.helper.givenMoreDesktopsPresent(nDiff)

            this.helper.expectRemoveDesktops(nDiff)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        ;; Test included for explicitness, even though covered
        ;; by other tests/helpers.
        shouldSyncValues() {
            this.hotMocks.expect(this.desktopMapper, "syncDesktopCount")
                         .andReturn(this.nDesktops)
            this.hotMocks.expect(this.desktopMapper, "syncCurrentDesktop")
                         .andReturn(this.desktop)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }
    }

    ;; Due to toggling mechanic, require target != current desktop
    ;; for most cases.
    class PickDesktop {
        __new() {
            this.outer := new DesktopPickerTest()
            this.helper := new Helper(this)
        }

        begin() {
            this.outer.begin(this)

            this.helper.givenAConstructedTarget()
        }

        end() {
            this.outer.end()
        }

        shouldDelegateGoToDesktop() {
            targetDesktop := this.target.desktop - 1

            this.helper.expectSuccessfulGoToDesktop(targetDesktop)

            this.target.pickDesktop(targetDesktop)
        }

        shouldSetTheNewDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(targetDesktop, this.target.desktop)
        }

        shouldSetTheNewDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            resultingDesktop := targetDesktop + 5

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(resultingDesktop, this.target.desktop)
        }

        shouldRefocus() {
            targetDesktop := this.target.desktop - 1

            this.helper.allowGoToDesktop(targetDesktop)
            FunctionMocks.expect("refocus", 1)

            this.target.pickDesktop(targetDesktop)
        }

        shouldSetTheRecentDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1
            originalDesktop := this.target.desktop

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(originalDesktop, this.target.recentDesktop)
        }

        shouldSetTheRecentDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            originalDesktop := this.target.desktop
            resultingDesktop := targetDesktop + 15

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(originalDesktop, this.target.recentDesktop)
        }

        shouldNotChangeTheOtherDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1
            otherDesktop := this.target.otherDesktop

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(otherDesktop, this.target.otherDesktop)
        }

        shouldNotChangeTheOtherDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            resultingDesktop := targetDesktop + 20
            otherDesktop := this.target.otherDesktop

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.pickDesktop(targetDesktop)

            Yunit.assertEq(otherDesktop, this.target.otherDesktop)
        }

        shouldDoNothingIfSuccessfulTwiceTargettingRecent() {
            recentDesktop := this.target.desktop - 4
            this.target.recentDesktop := recentDesktop
            originalDesktop := this.target.desktop
            this.helper.rememberValues()

            this.helper.allowGoToDesktop(recentDesktop)

            this.target.pickDesktop(recentDesktop)

            this.helper.expectSuccessfulGoToDesktop(originalDesktop)

            this.target.pickDesktop(recentDesktop)

            this.helper.assertSameValues()
        }

        shouldReturnOnRepeatSuccess() {
            originalDesktop := this.target.desktop
            recentDesktop := originalDesktop + 20
            this.target.recentDesktop := recentDesktop

            this.helper.expectSuccessfulGoToDesktop(recentDesktop)

            this.target.pickDesktop(originalDesktop)

            Yunit.assertEq(originalDesktop, this.target.recentDesktop)
            Yunit.assertEq(recentDesktop, this.target.desktop)
        }

        shouldReturnOnRepeatFailure() {
            originalDesktop := this.target.desktop
            recentDesktop := originalDesktop + 20
            this.target.recentDesktop := recentDesktop
            resultingDesktop := originalDesktop + 40

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.pickDesktop(originalDesktop)

            Yunit.assertEq(originalDesktop, this.target.recentDesktop)
            Yunit.assertEq(resultingDesktop, this.target.desktop)
        }
    }

    ;; Due to toggling mechanic, require target != current desktop
    ;; for most cases.
    class HardPickDesktop {
        __new() {
            this.outer := new DesktopPickerTest()
            this.helper := new Helper(this)
        }

        begin() {
            this.outer.begin(this)

            this.helper.givenAConstructedTarget()
        }

        end() {
            this.outer.end()
        }

        shouldDelegateGoToDesktop() {
            targetDesktop := this.target.desktop - 1

            this.helper.expectSuccessfulGoToDesktop(targetDesktop)

            this.target.hardPickDesktop(targetDesktop)
        }

        shouldSetTheNewDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(targetDesktop, this.target.desktop)
        }

        shouldSetTheNewDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            resultingDesktop := targetDesktop + 5

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(resultingDesktop, this.target.desktop)
        }

        shouldRefocus() {
            targetDesktop := this.target.desktop - 1

            this.helper.allowGoToDesktop(targetDesktop)
            FunctionMocks.expect("refocus", 1)

            this.target.hardPickDesktop(targetDesktop)
        }

        shouldSetTheOtherDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1
            originalDesktop := this.target.desktop

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(originalDesktop, this.target.otherDesktop)
        }

        shouldSetTheOtherDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            originalDesktop := this.target.desktop
            resultingDesktop := targetDesktop + 15

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(originalDesktop, this.target.otherDesktop)
        }

        shouldNotChangeTheRecentDesktopOnSuccess() {
            targetDesktop := this.target.desktop - 1
            recentDesktop := this.target.recentDesktop

            this.helper.allowGoToDesktop(targetDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(recentDesktop, this.target.recentDesktop)
        }

        shouldNotChangeTheRecentDesktopOnFailure() {
            targetDesktop := this.target.desktop - 1
            resultingDesktop := targetDesktop + 20
            recentDesktop := this.target.recentDesktop

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.hardPickDesktop(targetDesktop)

            Yunit.assertEq(recentDesktop, this.target.recentDesktop)
        }

        shouldDoNothingOnRepeat() {
            originalDesktop := this.target.desktop
            this.helper.rememberValues()

            this.hotMocks.disallow(this.target.desktopMapper, "goToDesktop")
            FunctionMocks.disallow("refocus")

            this.target.hardPickDesktop(originalDesktop)

            this.helper.assertSameValues()
        }
    }

    class SwapDesktops {
        __new() {
            this.outer := new DesktopPickerTest()
            this.helper := new Helper(this)
        }

        begin() {
            this.outer.begin(this)

            this.helper.givenAConstructedTarget()

            this.target.otherDesktop := this.target.desktop + 1
        }

        end() {
            this.outer.end()
        }

        shouldDelegateGoToDesktop() {
            otherDesktop := this.target.otherDesktop

            this.helper.expectSuccessfulGoToDesktop(otherDesktop)

            this.target.swapDesktops()
        }

        shouldSetTheNewDesktopOnSuccess() {
            otherDesktop := this.target.otherDesktop

            this.helper.allowGoToDesktop(otherDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(otherDesktop, this.target.desktop)
        }

        shouldSetTheNewDesktopOnFailure() {
            otherDesktop := this.target.otherDesktop
            resultingDesktop := otherDesktop + 5

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(resultingDesktop, this.target.desktop)
        }

        shouldRefocus() {
            this.helper.allowGoToDesktop(this.target.otherDesktop)
            FunctionMocks.expect("refocus", 1)

            this.target.swapDesktops()
        }

        shouldSetTheOtherDesktopOnSuccess() {
            otherDesktop := this.target.otherDesktop
            originalDesktop := this.target.desktop

            this.helper.allowGoToDesktop(otherDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(originalDesktop, this.target.otherDesktop)
        }

        shouldSetTheOtherDesktopOnFailure() {
            otherDesktop := this.target.otherDesktop
            originalDesktop := this.target.desktop
            resultingDesktop := originalDesktop + 15

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(originalDesktop, this.target.otherDesktop)
        }

        shouldSetTheRecentDesktopOnSuccess() {
            recentDesktop := this.target.recentDesktop

            this.helper.allowGoToDesktop(this.target.otherDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(recentDesktop, this.target.recentDesktop)
        }

        shouldSetTheRecentDesktopOnFailure() {
            recentDesktop := this.target.recentDesktop
            resultingDesktop := this.target.otherDesktop + 10

            this.helper.allowGoToDesktop(resultingDesktop)

            this.target.swapDesktops()

            Yunit.assertEq(recentDesktop, this.target.recentDesktop)
        }

        shouldDoNothingIfSuccessfulTwice() {
            otherDesktop := this.target.otherDesktop
            originalDesktop := this.target.desktop
            this.helper.rememberValues()

            this.helper.allowGoToDesktop(otherDesktop)

            this.target.swapDesktops()

            this.helper.expectSuccessfulGoToDesktop(originalDesktop)

            this.target.swapDesktops()

            this.helper.assertSameValues()
        }
    }

    class Resync {
        __new() {
            this.outer := new DesktopPickerTest()
            this.helper := new Helper(this)
        }

        begin() {
            this.outer.begin(this)

            this.helper.givenAConstructedTarget()

            this.hotMocks.allow(this.desktopMapper, "syncCurrentDesktop")
                .andReturn(this.desktop)
        }

        end() {
            this.outer.end()
        }

        shouldMakeNoChangesIfAllOk() {
            this.helper.givenCorrectDesktopCount()

            this.helper.expectNoChanges()

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        shouldAddDesktopsIfNeeded() {
            nDiff := 5
            this.helper.givenMoreDesktopsWanted(nDiff)

            this.helper.expectAddDesktops(nDiff)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        shouldRemoveDesktopsIfNeeded() {
            nDiff := 5
            this.helper.givenMoreDesktopsPresent(nDiff)

            this.helper.expectRemoveDesktops(nDiff)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }

        ;; Test included for explicitness, even though covered
        ;; by other tests/helpers.
        shouldSyncValues() {
            this.hotMocks.expect(this.desktopMapper, "syncDesktopCount")
                         .andReturn(this.nDesktops)
            this.hotMocks.expect(this.desktopMapper, "syncCurrentDesktop")
                         .andReturn(this.desktop)

            target := new DesktopPicker(this.dwm
                , this.desktopMapper, this.tooltip)
        }
    }

}

class Helper extends CarefulObject {

    __new(tester) {
        this.tester := tester
        this.outer := tester.outer
    }

    givenFewerDesktopsPresent(nDiff) {
        ;; We have nDiff fewer than we want.
        this.tester.dwm.nDesktops := this.tester.nDesktops
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops - nDiff)
    }

    givenMoreDesktopsPresent(nDiff) {
        ;; We have nDiff more than we want.
        this.tester.dwm.nDesktops := this.tester.nDesktops
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops + nDiff)
    }

    givenFewerDesktopsWanted(nDiff) {
        ;; We want nDiff fewer than we have.
        this.tester.dwm.nDesktops := this.tester.nDesktops - nDiff
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops)
    }

    givenMoreDesktopsWanted(nDiff) {
        ;; We want nDiff more than we have.
        this.tester.dwm.nDesktops := this.tester.nDesktops + nDiff
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops)
    }

    givenCorrectDesktopCount() {
        ;; We want nDiff more than we have.
        this.tester.dwm.nDesktops := this.tester.nDesktops
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops)
    }

    givenAConstructedTarget() {
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncDesktopCount").andReturn(this.tester.nDesktops)
        this.tester.hotMocks.allow(this.tester.desktopMapper
            , "syncCurrentDesktop").andReturn(this.tester.desktop)

        this.tester.target := new DesktopPicker(this.tester.dwm
            , this.tester.desktopMapper, this.tester.tooltip)

        this.tester.hotMocks.disallow(this.tester.desktopMapper
            , "syncDesktopCount")
        this.tester.hotMocks.disallow(this.tester.desktopMapper
            , "syncCurrentDesktop")
    }

    expectNoChanges() {
        ;; Read only operations like refocus are ok.
        FunctionMocks.disallow("slowSend")
        FunctionMocks.disallow("quickSend")
    }

    ;; Expect desktops to be added via slowSend at the rightmost desktop.
    expectAddDesktops(count) {
        keys := "i)(\^#|#\^){d\s+" count "}"
        FunctionMocks.expectAtLeast("slowSend")
            .withArgsLike([ keys
                          , this.outer.MOVE_RIGHT_ARG ])
    }

    ;; Expect desktops to be deleted via slowSend at the rightmost desktop.
    expectRemoveDesktops(count) {
        keys := "i)(\^#|#\^){F4\s+" count "}"
        FunctionMocks.expectAtLeast("slowSend")
            .withArgsLike([ keys
                          , this.outer.MOVE_RIGHT_ARG ])
    }

    expectSuccessfulGoToDesktop(targetDesktop) {
        this.tester.hotMocks
            .expect(this.tester.desktopMapper, "goToDesktop", 1)
            .withArgsLike([targetDesktop])
            .andReturn(targetDesktop)
    }

    allowGoToDesktop(resultingDesktop) {
        this.tester.hotMocks
            .allow(this.tester.desktopMapper, "goToDesktop")
            .andReturn(resultingDesktop)
    }

    rememberValues() {
        this.rememberedValues
            := { dwm: this.tester.target.dwm
               , desktopMapper: this.tester.target.desktopMapper
               , tooltip: this.tester.target.tooltip
               , desktop: this.tester.target.desktop
               , nDesktops: this.tester.target.nDesktops
               , recentDesktop: this.tester.target.recentDesktop
               , otherDesktop: this.tester.target.otherDesktop }
    }

    assertSameValues() {
        msg := "target's properties changed unexpectedly "
        Yunit.assertEq(this.rememberedValues.dwm
            , this.tester.target.dwm, msg "(dwm)", -1)
        Yunit.assertEq(this.rememberedValues.desktopMapper
            , this.tester.target.desktopMapper, msg "(desktopMapper)", -1)
        Yunit.assertEq(this.rememberedValues.tooltip
            , this.tester.target.tooltip, msg "(tooltip)", -1)
        Yunit.assertEq(this.rememberedValues.desktop
            , this.tester.target.desktop, msg "(desktop)", -1)
        Yunit.assertEq(this.rememberedValues.nDesktops
            , this.tester.target.nDesktops, msg "(nDesktops)", -1)
        Yunit.assertEq(this.rememberedValues.recentDesktop
            , this.tester.target.recentDesktop, msg "(recentDesktop)", -1)
        Yunit.assertEq(this.rememberedValues.otherDesktop
            , this.tester.target.otherDesktop, msg "(otherDesktop)", -1)
    }
}
