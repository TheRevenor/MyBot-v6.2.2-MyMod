; #FUNCTION# ====================================================================================================================
; Name ..........: BoostBarracks.au3
; Description ...:
; Syntax ........: BoostBarracks(), BoostDarkBarracks(), BoostSpellFactory(), BoostDarkSpellFactory()
; Parameters ....:
; Return values .: None
; Author ........: MR.ViPER
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $DebugBarrackBoost = 0

Func BoostBarracks()
	If $bTrainEnabled = False Then Return
	If $icmbQuantBoostBarracks = 0 Or $icmbBoostBarracks = 0 Then Return
	If $icmbQuantBoostBarracks > 1 Then
		Local $hour = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
		If $iPlannedBoostBarracksHours[$hour[0]] = 0 Then
			SetLog("Boost Barracks are not Planned, Skipped..", $COLOR_BLUE)
			Return ; exit func if no planned Boost Barracks checkmarks
		EndIf
	EndIf

	If $numBarracksAvaiables = 0 Then
		If $DebugBarrackBoost = 1 Then
			openArmyOverview()
			BarracksStatus()
		EndIf
	EndIf

	if $numBarracksAvaiables = 0 then return

	If $icmbQuantBoostBarracks > $numBarracksAvaiables Then
		SetLog("Hey Chief! I can not Boost more than: " & $numBarracksAvaiables & " Barracks .... ")
		Return
	EndIf

	SetLog("Boost Barracks started, checking available Barracks...", $COLOR_BLUE)
	If _Sleep($iDelaycheckArmyCamp1) Then Return

	;######################## CHECK If Number Of Barrackses To Boost Is Number Of Total Barrackses In Village, If True Then Use Boost All Button #####################

	If $icmbQuantBoostBarracks = $numBarracks Then
		SetLog("Boosting All Barrackses", $COLOR_BLUE)
		$btnStatus = CheckIfBoostButtonAvailable(1, True) ; Check If Boost All Button Is Available With Barrack '1'
		If @error Or $btnStatus = False Then ; If Failed To Select Barrack 1,
			$btnStatus = CheckIfBoostButtonAvailable(2, True) ; Check If Boost All Button Is Available With Barrack '2'
			If @error Or $btnStatus = False Then
				$btnStatus = CheckIfBoostButtonAvailable(3, True) ; Check If Boost All Button Is Available With Barrack '3'
				If @error Or $btnStatus = False Then
					$btnStatus = CheckIfBoostButtonAvailable(4, True) ; Check If Boost All Button Is Available With Barrack '4'
					If @error Or $btnStatus = False Then
						SetLog("No Boost Button Found, Or Maybe No Barrack Selected Successfully! Barrack Boost FAILED", $COLOR_ORANGE)
					EndIf
				EndIf
			EndIf
		EndIf ; EndIf For @error or $btnStatus = False

		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostBarracks", "icmbBoostBarracks", True) = True Then ;If Gem Window Was Open, Then Click On GREEN Button And Boost ALL Barrackses
				For $i = 0 To $numBarracks - 1
					$InitBoostTime[$i][0] = 1
					$InitBoostTime[$i][1] = TimerInit()
				Next
				SetLog("All Barrackses Boosted Successfully.", $COLOR_GREEN)
				checkMainScreen(False) ; Check for errors during function
				GUICtrlSetData($cmbBoostBarracks, $icmbBoostBarracks)
				Return True
			EndIf
			checkMainScreen(False) ; Check for errors during function
			SetLog("Failed To Boost All Barrackses, GEM Window Not Displayed", $COLOR_ORANGE)
		EndIf ; EndIf For $btnStatus = True
	EndIf ; EndIf For $icmbQuantBoostBarracks = $numBarracks

	;################################ Number Of Barrackses Too Boost Is NOT Number Of Total Barrackses In Village, SO Boost Barrackses One-By-One ###########################
	SetLog("Boosting Barrackses One-By-One", $COLOR_BLUE)
	Local $BoostedBarrackses = 0
	For $i = 1 To $numBarracks
		If $BoostedBarrackses >= $icmbQuantBoostBarracks Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Barrackses Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		EndIf
		SetLog("Boosting Barrack nº: " & $i, $COLOR_BLUE)
		ClickP($aAway, 1, 0, "#0157")
		_Sleep($iDelayBoostBarracks1)
		$btnStatus = CheckIfBoostButtonAvailable($i)
		If @error Or $btnStatus = False Then ContinueLoop

		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostBarracks", "icmbBoostBarracks", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				$BoostedBarrackses += 1
				$icmbBoostBarracks += 1
				$InitBoostTime[$i - 1][0] = 1
				$InitBoostTime[$i - 1][1] = TimerInit()
				SetLog("Barrack nº: " & $i & " Boosted Successfully.", $COLOR_GREEN)
				If $BoostedBarrackses = $icmbQuantBoostBarracks Then
					$icmbBoostBarracks -= 1
					Setlog(" Total remain cycles to boost Barracks:" & $icmbBoostBarracks, $COLOR_GREEN)
					GUICtrlSetData($cmbBoostBarracks, $icmbBoostBarracks)
				EndIf
			EndIf
		EndIf
	Next
	_Sleep($iDelayBoostBarracks5)
	checkMainScreen(False) ; Check for errors during function
	Return True
