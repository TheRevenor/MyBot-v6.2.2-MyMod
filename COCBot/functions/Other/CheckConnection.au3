; #FUNCTION# ====================================================================================================================
; Name ..........: Check Connection
; Description ...: Close Emulator When Connection Lost
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: TheRevenor(July, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#include <MsgBoxConstants.au3>

Func ChckInetCon()
Local $i = 0
If GUICtrlRead($chkConnection) = $GUI_CHECKED Then
	$ichkConnection = 1
	;MsgBox($MB_SYSTEMMODAL, "Close Emulator", "No Internet Connection Will Close Emulator", 5)
	SetLog("Lost Internet Connection Waiting Few Sec Before Close Emulator", $COLOR_RED)
	While $i < 5
		$ping = Ping("8.8.8.8")
		If $ping = 0 Then
			$i = $i + 1
			SetLog("My Ping: " & $Ping & "ms.", $COLOR_RED)
		ElseIf $ping > 0 Then
			SetLog("My Ping: " & $Ping & "ms.", $COLOR_GREEN)
			SetLog("Internet Reconnected Close Emulator Canceled", $COLOR_GREEN)
		ExitLoop
		Else
			$i = 0
		EndIf
		Sleep(5000)
	WEnd
Else
	$ichkConnection = 0
	If $debugsetlog = 1 Then Setlog("Check Internet Connections skip", $COLOR_PURPLE)
	Return ; exit func if no checkmarks
EndIf
; If the script gets here, we missed 5 pings - take action.
If $ping = 0 Then
	CloseAndroid()	; Close Emulator
If _Sleep(5000) Then Return
	SetLog("Waiting Internet Connection..", $COLOR_BLUE)
	CheckConnection()
EndIf
EndFunc ;==>ChckInetCon

Func CheckConnection()
Local $AmIConnected = "init"
While $AmIConnected <> "True"
	$ping = Ping("8.8.8.8")
	If $ping = 0 Then
		SetLog("My Ping: " & $Ping & "ms.", $COLOR_RED)
	ElseIf $ping > 0 Then
		SetLog("My Ping: " & $Ping & "ms.", $COLOR_GREEN)
		$AmIConnected = "True"
	EndIf
	Sleep(5000)
WEnd
SetLog("Internet Reconnected Will Start Emulator", $COLOR_BLUE)
StartAndroidCoC()	; Open Emulator
_PushToPushBullet(@HOUR & ":" & @MIN &" - " & $iOrigPushBullet & " | Internet Reconnected After Lost Connection - Open Emulator and CoC..")
EndFunc ;==>CheckConnection
