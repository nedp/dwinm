﻿/*
 * Original work Copyright 2016 Joshua Graham
 * Modified work Copyright 2016 Ned Pummeroy
 */
debugger(message)
{
	;~ ToolTip, % message
	;~ sleep 100
	return
}

turnCapslockOff()
{
	;if the capslock key is down then set the capslock state to on so that
	;when the user lets go it will change the state to off
	if(GetKeyState("Capslock", "P"))
	{
		SetCapsLockState, On
	} else
	{
		SetCapsLockState , Off
	}
	return
}

/*
 * If we send the keystrokes too quickly you sometimes get a flickering of the screen
 */
send(toSend)
{
	oldDelay := A_KeyDelay
	SetKeyDelay, 5

	send, % toSend

	SetKeyDelay, % oldDelay
	return
}

closeMultitaskingViewFrame()
{
	IfWinActive, ahk_class MultitaskingViewFrame
	{
		send("#{tab}")
	}
	return
}


openMultitaskingViewFrame()
{
	IfWinNotActive, ahk_class MultitaskingViewFrame
	{
		send("#{tab}")
		WinWaitActive, ahk_class MultitaskingViewFrame
	}
	return
}


callFunction(possibleFunction)
{
	if(IsFunc(possibleFunction))
	{
		%possibleFunction%()
	} else if(IsObject(possibleFunction))
	{
		possibleFunction.Call()
	} else if(IsLabel(possibleFunction))
	{
		gosub, % possibleFunction
	}
	return
}

getDesktopNumberFromHotkey(keyCombo)
{
	number := RegExReplace(keyCombo, "[^\d]", "")
	return number == 0 ? 10 : number
}

getIndexFromArray(searchFor, array)
{
	loop, % array.MaxIndex()
	{
		if(array[A_index] == searchFor)
		{
			return A_index
		}
	}
	return -1
}

/* Refocuses the top window.
 *
 * Useful for dealing with nondeterministic start menu
 * and window focusing behaviour when switching desktops and
 * using windows-key commands.
 */
refocus()
{
    send("!+{Escape} !{Escape}")
}