EndFunc   ;==>BoostBarracks

Func BoostSpellFactory()
	If $bTrainEnabled = False Then Return
	If $icmbBoostSpellFactory > 0 And $boostsEnabled = 1 Then
		SetLog("Boosting Spell Factory...", $COLOR_BLUE)
		If $SFPos[0] = -1 or $SFPos[0] = 0 or $SFPos[0] = "" Then
			LocateSpellFactory()
			SaveConfig()
			_Sleep($iDelayBoostSpellFactory2)
		EndIf
		ClickP($aAway, 1, 0, "#0161")
		_Sleep($iDelayBoostSpellFactory4)
		Click($SFPos[0], $SFPos[1], 1, 0, "#0162")
		_Sleep($iDelayBoostSpellFactory4)
		$btnStatus = CheckIfBoostButtonAvailable(-1, False, True)
		If @error Or $btnStatus = False Then Return False
		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostSpellFactory", "icmbBoostSpellFactory", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				GUICtrlSetData($cmbBoostSpellFactory, $icmbBoostSpellFactory)
				SetLog("Spell Factory Boosted Successfully.", $COLOR_GREEN)
			EndIf
		EndIf
		_Sleep($iDelayBoostBarracks5)
		checkMainScreen(False) ; Check for errors during function
		Return True
	EndIf
EndFunc   ;==>BoostSpellFactory

Func BoostDarkSpellFactory()
	If $bTrainEnabled = False Then Return
	If $icmbBoostDarkSpellFactory > 0 And ($boostsEnabled = 1) Then
		SetLog("Boosting Dark Spell Factory...", $COLOR_BLUE)
		If $DSFPos[0] = -1 or $DSFPos[0] = 0 or $DSFPos[0] = "" Then
			LocateDarkSpellFactory()
			SaveConfig()
			If _Sleep($iDelayBoostSpellFactory2) Then Return
		EndIf
		ClickP($aAway, 1, 0, "#0161")
		_Sleep($iDelayBoostSpellFactory4)
		Click($DSFPos[0], $DSFPos[1], 1, 0, "#0162")

		_Sleep($iDelayBoostSpellFactory4)
		$btnStatus = CheckIfBoostButtonAvailable(-1, False, True)
		If @error Or $btnStatus = False Then Return False
		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostDarkSpellFactory", "icmbBoostDarkSpellFactory", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				GUICtrlSetData($cmbBoostDarkSpellFactory, $icmbBoostDarkSpellFactory)
				SetLog("DARK Spell Factory Boosted Successfully.", $COLOR_GREEN)
			EndIf
		EndIf
		_Sleep($iDelayBoostBarracks5)
		checkMainScreen(False) ; Check for errors during function
		Return True
	EndIf
EndFunc   ;==>BoostDarkSpellFactory

