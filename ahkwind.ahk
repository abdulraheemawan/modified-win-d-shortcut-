#SingleInstance Force
DetectHiddenWindows, Off

ResList=
WinPosArray0=0
return

#d::
IfNotInString, ResList, |Desktop|
	{
	; Show Desktop
	StoreAllWindowsInOrder("Desktop")
	WinMinimizeAll
	}
Else
	{
	; Restore Previous Windows
	StoreAllWindowsInOrder("DesktopUpdate")
	WinMinimizeAllUndo	
	RestoreAllWindowsInOrder("Desktop")
	RestoreAllWindowsInOrder("DesktopUpdate")
	}
return



StoreAllWindowsInOrder(Resolution)
{
	Global

	local WinIDlist
	local WinPosList
	local WinOrder
	local thisID
	local IsMaximized
	local OnTopStyle

	
	SetBatchLines -1  ; Makes searching occur at maximum speed. 
	SetWinDelay, 0	  ; No movement or resize is done, so this should not cause any issues
	Critical
	
	WinIDlist=
	WinPosList=
	WinOrder=1
	
	; Get all visible Windows
	WinGet, WinIDlist, list, ,, Program Manager
	Loop, %WinIDlist%
	{
		thisID := WinIDlist%A_Index%
		
		; Don't store the ID's of already minimized Windows
		WinGet, IsMaximized, MinMax, ahk_id %thisID%
		If IsMaximized=-1
			continue
		
		WinGet, OnTopStyle, ExStyle, ahk_id %thisID%
		OnTopStyle&=0x8  ; 0x8 is WS_EX_TOPMOST.

		WinPosList=%WinPosList%%WinOrder%%A_TAB%%thisID%%A_TAB%%OnTopStyle%`n
		WinOrder+=1
	}
	
	WinPosArray%Resolution%:=WinPosList
	ResList=%ResList%|%Resolution%|
	
	; SetWinDelay is back to normal when returning from this function
	; SetBatchLines is back to normal when returning from this function
	; Critical is Off when returning from this function
}



RestoreAllWindowsInOrder(Resolution)
{
	Global

	local WinPosList
	local Field0					
	local Field1			;Field1=WinOrder		
	local Field2			;Field2=thisID		
	local Field4			;Field3=OnTopStyle		
	
	IfNotInString, ResList, |%Resolution%|
		return

	
	SetBatchLines -1  ; Makes searching occur at maximum speed. 
	SetWinDelay, 0	  ; No movement or resize is done so this should not cause any issues
	Critical

	; WinPosArray is sorted from Top to Bottom so we need to reverse that order
	Sort, WinPosArray%Resolution%, N R
	WinPosList:=WinPosArray%Resolution%
	Loop, parse, WinPosList, `n, `r
	{
	StringSplit, Field, A_LoopField, %A_TAB%
	
	; It turned out that using SetWindowPos with the "HWND_NOTOPMOST" Option is causing the least side effects. 
	; Going the other way and setting the Windows to the Bottom of the stack did result in unwanted behavior of the windows:
	; After restoring the z-Order, you could no longer bring a Window in front of another by just clicking somewhere inside 
	; that window. It was necessary to click on the Window Title bar to bring it in front of other windows.
	; It also works more reliable than DllCall("SetForegroundWindow", "UInt", hWnd)
	
	; http://msdn.microsoft.com/en-us/library/ms633545(v=vs.85).aspx?ppud=4
	; Places the window above all non-topmost windows (that is, behind all topmost windows). This flag has no effect if the window is already a non-topmost window.
	DllCall("SetWindowPos", "uint", Field2, "uint", "-2" , "int", "0", "int", "0", "int", "0", "int", "0"  , "uint", "19") ; 19 = NOSIZE | NOMOVE | NOACTIVATE ( 0x1 | 0x2 | 0x10 )

	; Restore the AlwaysOnTop setting
	If Field3 	; On TopSyle = AlwaysOnTop
		WinSet, AlwaysOnTop, On, ahk_id %Field2%
	
	; Opera did always end up in front of other windows, even so those were originaly above Opera and restored correctly until Opera did rise in front of them.
	; Regardless if SetWindowPos did activate the Window or not. But a WinActivate following SetWindowPos did solve that issue. 
	; Since the IDs of Windows that are originally minimized are not in the List, every Window can be activated
	WinActivate, ahk_id %Field2%
	}
	; SetWinDelay is back to normal when returning from this function
	; SetBatchLines is back to normal when returning from this function
	; Critical is Off when returning from this function
	
	; Clear the now unused global variables
	WinPosArray%Resolution%=
	; Rearm the Toggle function
	StringReplace, ResList, ResList, |%Resolution%|
}