
; #FUNCTION# ====================================================================================================================
; Name ..........: getArmyHeroTime
; Description ...: Obtains time reamining for Heros Training - Army Overview window
; Syntax ........: getArmyHeroTime($iHeroEnum = $eKing, $bReturnTimeArray = False, $bOpenArmyWindow = False, $bCloseArmyWindow = False)
; Parameters ....: $iHeroEnum = enum value for hero to check, or text "all" to check all heroes
;					  : $bOpenArmyWindow  = Bool value true if train overview window needs to be opened
;					  : $bCloseArmyWindow = Bool value, true if train overview window needs to be closed
; Return values .: MonkeyHunter (05/06-2016)
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;
Func getArmyHeroTime($HeroType, $bOpenArmyWindow = False, $bCloseArmyWindow = False)

	If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then Setlog("Begin getArmyHeroTime:", $COLOR_PURPLE)

	; validate hero troop type input, must be hero enum value or "all"
	If $HeroType <> $eKing And $HeroType <> $eQueen And $HeroType <> $eWarden And StringInStr($HeroType, "all", $STR_NOCASESENSEBASIC) = 0 Then
		Setlog("getHeroTime slipped on banana, get doctor, tell him: " & $HeroType, $COLOR_RED)
		SetError(1)
		Return
	EndIf

	If $bOpenArmyWindow = False And IsTrainPage() = False Then ; check for train page and open window if needed
		SetError(2)
		Return ; not open, not requested to be open - error.
	ElseIf $bOpenArmyWindow = True Then
		If openArmyOverview() = False Then
			SetError(3)
			Return ; not open, requested to be open - error.
		EndIf
		If _Sleep($iDelaycheckArmyCamp5) Then Return
	EndIf

	Local $iRemainTrainHeroTimer = 0
	Local $sResult
	Local $iResultHeroes[3] = ["", "", ""] ; array to hold all remaining regen time read via OCR
	Local Const $HeroSlots[3][2] = [[464, 446], [526, 446], [588, 446]] ; Location of hero status check tile

	; Constant Array with OCR find location: [X pos, Y Pos, Text Name, Global enum value]
	Local Const $aHeroRemainData[3][4] = [[442, 504, "King", $eKing], [504, 504, "Queen", $eQueen], [565, 504, "Warden", $eWarden]]

	For $index = 0 To UBound($aHeroRemainData) - 1 ;cycle through all 3 slots and hero types

		; check if OCR required
		If StringInStr($HeroType, "all", $STR_NOCASESENSEBASIC) = 0 And $HeroType <> $aHeroRemainData[$index][3] Then ContinueLoop

		; Check if slot has healing hero
		$sResult = getHeroStatus($HeroSlots[$index][0], $HeroSlots[$index][1]) ; OCR slot for status information
		If $sResult <> "" Then ; we found something
			If StringInStr($sResult, "heal", $STR_NOCASESENSEBASIC) = 0 Then
				If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then
					SetLog("Hero slot#" & $index + 1 & " status: " & $sResult & " :skip time read", $COLOR_PURPLE)
				EndIf
				ContinueLoop ; if do not find hero healing, then do not read time
			Else
				If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then SetLog("Hero slot#" & $index + 1 & " status: " & $sResult, $COLOR_PURPLE)
			EndIf
		Else
			SetLog("Hero slot#" & $index + 1 & " Status read problem!", $COLOR_RED)
		EndIf

		$sResult = getRemainTHero($aHeroRemainData[$index][0], $aHeroRemainData[$index][1]) ;Get Hero training time via OCR.

		If $sResult <> "" Then
			Select
				Case StringInStr($sResult, "m", $STR_NOCASESENSEBASIC) ; find minutes?
					$sResultHeroTime = StringTrimRight($sResult, 1) ; removing the "m"
					$iResultHeroes[$index] = Number($sResultHeroTime)
				Case StringInStr($sResult, "s", $STR_NOCASESENSEBASIC) ; find seconds?
					$sResultHeroTime = StringTrimRight($sResult, 1) ; removing the "s"
					$iResultHeroes[$index] = Number($sResultHeroTime) / 60 ; convert to minute
				Case Else
					SetLog("Bad read of remaining " & $aHeroRemainData[$index][2] & " train time: " & $sResult, $COLOR_RED)
			EndSelect
			If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then SetLog("Remaining " & $aHeroRemainData[$index][2] & " train time: " & StringFormat("%.2f", $iResultHeroes[$index]), $COLOR_PURPLE)

			If $HeroType = $aHeroRemainData[$index][3] Then ; if only one hero requested, then set return value and exit loop
				$iRemainTrainHeroTimer = Number($sResultHeroTime)
				ExitLoop
			EndIf
		Else ; empty OCR value
			If $HeroType = $aHeroRemainData[$index][3] Then ; only one hero value?
				SetLog("Can not read remaining " & $aHeroRemainData[$index][2] & " train time", $COLOR_RED)
			Else
				; reading all heros, need to find if hero is active/wait to determine how to log message?
				For $pMatchMode = $DB To $iMatchMode - 1 ; check all attack modes
					If IsSpecialTroopToBeUsed($pMatchMode, $aHeroRemainData[$index][3]) And _
							BitAND($iHeroAttack[$pMatchMode], $iHeroWait[$pMatchMode]) = $iHeroWait[$pMatchMode] Then ; check if Hero enabled to wait
						SetLog("Can not read remaining " & $aHeroRemainData[$index][2] & " train time", $COLOR_RED)
						ExitLoop
					Else
						If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then SetLog("Bad read remain " & $aHeroRemainData[$index][2] & " train time, but not enabled", $COLOR_PURPLE)
					EndIf
				Next
			EndIf
		EndIf
	Next

	If $bCloseArmyWindow = True Then
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		If _Sleep($iDelaycheckArmyCamp4) Then Return
	EndIf

	; Determine proper return value
	If $HeroType = $eKing Or $HeroType = $eQueen Or $HeroType = $eWarden Then
		Return $iRemainTrainHeroTimer ; return one requested hero value
	ElseIf StringInStr($HeroType, "all", $STR_NOCASESENSEBASIC) > 0 Then
		; calling function needs to check if heroattack enabled & herowait enabled for attack mode used!
		Return $iResultHeroes ; return array of with each hero regen time value
	EndIf