Func IsGemWindowOpen($varToChange1, $varToChange2, $AcceptGem = False, $NeedCapture = True)
	If $DebugBarrackBoost = 1 Then SetLog("Func IsGemWindowOpen(" & $AcceptGem & ", " & $NeedCapture & ")", $COLOR_PURPLE)
	_Sleep($iDelayisGemOpen1)
	If _ColorCheck(_GetPixelColor(314, 249 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) Then
		If _ColorCheck(_GetPixelColor(440, 424 + $midOffsetY, True), Hex(0x0d1903, 6), 20) Then
			If $debugSetlog = 1 or $DebugBarrackBoost = 1 Then Setlog("DETECTED, GEM Window Is OPEN", $COLOR_PURPLE)
			If $AcceptGem = True Then
				Click(425, 425)
				_Sleep($iDelayBoostBarracks2)
				If _ColorCheck(_GetPixelColor(586, 267 + $midOffsetY, True), Hex(0xd80405, 6), 20) Then
					Assign($varToChange1, 0, 4)
					SetLog("Not enough gems", $COLOR_RED)
					ClickP($aAway, 1, 0, "#0161")
				Else
					Assign($varToChange2, Eval($varToChange2) - 1, 4)
					SetLog('Boost completed. Remaining : ' & Eval($varToChange2), $COLOR_GREEN)
				EndIf
			Else
				PureClickP($aAway, 1, 0, "#0140") ; click away to close gem window
			EndIf
			_Sleep($iDelayBoostSpellFactory3)
			ClickP($aAway, 1, 0, "#0161")
			If $DebugBarrackBoost = 1 Then SetLog("Func IsGemWindowOpen(" & $AcceptGem & ") = TRUE", $COLOR_GREEN)
			Return True
		EndIf
	EndIf
	If $DebugBarrackBoost = 1 Then SetLog("Func IsGemWindowOpen(" & $AcceptGem & ", " & $NeedCapture & ") = FALSE", $COLOR_GREEN)
	Return False
EndFunc

Func CheckIfBoostButtonAvailable($BRNum, $BoostAllBtn = False, $ClickAlso = True)
	If $DebugBarrackBoost = 1 Then SetLog("Func CheckIfBoostButtonAvailable(" & $BRNum & ", " & $BoostAllBtn & ", " & $ClickAlso & ")", $COLOR_PURPLE)
	Local $ImagesToUse[2] ; Boost All
	$ImagesToUse[0] = @ScriptDir & "\images\Button\BoostAllBarracks.png"
	$ImagesToUse[1] = @ScriptDir & "\images\Button\BoostBarrack.png"
	;$ImagesToUse[2] = @ScriptDir & "\images\Button\BoostedBarrack.png"
	If FileExists($ImagesToUse[0]) And FileExists($ImagesToUse[1]) Then
		$ToleranceImgLoc = 0.92
		If SelectBarrack($BRNum) or $BRNum = -1 Then
			_CaptureRegion2(125, 610, 740, 715)
			$res = ""
			If $BoostAllBtn = True Then ; Determine What Button It Should Search For
				$res = DllCall($hImgLib, "str", "SearchTile", "handle", $hHBitmap2, "str", $ImagesToUse[0], "float", $ToleranceImgLoc, "str", "FV", "int", 1)
				If @error Then _logErrorDLLCall($pImgLib, @error)
			ElseIf $BoostAllBtn = False Then
				$res = DllCall($hImgLib, "str", "SearchTile", "handle", $hHBitmap2, "str", $ImagesToUse[1], "float", $ToleranceImgLoc, "str", "FV", "int", 1)
				If @error Then _logErrorDLLCall($pImgLib, @error)
			EndIf
			If IsArray($res) Then
				If $debugSetlog = 1 Then SetLog("DLL Call succeeded " & $res[0], $COLOR_RED)
				If $res[0] = "0" Or $res[0] = "" Then
					; failed to find Boost Button
					If $debugSetlog Then SetLog("No Boost Button found")
					If IsBoosted() = False Then
						SetLog("No Boost Button Found", $COLOR_RED)
						Return False
					Else
						SetLog("No Need To Boost, It's Already Boosted", $COLOR_GREEN)
						Return "Boosted"
					EndIf
				ElseIf $res[0] = "-1" Then
					SetLog("DLL Error", $COLOR_RED)
				ElseIf $res[0] = "-2" Then
					SetLog("Invalid Resolution", $COLOR_RED)
				Else
					$expRet = StringSplit($res[0], "|", $STR_NOCOUNT)
					$posPoint = StringSplit($expRet[1], ",", $STR_NOCOUNT)
					$ButtonX = 125 + Int($posPoint[0])
					$ButtonY = 610 + Int($posPoint[1])
					If $ClickAlso = False Then Return True
					If $ClickAlso Then Click($ButtonX, $ButtonY, 1, 0, "#04006")
					Return True
				EndIf
			EndIf ;EndIf for: If IsArray($res)
		Else
			SetError(1, 0)
		EndIf ;EndIf For SelectBarrack($BRNum)
	Else
		Return False
	EndIf ;EndIf For FileExists($ImagesToUse1[0]) AND FileExists($ImagesToUse1[1])
EndFunc   ;==>CheckIfBoostButtonAvailable

Func IsBoosted()
	Local $ImagesToUse[1] ; Boost All
	$BoostedButtonX = 0
	$BoostedButtonY = 0

	$ImagesToUse[0] = @ScriptDir & "\images\Button\BarrackBoosted.png"
	If FileExists($ImagesToUse[0]) Then
		$ToleranceImgLoc = 0.92
		_CaptureRegion2(125, 610, 740, 715)
		$res = DllCall($hImgLib, "str", "SearchTile", "handle", $hHBitmap2, "str", $ImagesToUse[0], "float", $ToleranceImgLoc, "str", "FV", "int", 1)
		If IsArray($res) Then
			If $debugSetlog = 1 Then SetLog("DLL Call succeeded " & $res[0], $COLOR_RED)
			If $res[0] = "0" Or $res[0] = "" Then
				If $debugSetlog = 1 Then SetLog("No Button found")
			ElseIf StringLeft($res[0], 2) = "-1" Then
				SetLog("DLL Error: " & $res[0], $COLOR_RED)
			Else
				$expRet = StringSplit($res[0], "|", $STR_NOCOUNT)
				$posPoint = StringSplit($expRet[1], ",", $STR_NOCOUNT)
				$BoostedButtonX = 125 + Int($posPoint[0])
				$BoostedButtonY = 610 + Int($posPoint[1])
				;SetLog("$BoostedButtonX: " & $BoostedButtonX & "| $BoostedButtonY: " & $BoostedButtonY)
				Return True
			EndIf
		EndIf ;EndIf for: If IsArray($res)
	Else
		Return False
	EndIf
EndFunc   ;==>IsBoosted

Func SelectBarrack($BRNum) ; 3
	If $DebugBarrackBoost = 1 Then SetLog("Func SelectBarrack(" & $BRNum & ")", $COLOR_PURPLE)
	If $BRNum = 0 or $BRNum > 4 Then CheckForBarrackNoPos()
	Local $CorrectBRNum

	; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
	$x = 0
	For $i = 1 To 4 ; from $Trainavailable[1] to $Trainavailable[4]
		If $Trainavailable[$i] = 1 Then
			$x += 1
			If $x = $BRNum Then
				$CorrectBRNum = $i ; this is the correct $barrackPos = $numBarrackAvailables
				ExitLoop
			EndIf
		EndIf
	Next

	If $barrackPos[0][0] = -1 Or $barrackPos[0][0] = 0 Or $barrackPos[0][0] = "" Then LocateBarrack2()
	If $barrackPos[3][0] = -1 Or $barrackPos[3][0] = 0 Or $barrackPos[3][0] = "" Then LocateBarrack2()

	Select
		Case $CorrectBRNum = -1
			If $DebugBarrackBoost = 1 Then SetLog("No Need To Select Barrack", $COLOR_GREEN)
		Case $CorrectBRNum = 1
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($barrackPos[0][0], $barrackPos[0][1], 1, 0)
		Case $CorrectBRNum = 2
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($barrackPos[1][0], $barrackPos[1][1], 1, 0)
		Case $CorrectBRNum = 3
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($barrackPos[2][0], $barrackPos[2][1], 1, 0)
		Case $CorrectBRNum = 4
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($barrackPos[3][0], $barrackPos[3][1], 1, 0)
		Case Else
			If $DebugBarrackBoost = 1 Then SetLog("Func SelectBarrack(" & $CorrectBRNum & ") = FALSE", $COLOR_RED)
			Return False
	EndSelect


	If $DebugBarrackBoost = 1 Then SetLog("Func SelectBarrack(" & $CorrectBRNum & ") = TRUE", $COLOR_GREEN)
	_Sleep($iDelayBoostBarracks1)
	Return True
EndFunc   ;==>SelectBarrack

Func SelectDarkBarrack($BRNum)
	If $DebugBarrackBoost = 1 Then SetLog("Func SelectBarrack(" & $BRNum & ")", $COLOR_PURPLE)
	; If $BRNum = -1 = False Then CheckForBarrackNoPos()
	Local $CorrectBRNum

	; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
	$x = 0
	For $i = 5 To 6 ; from $Trainavailable[1] to $Trainavailable[4]
		If $Trainavailable[$i] = 1 Then
			$x += 1
			If $x = $BRNum Then
				$CorrectBRNum = $i ; this is the correct $barrackPos = $numBarrackAvailables
				ExitLoop
			EndIf
		EndIf
	Next
	If $DebugBarrackBoost = 1 Then SetLog("$CorrentBRNum = " & $CorrectBRNum, $COLOR_BLUE)

	If $DarkbarrackPos[0][0] = -1 Or $DarkbarrackPos[0][0] = 0 Or $DarkbarrackPos[0][0] = "" Then LocateDarkBarrack()
	If $DarkbarrackPos[1][0] = -1 Or $DarkbarrackPos[1][0] = 0 Or $DarkbarrackPos[1][0] = "" Then LocateDarkBarrack()

	Select
		Case $CorrectBRNum = -1
			If $DebugBarrackBoost = 1 Then SetLog("No Need To Select Barrack", $COLOR_GREEN)
		Case $CorrectBRNum = 5
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($DarkbarrackPos[0][0], $DarkbarrackPos[0][1], 1, 0)
		Case $CorrectBRNum = 6
			ClickP($aAway, 1, 0)
			_Sleep($iDelayBoostBarracks1)
			Click($DarkbarrackPos[1][0], $DarkbarrackPos[1][1], 1, 0)
		Case Else
			If $DebugBarrackBoost = 1 Then SetLog("Func SelectDarkBarrack(" & $CorrectBRNum & ") = FALSE", $COLOR_RED)
			Return False
	EndSelect


	If $DebugBarrackBoost = 1 Then SetLog("Func SelectBarrack(" & $CorrectBRNum & ") = TRUE", $COLOR_GREEN)
	_Sleep($iDelayBoostBarracks1)
	Return True

EndFunc   ;==>SelectDarkBarrack

Func CheckForBarrackNoPos()
	If $DebugBarrackBoost = 1 Then SetLog("Func CheckForBarrackNoPos()", $COLOR_PURPLE)
	If $numBarracksAvaiables = 0 Then
		If $DebugBarrackBoost = 1 Then
			openArmyOverview()
			BarracksStatus() ; this will check and returns the correct $Trainavailable
		EndIf
	EndIf
	For $i = 0 To ($numBarracksAvaiables - 1)
		If $barrackPos[$i][0] = "" Or $barrackPos[$i][1] = "" Then
			SetLog("Barrack nº " & $i + 1 & " Not Located", $COLOR_ORANGE)
			SetLog("Locate It By It's Index In Army Overview Tab Index", $COLOR_ORANGE)
			LocateBarrack()
			SaveConfig()
			If $DebugBarrackBoost = 1 Then SetLog("ReCalling Func CheckForBarrackNoPos() Due To Barrack nº " & $i + 1 & " ReLocated", $COLOR_PURPLE)
			CheckForBarrackNoPos() ; *****ing AutoIt Doesn't have GoTo Statement
		Else
			If $DebugBarrackBoost = 1 Then SetLog("Barrack nº " & $i + 1 & " Is Located: (" & $barrackPos[$i][0] & ", " & $barrackPos[$i][0] & ")", $COLOR_GREEN)
		EndIf
	Next
	Return True
EndFunc   ;==>CheckForBarrackNoPos

Func BoostDarkBarracks()
	If $bTrainEnabled = False Then Return
	If $icmbQuantBoostDarkBarracks = 0 Or $icmbBoostDarkBarracks = 0 Then Return
	If $icmbQuantBoostDarkBarracks > 1 Then
		Local $hour = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
		If $iPlannedBoostBarracksHours[$hour[0]] = 0 Then
			SetLog("Boost Dark Barracks are not Planned, Skipped..", $COLOR_BLUE)
			Return ; exit func if no planned Boost Barracks checkmarks
		EndIf
	EndIf

	If $numDarkBarracksAvaiables = 0 Then
		If $DebugBarrackBoost = 1 Then
			openArmyOverview()
			BarracksStatus()
		EndIf
	EndIf

	If $numDarkBarracksAvaiables = 0 then return

	If $icmbQuantBoostDarkBarracks > $numDarkBarracksAvaiables Then
		SetLog("Hey Chief! I can not Boost more than: " & $numDarkBarracksAvaiables & " Dark Barracks .... ")
		Return
	EndIf

	SetLog("Boost Dark Barracks started, checking available Barracks...", $COLOR_BLUE)
	If _Sleep($iDelaycheckArmyCamp1) Then Return

	;######################## CHECK If Number Of Barrackses To Boost Is Number Of Total Barrackses In Village, If True Then Use Boost All Button #####################

	If $icmbQuantBoostDarkBarracks = $numDarkBarracksAvaiables Then
		SetLog("Boosting All Dark Barrackses", $COLOR_BLUE)
		$btnStatus = CheckIfDarkBoostButtonAvailable(1, True) ; Check If Boost All Button Is Available With Barrack '1'
		If @error Or $btnStatus = False Then ; If Failed To Select Barrack 1,
			$btnStatus = CheckIfDarkBoostButtonAvailable(2, True) ; Check If Boost All Button Is Available With Barrack '2'
		EndIf ; EndIf For @error or $btnStatus = False

		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostDarkBarracks", "icmbBoostDarkBarracks", True) = True Then ;If Gem Window Was Open, Then Click On GREEN Button And Boost ALL Barrackses
				For $i = 0 To $numDarkBarracks - 1
					$InitBoostTimeDark[$i][0] = 1
					$InitBoostTimeDark[$i][1] = TimerInit()
				Next
				SetLog("All Dark Barracks Boosted Successfully.", $COLOR_GREEN)
				checkMainScreen(False) ; Check for errors during function
				GUICtrlSetData($cmbBoostDarkBarracks, $icmbBoostDarkBarracks)
				Return True
			EndIf
			checkMainScreen(False) ; Check for errors during function
			SetLog("Failed To Boost All DARK Barracks, GEM Window Not Displayed", $COLOR_ORANGE)
		EndIf ; EndIf For $btnStatus = True
	EndIf ; EndIf For $icmbQuantBoostDarkBarracks = $numBarracks

	;################################ Number Of Barrackses Too Boost Is NOT Number Of Total Barrackses In Village, SO Boost Barrackses One-By-One ###########################
	SetLog("Boosting Dark Barracks One-By-One", $COLOR_BLUE)
	Local $BoostedBarrackses = 0
	For $i = 1 To $numDarkBarracks
		If $BoostedBarrackses >= $icmbQuantBoostDarkBarracks Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Dark Barracks Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		EndIf
		SetLog("Boosting Dark Barrack nº: " & $i, $COLOR_BLUE)
		ClickP($aAway, 1, 0, "#0157")
		_Sleep($iDelayBoostBarracks1)
		$btnStatus = CheckIfDarkBoostButtonAvailable($i)
		If @error Or $btnStatus = False Then ContinueLoop

		If $btnStatus = True Then
			If IsGemWindowOpen("icmbBoostDarkBarracks", "icmbBoostDarkBarracks", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				$BoostedBarrackses += 1
				$icmbBoostDarkBarracks += 1
				$InitBoostTimeDark[$i - 1][0] = 1
				$InitBoostTimeDark[$i - 1][1] = TimerInit()
				SetLog("Barrack nº: " & $i & " Boosted Successfully.", $COLOR_GREEN)
				If $BoostedBarrackses = $icmbQuantBoostDarkBarracks Then
					$icmbBoostDarkBarracks -= 1
					Setlog(" Total remain cycles to boost Barracks:" & $icmbBoostDarkBarracks, $COLOR_GREEN)
					GUICtrlSetData($cmbBoostDarkBarracks, $icmbBoostDarkBarracks)
				EndIf
			EndIf
		EndIf
	Next
	_Sleep($iDelayBoostBarracks5)
	checkMainScreen(False) ; Check for errors during function
	Return True
EndFunc   ;==>BoostDarkBarracks

Func CheckIfDarkBoostButtonAvailable($BRNum, $BoostAllBtn = False, $ClickAlso = True)
	If $DebugBarrackBoost = 1 Then SetLog("Func CheckIfDarkBoostButtonAvailable(" & $BRNum & ", " & $BoostAllBtn & ", " & $ClickAlso & ")", $COLOR_PURPLE)
	Local $ImagesToUse[2] ; Boost All
	$ImagesToUse[0] = @ScriptDir & "\images\Button\BoostAllBarracks.png"
	$ImagesToUse[1] = @ScriptDir & "\images\Button\BoostBarrack.png"
	;$ImagesToUse[2] = @ScriptDir & "\images\Button\BoostedBarrack.png"
	If FileExists($ImagesToUse[0]) And FileExists($ImagesToUse[1]) Then
		$ToleranceImgLoc = 0.92
		If SelectDarkBarrack($BRNum) Then
			_CaptureRegion2(125, 610, 740, 715)
			$res = ""
			If $BoostAllBtn = True Then ; Determine What Button It Should Search For
				$res = DllCall($hImgLib, "str", "SearchTile", "handle", $hHBitmap2, "str", $ImagesToUse[0], "float", $ToleranceImgLoc, "str", "FV", "int", 1)
				If @error Then _logErrorDLLCall($pImgLib, @error)
			ElseIf $BoostAllBtn = False Then
				$res = DllCall($hImgLib, "str", "SearchTile", "handle", $hHBitmap2, "str", $ImagesToUse[1], "float", $ToleranceImgLoc, "str", "FV", "int", 1)
				If @error Then _logErrorDLLCall($pImgLib, @error)
			EndIf
			If IsArray($res) Then
				If $debugSetlog = 1 Then SetLog("DLL Call succeeded " & $res[0], $COLOR_RED)
				If $res[0] = "0" Or $res[0] = "" Then
					; failed to find Boost Button
					If $debugSetlog Then SetLog("No Boost Button found")
					If IsBoosted() = False Then
						SetLog("No Boost Button Found", $COLOR_RED)
						Return False
					Else
						SetLog("No Need To Boost, It's Already Boosted", $COLOR_GREEN)
						Return "Boosted"
					EndIf
				ElseIf $res[0] = "-1" Then
					SetLog("DLL Error", $COLOR_RED)
				ElseIf $res[0] = "-2" Then
					SetLog("Invalid Resolution", $COLOR_RED)
				Else
					$expRet = StringSplit($res[0], "|", $STR_NOCOUNT)
					$posPoint = StringSplit($expRet[1], ",", $STR_NOCOUNT)
					$ButtonX = 125 + Int($posPoint[0])
					$ButtonY = 610 + Int($posPoint[1])
					If $ClickAlso = False Then Return True
					If $ClickAlso Then Click($ButtonX, $ButtonY, 1, 0, "#04006")
					Return True
				EndIf
			EndIf ;EndIf for: If IsArray($res)
		Else
			SetError(1, 0)
		EndIf ;EndIf For SelectBarrack($BRNum)
	Else
		Return False
	EndIf ;EndIf For FileExists($ImagesToUse1[0]) AND FileExists($ImagesToUse1[1])
EndFunc   ;==>CheckIfDarkBoostButtonAvailable