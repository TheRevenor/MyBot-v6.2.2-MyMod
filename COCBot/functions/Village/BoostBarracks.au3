; #FUNCTION# ====================================================================================================================
; Name ..........: BoostBarracks.au3
; Description ...:
; Syntax ........: BoostBarracks(), BoostDarkBarracks(), BoostSpellFactory(), BoostDarkSpellFactory()
; Parameters ....:
; Return values .: None
; Author ........: MR.ViPER
; Modified ......: MR.ViPER (9-9-2016)
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
		openArmyOverview()
		BarracksStatus()
	EndIf

	If $numBarracksAvaiables = 0 Then Return
	If isEnoughBarracksesAlreadyBoosted() = True Then Return ; Exit function if Number of already boosted barracks is equal to Number of barrackses to boost

	SetLog("Boost Barracks started...", $COLOR_BLUE)
	If _Sleep($iDelaycheckArmyCamp1) Then Return

	If $totalPossibleBoostTimes = 0 Then $totalPossibleBoostTimes = (Number($icmbBoostBarracks) * Number($icmbQuantBoostBarracks))
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
			If IsGemWindowOpen("", "", True) = True Then ;If Gem Window Was Open, Then Click On GREEN Button And Boost ALL Barrackses
				For $i = 0 To $numBarracks - 1
					If IsBoostedSuccessfully($i + 1) = True Then
						$InitBoostTime[$i][0] = 1
						$InitBoostTime[$i][1] = TimerInit()
						$totalPossibleBoostTimes -= 1
						$totalPossibleBoostBarrackses -= $totalPossibleBoostBarrackses
						WorksWithBoostedBarrackses()
						If IsFinishedBoostForThisCycle() = True Then
							SetLog("All Barrackses Boosted Successfully.", $COLOR_GREEN)
							If $icmbBoostBarracks >= 1 Then $icmbBoostBarracks -= 1
							Setlog(" Total remain cycles to boost Barracks:" & $icmbBoostBarracks, $COLOR_GREEN)
							GUICtrlSetData($cmbBoostBarracks, $icmbBoostBarracks)
							checkMainScreen(False) ; Check for errors during function
							Return True
						EndIf
					EndIf
				Next
				SetLog("All Barrackses Boosted Successfully.", $COLOR_GREEN)
				checkMainScreen(False) ; Check for errors during function
				Return True
			EndIf
			checkMainScreen(False) ; Check for errors during function
			SetLog("Failed To Boost All Barrackses, GEM Window Not Displayed", $COLOR_ORANGE)
		EndIf ; EndIf For $btnStatus = True
	EndIf ; EndIf For $icmbQuantBoostBarracks = $numBarracks

	;################################ Number Of Barrackses Too Boost Is NOT Number Of Total Barrackses In Village, SO Boost Barrackses One-By-One ###########################
	SetLog("Boosting Barrackses One-By-One", $COLOR_BLUE)
	For $i = 1 To $numBarracks
		If IsFinishedBoostForThisCycle() = True Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Barrackses Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		ElseIf CanBoostOneMoreBarrack() = False Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Barrackses Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		EndIf
		SetLog("Boosting Barrack nº: " & $i, $COLOR_BLUE)
		ClickP($aAway, 1, 0, "#0157")
		If _Sleep($iDelayBoostBarracks1) Then Return
		$btnStatus = CheckIfBoostButtonAvailable($i)
		If @error Or $btnStatus = False Then ContinueLoop

		If $btnStatus = True Then
			If IsGemWindowOpen("", "", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				If IsBoostedSuccessfully($i) = True Then
					$InitBoostTime[$i - 1][0] = 1
					$InitBoostTime[$i - 1][1] = TimerInit()
					$totalPossibleBoostTimes -= 1
					$totalPossibleBoostBarrackses -= 1
					WorksWithBoostedBarrackses()
					SetLog("Barrack nº: " & $i & " Boosted Successfully.", $COLOR_GREEN)
				EndIf
				If IsFinishedBoostForThisCycle() = True Then
					If $icmbBoostBarracks >= 1 Then $icmbBoostBarracks -= 1
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
		openArmyOverview()
		BarracksStatus()
	EndIf

	If $numDarkBarracksAvaiables = 0 Then Return
	If isEnoughBarracksesAlreadyBoostedDARK() = True Then Return ; Exit function if Number of already boosted DARK barracks is equal to Number of barrackses to boost

	SetLog("Boost Dark Barracks started...", $COLOR_BLUE)
	If _Sleep($iDelaycheckArmyCamp1) Then Return

	If $totalPossibleBoostTimesDARK = 0 Then $totalPossibleBoostTimesDARK = (Number($icmbBoostDarkBarracks) * Number($icmbQuantBoostDarkBarracks))

	;######################## CHECK If Number Of Barrackses To Boost Is Number Of Total Barrackses In Village, If True Then Use Boost All Button #####################

	If $icmbQuantBoostDarkBarracks = $numDarkBarracksAvaiables Then
		SetLog("Boosting All Dark Barrackses", $COLOR_BLUE)
		$btnStatus = CheckIfDarkBoostButtonAvailable(1, True) ; Check If Boost All Button Is Available With Barrack '1'
		If @error Or $btnStatus = False Then ; If Failed To Select Barrack 1,
			$btnStatus = CheckIfDarkBoostButtonAvailable(2, True) ; Check If Boost All Button Is Available With Barrack '2'
			If @error Or $btnStatus = False Then
				SetLog("No Boost Button Found, Or Maybe No Dark Barrack Selected Successfully! Trying Another way...", $COLOR_ORANGE)
			EndIf
		EndIf ; EndIf For @error or $btnStatus = False

		If $btnStatus = True Then
			If IsGemWindowOpen("", "", True) = True Then ;If Gem Window Was Open, Then Click On GREEN Button And Boost ALL Barrackses
				For $i = 0 To $numDarkBarracks - 1
					If IsBoostedSuccessfully($i + 1, True) = True Then
						$InitBoostTimeDark[$i][0] = 1
						$InitBoostTimeDark[$i][1] = TimerInit()
						$totalPossibleBoostTimesDARK -= 1
						$totalPossibleBoostBarracksesDARK -= $totalPossibleBoostBarracksesDARK
						WorksWithBoostedBarrackses("DARK")
						If IsFinishedBoostForThisCycleDARK() = True Then
							SetLog("All Dark Barrackses Boosted Successfully.", $COLOR_GREEN)
							If $icmbBoostDarkBarracks >= 1 Then $icmbBoostDarkBarracks -= 1
							Setlog(" Total remain cycles to boost Dark Barracks:" & $icmbBoostDarkBarracks, $COLOR_GREEN)
							GUICtrlSetData($cmbBoostDarkBarracks, $icmbBoostDarkBarracks)
							checkMainScreen(False) ; Check for errors during function
							Return True
						EndIf
					EndIf
				Next
				SetLog("All Dark Barracks Boosted Successfully.", $COLOR_GREEN)
				checkMainScreen(False) ; Check for errors during function
				Return True
			EndIf
			checkMainScreen(False) ; Check for errors during function
			SetLog("Failed To Boost All DARK Barracks, GEM Window Not Displayed", $COLOR_ORANGE)
		EndIf ; EndIf For $btnStatus = True
	EndIf ; EndIf For $icmbQuantBoostDarkBarracks = $numBarracks

	;################################ Number Of Barrackses Too Boost Is NOT Number Of Total Barrackses In Village, SO Boost Barrackses One-By-One ###########################
	SetLog("Boosting Dark Barracks One-By-One", $COLOR_BLUE)
	For $i = 1 To $numDarkBarracks
		If IsFinishedBoostForThisCycleDARK() Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Dark Barracks Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		ElseIf CanBoostOneMoreBarrack(True) = False Then
			_Sleep($iDelayBoostBarracks5)
			checkMainScreen(False) ; Check for errors during function
			SetLog("Barrackses Boosted Successfully", $COLOR_GREEN)
			Return True
			ExitLoop
		EndIf
		SetLog("Boosting Dark Barrack nº: " & $i, $COLOR_BLUE)
		ClickP($aAway, 1, 0, "#0157")
		If _Sleep($iDelayBoostBarracks1) Then Return
		$btnStatus = CheckIfDarkBoostButtonAvailable($i)
		If @error Or $btnStatus = False Then ContinueLoop

		If $btnStatus = True Then
			If IsGemWindowOpen("", "", True) = True Then ; If Gem Window Was Open, Then Click On GREEN Button And Boost Barrack
				If IsBoostedSuccessfully($i, True) = True Then
				$InitBoostTimeDark[$i - 1][0] = 1
				$InitBoostTimeDark[$i - 1][1] = TimerInit()
				$totalPossibleBoostTimesDARK -= 1
				$totalPossibleBoostBarracksesDARK -= 1
				WorksWithBoostedBarrackses("DARK")
				SetLog("Dark Barrack nº: " & $i & " Boosted Successfully.", $COLOR_GREEN)
				EndIf
				If IsFinishedBoostForThisCycleDARK() = True Then
					If $icmbBoostDarkBarracks >= 1 Then $icmbBoostDarkBarracks -= 1
					Setlog(" Total remain cycles to boost Dark Barracks:" & $icmbBoostDarkBarracks, $COLOR_GREEN)
					GUICtrlSetData($cmbBoostDarkBarracks, $icmbBoostDarkBarracks)
				EndIf
			EndIf
		EndIf
	Next
	_Sleep($iDelayBoostBarracks5)
	checkMainScreen(False) ; Check for errors during function
	Return True
EndFunc   ;==>BoostDarkBarracks

Func BoostSpellFactory()
	If $bTrainEnabled = False Then Return
	If $icmbBoostSpellFactory > 0 And $boostsEnabled = 1 Then
		SetLog("Boosting Spell Factory...", $COLOR_BLUE)
		If $SFPos[0] = -1 Or $SFPos[0] = 0 Or $SFPos[0] = "" Then
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
		If $DSFPos[0] = -1 Or $DSFPos[0] = 0 Or $DSFPos[0] = "" Then
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

Func CanBoostOneMoreBarrack($isDarkBoost = False)
	Select
		Case $isDarkBoost = False
			If $totalPossibleBoostBarrackses <= 0 Then Return False
			Return True
		Case Else
			If $totalPossibleBoostBarracksesDARK <= 0 Then Return False
			Return True
	EndSelect
EndFunc   ;==>CanBoostOneMoreBarrack

Func isEnoughBarracksesAlreadyBoosted()
	If $totalPossibleBoostBarrackses <= 0 Then $totalPossibleBoostBarrackses = $icmbQuantBoostBarracks
	$tAlreadyBoosted = 0
	For $i = 1 To $numBarracks
		SelectBarrack($i)
		$res = IsBoosted()
		If $res = True Then $tAlreadyBoosted += 1
	Next
	If $DebugBarrackBoost = 1 Then SetLog("$tAlreadyBoosted = " & $tAlreadyBoosted & "  $icmbQuantBoostBarracks = " & $icmbQuantBoostBarracks, $COLOR_BLUE)
	If $tAlreadyBoosted > 0 Then $totalPossibleBoostBarrackses -= $tAlreadyBoosted
	If $DebugBarrackBoost = 1 Then SetLog("$totalPossibleBoostBarrackses = " & $totalPossibleBoostBarrackses, $COLOR_BLUE)
	If $tAlreadyBoosted = $icmbQuantBoostBarracks Then
		SetLog("Enough Barrackses are already boosted, Skipping Barracks boost", $COLOR_BLUE)
		Return True
	ElseIf $tAlreadyBoosted > $icmbQuantBoostBarracks Then
		SetLog($tAlreadyBoosted & " Barracks are Already boosted, Higher than Number Setted in GUI! Maybe Something is wrong, Otherwise Skipping Barracks Boost", $COLOR_ORANGE)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>isEnoughBarracksesAlreadyBoosted

Func isEnoughBarracksesAlreadyBoostedDARK()
	If $totalPossibleBoostBarracksesDARK <= 0 Then $totalPossibleBoostBarracksesDARK = $icmbQuantBoostDarkBarracks
	$tAlreadyBoostedDARK = 0
	For $i = 1 To $numDarkBarracks
		SelectDarkBarrack($i)
		$res = IsBoosted()
		If $res = True Then $tAlreadyBoostedDARK += 1
	Next
	If $DebugBarrackBoost = 1 Then SetLog("$tAlreadyBoostedDARK = " & $tAlreadyBoostedDARK & "  $icmbQuantBoostDarkBarracks = " & $icmbQuantBoostDarkBarracks, $COLOR_BLUE)
	If $tAlreadyBoostedDARK > 0 Then $totalPossibleBoostBarracksesDARK -= $tAlreadyBoostedDARK
	If $DebugBarrackBoost = 1 Then SetLog("$totalPossibleBoostBarracksesDARK = " & $totalPossibleBoostBarracksesDARK, $COLOR_BLUE)
	If $tAlreadyBoostedDARK = $icmbQuantBoostDarkBarracks Then
		SetLog("Enough Dark Barrackses are already boosted, Skipping Dark Barracks boost", $COLOR_BLUE)
		Return True
	ElseIf $tAlreadyBoostedDARK > $icmbQuantBoostDarkBarracks Then
		SetLog($tAlreadyBoostedDARK & " Dark Barracks are Already boosted, Higher than Number Setted in GUI! Maybe Something is wrong, Otherwise Skipping Dark Barracks Boost", $COLOR_ORANGE)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>isEnoughBarracksesAlreadyBoostedDARK

Func WorksWithBoostedBarrackses($BType = "ELIXIR", $operator = "+", $iNumWorksWith = 1)
	Select
		Case $BType = "ELIXIR"
			Select
				Case $operator = "+"
					$BoostedBarrackses += $iNumWorksWith
				Case $operator = "-"
					$BoostedBarrackses -= $iNumWorksWith
			EndSelect
		Case $BType = "DARK"
			Select
				Case $operator = "+"
					$BoostedBarracksesDARK += $iNumWorksWith
				Case $operator = "-"
					$BoostedBarracksesDARK -= $iNumWorksWith
			EndSelect
	EndSelect
	Return $BoostedBarrackses
EndFunc   ;==>WorksWithBoostedBarrackses

Func IsFinishedBoostForThisCycle()
	If $totalPossibleBoostTimes <= 0 Then
		If $DebugBarrackBoost = 1 Then SetLog("Possible Boost Times is lower than 0 and value is = " & $totalPossibleBoostTimes, $COLOR_ORANGE)
		Return True
	EndIf
	Return GetDifferenceOfBoostBarrackTimer()
EndFunc   ;==>IsFinishedBoostForThisCycle

Func IsFinishedBoostForThisCycleDARK()
	If $totalPossibleBoostTimesDARK <= 0 Then
		If $DebugBarrackBoost = 1 Then SetLog("Possible Boost Times is lower than 0 and value is = " & $totalPossibleBoostTimesDARK, $COLOR_ORANGE)
		Return True
	EndIf
	Return GetDifferenceOfBoostBarrackTimerDARK()
EndFunc   ;==>IsFinishedBoostForThisCycleDARK

Func GetDifferenceOfBoostBarrackTimer()
	Local $totalRecentlyBoosted = 0
	For $i = 0 To $numBarracks - 1
		$fDiff = TimerDiff($InitBoostTime[$i][1])
		If $DebugBarrackBoost = 1 Then SetLog("$InitBoostTime[" & $i & "][1] = " & $InitBoostTime[$i][1], $COLOR_ORANGE)
		$fDiff = Int($fDiff, 2)
		If $fDiff <= 300000 Then
			$totalRecentlyBoosted += 1
			If $DebugBarrackBoost = 1 Then SetLog("$totalRecentlyBoosted = " & $totalRecentlyBoosted, $COLOR_ORANGE)
		EndIf
	Next
	$iNumTotalBarracksToBoostInGUI = $icmbQuantBoostBarracks
	If $DebugBarrackBoost = 1 Then SetLog("$iNumTotalBarracksToBoostInGUI = " & $iNumTotalBarracksToBoostInGUI, $COLOR_ORANGE)
	If $totalRecentlyBoosted >= $iNumTotalBarracksToBoostInGUI Then
		If $DebugBarrackBoost = 1 Then SetLog("$totalRecentlyBoosted >= $iNumTotalBarracksToBoostInGUI = " & $totalRecentlyBoosted >= $iNumTotalBarracksToBoostInGUI, $COLOR_ORANGE)
		Return True
	EndIf
	Return False
EndFunc   ;==>GetDifferenceOfBoostBarrackTimer

Func GetDifferenceOfBoostBarrackTimerDARK()
	Local $totalRecentlyBoostedDARK = 0
	For $i = 0 To $numDarkBarracks - 1
		$fDiff = TimerDiff($InitBoostTimeDark[$i][1])
		If $DebugBarrackBoost = 1 Then SetLog("$InitBoostTimeDark[" & $i & "][1] = " & $InitBoostTimeDark[$i][1], $COLOR_ORANGE)
		$fDiff = Int($fDiff, 2)
		If $fDiff <= 300000 Then
			$totalRecentlyBoostedDARK += 1
			If $DebugBarrackBoost = 1 Then SetLog("$totalRecentlyBoostedDARK = " & $totalRecentlyBoostedDARK, $COLOR_ORANGE)
		EndIf
	Next
	$iNumTotalBarracksToBoostInGUIDARK = $icmbQuantBoostDarkBarracks
	If $DebugBarrackBoost = 1 Then SetLog("$iNumTotalBarracksToBoostInGUIDARK = " & $iNumTotalBarracksToBoostInGUIDARK, $COLOR_ORANGE)
	If $totalRecentlyBoostedDARK >= $iNumTotalBarracksToBoostInGUIDARK Then
		If $DebugBarrackBoost = 1 Then SetLog("$totalRecentlyBoostedDARK >= $iNumTotalBarracksToBoostInGUIDARK = " & $totalRecentlyBoostedDARK >= $iNumTotalBarracksToBoostInGUIDARK, $COLOR_ORANGE)
		Return True
	EndIf
	Return False
EndFunc   ;==>GetDifferenceOfBoostBarrackTimerDARK

Func IsBoostedSuccessfully($BRNum, $isDarkBarrack = False)
	If $DebugBarrackBoost = 1 Then SetLog("Func IsBoostedSuccessfully(" & $BRNum & ", " & $isDarkBarrack & ")", $COLOR_PURPLE)
	ClickP($aAway, 1, 0, "#0161")
	If _Sleep(250) Then Return
	$selectResult = -1
	Select
		Case $isDarkBarrack = False
			$selectResult = SelectBarrack($BRNum)
		Case Else
			$selectResult = SelectDarkBarrack($BRNum)
	EndSelect
	If $selectResult = True Then
		If _Sleep(1000) Then Return
		If IsBoosted() = True Then
			If $DebugBarrackBoost = 1 Then SetLog(IIf($isDarkBarrack = True, "Dark ", "") & "Barrack nº: " & $BRNum & " Boost Verified.", $COLOR_BLUE)
			If $DebugBarrackBoost = 1 Then SetLog("Func IsBoostedSuccessfully(" & $BRNum & ", " & $isDarkBarrack & ") = True", $COLOR_PURPLE)
			Return True
		Else
			If $DebugBarrackBoost = 1 Then SetLog(IIf($isDarkBarrack = True, "Dark ", "") & "Barrack nº: " & $BRNum & " Not Boosted, Failed To Verify.", $COLOR_BLUE)
			If $DebugBarrackBoost = 1 Then SetLog("Func IsBoostedSuccessfully(" & $BRNum & ", " & $isDarkBarrack & ") = False", $COLOR_PURPLE)
			Return False
		EndIf
		Return IsBoosted()
	Else
		If $DebugBarrackBoost = 1 Then SetLog("Failed To Select " & IIf($isDarkBarrack = True, "Dark ", "") & "Barrack nº: " & $BRNum & ", " & $isDarkBarrack & " To Verify Boost", $COLOR_BLUE)
		If $DebugBarrackBoost = 1 Then SetLog("Func IsBoostedSuccessfully(" & $BRNum & ", " & $isDarkBarrack & ") = False", $COLOR_PURPLE)
		Return False
	EndIf
	If $DebugBarrackBoost = 1 Then SetLog("END Func IsBoostedSuccessfully(" & $BRNum & ", " & $isDarkBarrack & ")", $COLOR_PURPLE)
EndFunc   ;==>IsBoostedSuccessfully

Func IsGemWindowOpen($varToChange1 = "", $varToChange2 = "", $AcceptGem = False, $NeedCapture = True)
	If $DebugBarrackBoost = 1 Then SetLog("Func IsGemWindowOpen(" & $AcceptGem & ", " & $NeedCapture & ")", $COLOR_PURPLE)
	_Sleep($iDelayisGemOpen1)
	If _ColorCheck(_GetPixelColor(314, 249 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) Then
		If _ColorCheck(_GetPixelColor(440, 424 + $midOffsetY, True), Hex(0x0d1903, 6), 20) Then
			If $debugSetlog = 1 Or $DebugBarrackBoost = 1 Then Setlog("DETECTED, GEM Window Is OPEN", $COLOR_PURPLE)
			If $AcceptGem = True Then
				Click(425, 425)
				_Sleep($iDelayBoostBarracks2)
				If _ColorCheck(_GetPixelColor(586, 267 + $midOffsetY, True), Hex(0xd80405, 6), 20) Then
					If $varToChange1 = "" = False Then Assign($varToChange1, 0, 4)
					SetLog("Not enough gems", $COLOR_RED)
					ClickP($aAway, 1, 0, "#0161")
				Else
					If $varToChange2 = "" = False Then Assign($varToChange2, Eval($varToChange2) - 1, 4)
					If $varToChange2 = "" = False Then SetLog('Boost completed. Remaining : ' & Eval($varToChange2), $COLOR_GREEN)
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
EndFunc   ;==>IsGemWindowOpen

Func CheckIfBoostButtonAvailable($BRNum, $BoostAllBtn = False, $ClickAlso = True)
	If $DebugBarrackBoost = 1 Then SetLog("Func CheckIfBoostButtonAvailable(" & $BRNum & ", " & $BoostAllBtn & ", " & $ClickAlso & ")", $COLOR_PURPLE)
	Local $ImagesToUse[2] ; Boost All
	$ImagesToUse[0] = @ScriptDir & "\images\Button\BoostAllBarracks.png"
	$ImagesToUse[1] = @ScriptDir & "\images\Button\BoostBarrack.png"
	;$ImagesToUse[2] = @ScriptDir & "\images\Button\BoostedBarrack.png"
	If FileExists($ImagesToUse[0]) And FileExists($ImagesToUse[1]) Then
		$ToleranceImgLoc = 0.92
		If SelectBarrack($BRNum) Or $BRNum = -1 Then
			If _Sleep(500) Then Return
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
			SetLog("Failed to Select Barrack #" & $BRNum & " to Boost", $COLOR_RED)
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
	If $BRNum = 0 Or $BRNum > 4 Then CheckForBarrackNoPos()
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