EndFunc   ;==>getArmyHeroTime

Func CheckWaitHero()	; get hero regen time remaining if enabled
    Local $aResult, $iActiveHero
	Local $aHeroResult[3]
	$aTimeTrain[2] = 0

	If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then Setlog("CheckWaitHero", $COLOR_PURPLE)
	  For $j = 0 To UBound($aResult) - 1
		$aHeroResult[$j] = 0 ; reset old values
	  Next
	  If _Sleep($iDelayRespond) Then Return
	  $aHeroResult = getArmyHeroTime("all")
	  ;Setlog("Getting Hero's recover time, King: " & $aHeroResult[0] & " m, Queen: " & $aHeroResult[1] & " m, GW: " & $aHeroResult[2] & " m.")
	  Setlog("Getting Hero's recover time: ", $COLOR_BLUE)
	  If $aHeroResult[0] > 0 Then
	  SetLog("King: " & $aHeroResult[0] & " minute(s)", $COLOR_BLUE)
	  EndIf
	  If $aHeroResult[1] > 0 Then
	  SetLog("Queen: " & $aHeroResult[1] & " minute(s)", $COLOR_BLUE)
	  EndIf
	  If $aHeroResult[2] > 0 Then
	  SetLog("Warden: " & $aHeroResult[2] & " minute(s)", $COLOR_BLUE)
	  EndIf
	  If @error Then
		Setlog("getArmyHeroTime return error, exit Check Hero's wait time!", $COLOR_RED)
		Return ; if error, then quit smartwait
	  EndIf
	  If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then SetLog("getArmyHeroTime returned: " & $aHeroResult[0] & ":" & $aHeroResult[1] & ":" & $aHeroResult[2], $COLOR_PURPLE)
	  If _Sleep($iDelayRespond) Then Return
	  If $aHeroResult[0] > 0 Or $aHeroResult[1] > 0 Or $aHeroResult[2] > 0 Then ; check if hero is enabled to use/wait and set wait time
		 For $pTroopType = $eKing To $eWarden ; check all 3 hero
			 For $pMatchMode = $DB To $iModeCount - 1 ; check all attack modes
				 If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then
					 SetLog("$pTroopType: " & NameOfTroop($pTroopType) & ", $pMatchMode: " & $sModeText[$pMatchMode], $COLOR_PURPLE)
					 Setlog("TroopToBeUsed: " & IsSpecialTroopToBeUsed($pMatchMode, $pTroopType) & ", Hero Wait Status: " & (BitOr($iHeroAttack[$pMatchMode], $iHeroWait[$pMatchMode]) = $iHeroAttack[$pMatchMode]), $COLOR_PURPLE)
				 EndIf
				 $iActiveHero = -1
				 If IsSpecialTroopToBeUsed($pMatchMode, $pTroopType) And _
						 BitOr($iHeroAttack[$pMatchMode], $iHeroWait[$pMatchMode]) = $iHeroAttack[$pMatchMode] Then ; check if Hero enabled to wait
					 $iActiveHero = $pTroopType - $eKing ; compute array offset to active hero
				 EndIf
				 If $iActiveHero <> -1 And $aHeroResult[$iActiveHero] > 0 Then ; valid time?
					 ; check exact time & existing time is less than new time
					 If $aTimeTrain[2] < $aHeroResult[$iActiveHero] Then
						$aTimeTrain[2] = $aHeroResult[$iActiveHero] ; use exact time
					 EndIf
					 If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then
						 SetLog("Wait enabled: " & NameOfTroop($pTroopType) & ", Attack Mode:" & $sModeText[$pMatchMode] & ", Hero Time:" & $aHeroResult[$iActiveHero] & ", Wait Time: " & StringFormat("%.2f", $aTimeTrain[2]), $COLOR_PURPLE)
					 EndIf
				 EndIf
			 Next
			 If _Sleep($iDelayRespond) Then Return
		 Next
	  Else
		 If $debugsetlogTrain = 1 Or $debugSetlog = 1 Then Setlog("getArmyHeroTime return all zero hero wait times", $COLOR_PURPLE)
	  EndIf

	Setlog("Hero recover wait time: " & $aTimeTrain[2] & " minute(s)", $COLOR_BLUE)

 EndFunc ; CheckWaitHero
 
 Func ChkRemainHeroandSpell()

   getArmyTroopTime(True, False)
   
   If IsWaitforSpellsActive() Then
	  getArmySpellTime()
   Else
	  $aTimeTrain[1] = 0
   EndIf

   If IsWaitforHeroesActive() Then
	  CheckWaitHero()
   Else
	  $aTimeTrain[2] = 0
   EndIf

   ClickP($aAway, 1, 0, "#0000") ;Click Away
 EndFunc ; ChkRemainHeroandSpell
