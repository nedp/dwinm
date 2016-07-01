# dwinm

A pauper's dwm for Windows 10.

## Philosophy

dwinm is based on three core ideas:

1. Window managers need to be as lightweight as possible to
   achieve the best possible performance and responsiveness.
2. Simpler software is better, it's easier to maintain.
3. (General keybinds + window management) is a specialised enough
   concern for a single program.

## Features

### Key swaps

* Swaps the Left Win and Left Alt keys
* Binds CapsLock to Escape

### DWM bindings

Bindings for instantly:

* Changing to virtual desktop number X
* Swapping between a 'main' and 'other' virtual desktop
  * Win+wab (recall LWin and LAlt are swapped) will swap
    the 'main' and 'other' desktops.
  * The 'other' desktop is remembered until you swap back into it.
* Moving windows between virtual desktops
* *Cycling* through windows (Alt+Esc-like, not Alt+Tab-like)

### Bindings for the Window picker (normally Ctrl+Alt+Tab)

* Alt+Tab to bring it up (but recall LWin and LAlt are swapped)
* vi bindings for selecting a window (SELECT mode)

### Generalised vi-like bindings

* Normally in PASSTHROUGH mode
  * Almost all keypresses just go through
  * Go to NORMAL mode with Win+Escape
  * Go to SELECT mode with Ctrl+Win+J
* NORMAL mode uses vi-like movement bindings; it is
  * intended for e.g. file browsing,
  * supports:
    * hjkl
  * Go back to PASSTHROUGH mode with Escape
  * Go to INSERT mode with i
* SELECT is like NORMAL mode but
  * intended for choosing a single item from a single menu and
  * i passes through; no INSERT mode.
  * Return to PASSTHOUGH mode with the following keybinds, which
    themselves will passthrough:
    * Enter
    * Escape
    * ^c
    * ^v
* INSERT mode is like PASSTHROUGH mode but
  * Intended for use in the middle of NORMAL mode, for:
    * navigating between (NORMAL) and filling (INSERT) in text fields,
      for example in Excel
    * turning other editors into something kinda vi-like;
      needs work though
  * Ctrl+Win+J passes through, no SELECT mode
  * Escape returns you to NORMAL mode

### Deficiencies

* Uses virtual desktops instead of tags, so only one virtual desktop
  is allowed per window.
* Doesn't arrange your windows for you; for now the best dwinm offers
  is a slight improvement on the bindings for Windows 10's built
  in tiling features.
* If virtual desktops are changed by something other than dwinm,
  dwinm may think that it's on a different desktop to what it
  is actually on.
* There is a flicker when switching to a desktop with multiple
  open windows.  This is a side effect of the method used to autofocus
  the top window.
* Not very good support for vi keychains yet.

## Forked from

[https://autohotkey.com/boards/viewtopic.php?t=9224]

Improved responsiveness at the cost of reduced automation;
it's possible for dwinm to desync, and you'll need to
resync manually.

I'm cutting features and code where possible and converting it to my
prefered style as I go.

I'm probably not going to change the DLLs, and plan to shamelessly use
any more DLLs Joshua comes up with.

## TODO

* Rewrite to avoid being bound to the Apache license
* Implement tiling mode
* Implement something like [https://autohotkey.com/boards/viewtopic.php?f=6&t=14881]
* Implement proper tags
* Improve vi bindings; e.g. add a VISUAL mode
