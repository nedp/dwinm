# dwinm

A pauper's dwm for Windows 10.

## Builds

Most recent:
[![Build status](https://ci.appveyor.com/api/projects/status/xb5mv5qimhl47bfc?svg=true)](https://ci.appveyor.com/project/nedp/dwinm)

`master`:
[![Build status](https://ci.appveyor.com/api/projects/status/xb5mv5qimhl47bfc/branch/master?svg=true)](https://ci.appveyor.com/project/nedp/dwinm/branch/master)

## Philosophy

dwinm is based on three core ideas:

1. Window managers need to be as lightweight as possible to
   achieve the best possible performance and responsiveness.
2. Simpler software is better, it's easier to maintain.
3. (General keybinds + window management) is a specialised enough
   concern for a single program.

## Features

* Bindings for managing windows within a virtual desktop.
* Bindings for moving windows between virtual desktops.
* Bindings for switching between virtual desktops.
* Modal hotkey definitions, supporting a vi-like mode.
* Emacs-like hotkey definitions for explorers and browsers.
* Reversible registry edit for remapping CapsLock to Escape.

## Usage

### Display

The first thing you'll notice is that dwinm gives you information via a couple
of tooltips.

#### Desktops

In the top left corner of the screen, a tooltip is shown with a number
for each desktop.
The current desktop is highlighted with square brackets.
The "other" desktop (activated with Alt+Tab) is highlighted with dots.

e.g. ` 1  2 .3. 4  5 [6] 7  8 '9'` indicates that:

* you're on desktop 6;
* the "other" desktop is desktop 3, access it with Alt+Tab; and
* the "recent" desktop is desktop 9, return to it by pressing the
  current desktop's "pick" shortcut, Alt+6.

#### Mode indicator

Below the desktop tooltip is the mode indicator.
In `DESKTOP` mode, the mode indicator is hidden.
In all other modes, the name of the current mode is displayed.

### Modes

dwinm is always in one of several modes.

`DESKTOP` is the default mode, with window management bindings.

`NORMAL` is accessed from `DESKTOP` with `Alt+Escape`, acts like vi.

`INSERT` is accessed from `NORMAL` with `i`, it's optimised for text insertion.
Return to `NORMAL` with `Escape`.

`SELECT` is accessed from `DESKTOP` with `Alt+s`, it's a limited `NORMAL` mode.
It's exited by pressing `Enter`, `Escape`, or a few other intuitive keybinds.
It is optimised for picking items from menus.

`COMMAND` is accessed from `DESKTOP` with `Alt+Shift+:` and
acts kind of like zle/emacs.

`PASSTHROUGH` is accessed from `DESKTOP` with `Alt+i`,
it allows all keypresses to pass through unaffected
except `Ctrl+Shift+Escape`, which returns you to `DESKTOP` mode.

### `DESKTOP` mode keybinds

| Combination | Command |
|:-----------:|:--------|
| Alt+Escape  | Enter `NORMAL` mode
| Alt+s       | Enter `SELECT` mode
| Alt+Shift+: | Enter `COMMAND` mode
| Alt+i       | Enter `PASSTHROUGH` mode
| Alt+(X)     | Change to desktop (X), with (X) is in 1-9.  Press again to return.
| Alt+0       | Resynchronise dwinm
|Alt+Shift+(X)| Send active window to desktop (X), with (X) in 1-9
| Alt+Tab     | Swap the active and "other" desktop
| Ctrl+Alt+(X)| Swap the active and "other" desktop, then change to desktop (X)
| Ctrl+Alt+Tab| Enter `SELECT` mode for the window browser
| Win+Tab     | Enter `SELECT` mode and bring up the task view
| Alt+j       | Cycle down the window stack, like Alt+Escape
| Alt+k       | Cycle up the window stack, like Alt+Shift+Escape
| Alt+w       | Close the active window (Alt+F4)
| Ctrl+Alt+L  | Lock the screen
| Alt+Shift+(h/j/k/l) | Maps to Win+(Left/Down/Up/Right) respectively
| Ctrl+Alt+q  | Reload dwinm, useful for reconfiguring
| Alt+Space   | Bring up the start menu (Windows key)

### `NORMAL` mode keybinds

Move the cursor:

| Key | Movement      | Simulated Keys |
|:---:|:-------------:|:---------------|
|Basic|               |
| h   | Left          | Left
| j   | Down          | Down
| k   | Up            | Up
| l   | Right         | Right
|Words|               |
| b   | Back word     | Ctrl+Left
| w   | Next word     | Ctrl+Right
|Lines|               |
| 0   | Start of line | Home
| $   | End of line   | End
| _   | Start of first word in line\* | Home Left Ctrl+Right
| ^   | Start of first word in line | Home Left Ctrl+Right
|Doc  |               |
| gg  | Start of doc  | Ctrl+Home
| G   | End of doc    | Ctrl+End

* Note, `_` works differently in combinations such as `d_`, `c_`, etc.
  in these, it makes the operation target the whole line, not work as a
  movement. `^` doesn't behave like this with other commands.

Enter insert mode at various position by simulating
complicated key chains:

| Keychain | Position |
|:--------:|:--------:|
| `i`      | Here
| `I`      | Before this line (except leading whitespace)
| `a`      | After this character
| `A`      | End of line
| `o`      | At a new line before start of line
| `O`      | At a new line after end of line

Delete stuff, yanking it (cut):

| Keychain    | Target |
|:-----------:|:-------|
| `x`         | This character (Delete)
| `X`         | Previous character (BackSpace)
| `dd` or `d_`| This line
| `D`         | Here to end of line
| `d<move>`   | Here to `move` target

Change stuff, by deleting and yanking (cutting) then entering `INSERT` mode:

| Keychain            | Target |
|:-------------------:|:-------|
| `s`                 | This character
| `S` or `cc` or `c_` | This line (except leading whitespace)
| `C`                 | Here to end of line
| `c<move>`           | Here to `move` target
| `cw`                | (Exception to above if inside a word) Here to end of word

Yank (copy) and put (paste) stuff:

| Keychain            | Command |
|:-------------------:|:--------|
| `y`                 | Yank selection
| `Y` or `yy` or `y_` | Yank this line
| `c<move>`           | Yank from here to `move` target
| `p`                 | Put here
| `P`                 | Put before this character

Miscellaneous commands:

| Combination | Command              | Simulated keys |
|:-----------:|:--------------------:|:---------------|
| u           | Undo                 | Ctrl+z
| Ctrl+r      | Redo                 | Ctrl+y
| /           | Search               | Ctrl+f
| Shift+j     | Merge with next line | End Space Shift+Ctrl+Right BackSpace

### `INSERT` mode keybinds

Pressing either keychain `jk` or `kj` will enter `NORMAL` mode

| Combination  | Command |
|:------------:|:--------|
| Ctrl+W       | Delete+yank (cut) last word
| Ctrl+U       | Delete+yank (cut) to start of first word in line

### `SELECT` mode keybinds

Press any of the following keys to pass the pressed key through
to whatever application you're using, and return to `DESKTOP` mode.

* `Escape`
* `Enter`
* `Space`
* `Ctrl+C`
* `Ctrl+X`

Select items with basic movements:

| Key | Simulated Keys |
|:---:|:---------------|
| h   | Left
| j   | Down
| k   | Up
| l   | Right

### `COMMAND` mode keybinds

| Combination | Command + mnemonic      | Simulated Keys |
|:-----------:|:-----------------------:|:---------------|
| Ctrl+F      | *F*orward               | Right
| Alt+F       | *F*orward word          | Ctrl+Right
| Ctrl+B      | *B*ack                  | Left
| Alt+B       | *B*ack word             | Ctrl+Left
| Ctrl+A      | st*A*rt of line         | Home
| Ctrl+E      | *E*nd of line           | End
| Ctrl+N      | *N*ext                  | Down
| Ctrl+P      | *P*revious              | Up
| Ctrl+H      | kill last c*H*aracter   | Ctrl+Left, Ctrl+X
| Ctrl+W      | kill last *W*ord        | Ctrl+Shift+Left, Ctrl+X
| Ctrl+D      | *D*elete next character | Ctrl+Right, Ctrl+X
| Alt+D       | *D*elete next word      | Ctrl+Shift+Right, Ctrl+X
| Ctrl+K      | *K*ill rest of line     | Shift+End, Ctrl+X
| Ctrl+U      | *U*ndo entire line      | Home, Shift+End, Ctrl+X
| Ctrl+Y      | un*Y*ank (paste)        | Ctrl+V
| Ctrl+C      | *C*ancel                | Escape, return to `DESKTOP` mode
| Enter       | Done (pass through)     | Enter, return to `DESKTOP` mode
| Escape      | Done (pass through)     | Escape, return to `DESKTOP` mode

### `PASSTHROUGH` mode keybinds

All keypresses will be passed through, except
`Ctrl+Alt+Escape` which returns you to `DESKTOP` mode.

## Deficiencies

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

* Implement tiling mode
* Implement something like [https://autohotkey.com/boards/viewtopic.php?f=6&t=14881]
* Implement proper tags
* Improve vi bindings; e.g. add a VISUAL mode
