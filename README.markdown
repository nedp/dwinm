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
* Changing between two most recent virtual desktops
* Moving windows between virtual desktops
* Cycling through windows (Alt+Esc-like, not Alt+Tab-like)

### Bindings for the Window picker (normally Ctrl+Alt+Tab)

* Alt+Tab to bring it up (recall LWin and LAlt are swapped)
* vi bindings for selecting a window (SELECT mode)

### Generalised vi-like bindings

* Normally in PASSTHROUGH mode
  * Almost all keypresses just go through
  * Go to NORMAL mode with Win+Escape
  * Go to SELECT mode with Ctrl+Win+J
* NORMAL mode uses vi-like movement bindings
  * hjkl
  * Go back to PASSTHROUGH mode with Escape
  * Go to INSERT mode with i
  * Intended for e.g. file browsing
* SELECT is like NORMAL mode but
  * i passes through; no INSERT mode
  * Enter and Escape return to PASSTHROUGH mode but
    also pass through
  * Intended for choosing a single item from a single menu
* INSERT mode is like PASSTHROUGH mode but
  * Ctrl+Win+J passes through, no SELECT mode
  * Escape returns you to NORMAL mode
  * Intended for use with NORMAL mode:
    * navigating between and filling in text fields; e.g. Excel
    * turning other editors into something kinda vi-like;
      needs work though

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

## Forked from

[https://autohotkey.com/boards/viewtopic.php?t=9224]

Improved responsiveness at the cost of reduced automation;
it's possible for dwinm to desync, and you'll need to
resync manually.

## TODO

* Rewrite to avoid being bound to the Apache license
* Implement tiling mode
* Implement something like [https://autohotkey.com/boards/viewtopic.php?f=6&t=14881]
* Implement proper tags
* Improve vi bindings; e.g. add a VISUAL mode
