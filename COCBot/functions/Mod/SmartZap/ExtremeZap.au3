; #FUNCTION# ====================================================================================================================
; Name ..........: ExtremeZap
; Description ...: This file Includes all functions to current GUI
; Syntax ........: ExtremeZap()
; Parameters ....: None
; Return values .: None
; Author ........: TheRevenor(July, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func ExtremeZap()
	;Local $oldSearchDark = 0, $skippedZap = True, $performedZap = False
	Local $searchDark, $oldSearchDark = 0, $numSpells, $skippedZap = True, $performedZap = False, $dropPoint

	; If ExtremeZap is not checked, exit.
	If $ichkExtLightSpell <> 1 Then Return $performedZap
		SetLog("====== Your Activate ExtremeZap Mode ======", $COLOR_RED)

	; Check match mode
	If $ichkSmartZapDB = 1 And $iMatchMode <> $DB Then
		SetLog("Not a dead base so lets just go home!", $COLOR_ORANGE)
		Return $performedZap
	EndIf
	
	If getDarkElixirStorageFull() Then
		SetLog("Your Dark Elixir Storage is full, no need to zap!", $COLOR_FUCHSIA)
		Return $performedZap
	EndIf

	Local $aDrills
	
	; Get Drill locations and info
	Local $listPixelByLevel = getDrillArray()
	Local $aDarkDrills = drillSearch($listPixelByLevel)

	Local $strikeOffsets = [7, 10]
	Local $drillLvlOffset, $spellAdjust, $searchDark, $numDrills, $numSpells, $testX, $testY, $tempTestX, $tempTestY, $strikeGain, $expectedDE, $bDrillFound
	Local $error = 5 ; 5 pixel error margin for DE drill search

	; Get the number of drills
	$numDrills = getNumberOfDrills($listPixelByLevel)
	If $numDrills = 0 Then
		SetLog("No Drills Found, Time To Go Home!", $COLOR_ORANGE)
		Return $performedZap
	Else
		SetLog("Number of Dark Elixir Drills: " & $numDrills, $COLOR_FUCHSIA)
	EndIf
	
	; Get the number of lightning spells
	$numSpells = $CurLightningSpell
	If $numSpells = 0 Then
		SetLog("No lightning spells trained, time to go home!", $COLOR_FUCHSIA)
		Return $performedZap
	Else
		SetLog("Number of Lightning Spells: " & $numSpells, $COLOR_FUCHSIA)
	EndIf

	; Get Dark Elixir value, if no DE value exists, exit.
	$searchDark = getDarkElixir()
	If Not $searchDark Or $searchDark = 0 Then
		SetLog("No Dark Elixir so lets just exit!", $COLOR_FUCHSIA)
		Return $performedZap
	EndIf

	; Create the log entry string for amount stealable
	_ArraySort($aDarkDrills, 1, 0, 0, 3)

	; Offset the number of spells based on town hall level
	$spellAdjust = getSpellOffset()
	If $debugSetLog = 1 Then SetLog("Spell Adjust is: " & $spellAdjust, $COLOR_PURPLE)

	; Loop while you still have spells and the first drill in the array has Dark Elixir, if you are town hall 7 or higher
	While $numSpells > 0 And $aDarkDrills[0][3] <> -1 And $spellAdjust <> -1
		; Store the DE value before any Zaps are done.
		$oldSearchDark = $searchDark

		If ($searchDark < Number($itxtMinDE)) Then
			SetLog("Dark Elixir is below minimum value " & $itxtMinDE & ", Exiting Now!", $COLOR_RED)
			Return $performedZap
		EndIf
		CheckHeroesHealth()
		
		; Store the DE value before any Zaps are done.
		$oldSearchDark = $searchDark
		
		; If you have max lightning spells, drop lightning on any level DE drill
		If $numDrills >= 1 Then
			SetLog("ExtremeZap Drop L.Spell For All Dark Elixir Drill.", $COLOR_FUCHSIA)
			zapDrill($eLSpell, $aDarkDrills[0][0] + $strikeOffsets[0], $aDarkDrills[0][1] + $strikeOffsets[1])

			$numSpells -= 1
			$performedZap = True
			$skippedZap = False

			If _Sleep(3500) Then Return
		Else
			$skippedZap = True
			SetLog("No Dark Elixir Gained Or Dark Drill Already Destroyed.", $COLOR_ORANGE)
		EndIf

		; Get the DE Value after ExtremeZap has performed its actions.
		$searchDark = getDarkElixir()
		
		; No Dark Elixir Left
		If Not $searchDark Or $searchDark = 0 Then
			SetLog("No Dark Elixir so lets just exit!", $COLOR_FUCHSIA)
			Return $performedZap
		EndIf

		; Check to make sure we actually zapped
		If $skippedZap = False Then
			$strikeGain = $oldSearchDark - $searchDark
			$numLSpellsUsed += 1

			; Get the DE Value after ExtremeZap has performed its actions.
			$searchDark = getDarkElixir()
			
			; Check to make sure we actually zapped
			If $aDarkDrills[0][1] <> -1 Then
				$expectedDE = 81
			Else
				$expectedDE = -1
			EndIf

			; If change in DE is less than expected, remove the Drill from list. else, subtract change from assumed total
			If $strikeGain < $expectedDE And $expectedDE <> -1 Then
				For $i = 0 To UBound($aDarkDrills, 1) - 1
					$aDarkDrills[0][$i] = -1
				Next
			Else
				$aDarkDrills[0][3] -= $strikeGain
				SetLog("ExtremeZap: " & $strikeGain & ". Adjusting amount left in this drill.", $COLOR_PURPLE)
			EndIf

			$SmartZapGain += $strikeGain
			SetLog("DE from last zap: " & $strikeGain & ", Total DE from ExtremeZap: " & $SmartZapGain, $COLOR_FUCHSIA)
		EndIf
		
		; Resort the array
		_ArraySort($aDarkDrills, 1, 0, 0, 3)

		; Test current drill locations to check if it still exists (within error)
		; AND get total theoretical amount in drills to compare against available amount
		$aDrills = drillSearch()

		If $aDarkDrills[0][0] <> -1 Then
			;Initialize tests.
			;$testX = -1
			;$testY = -1
			$bDrillFound = False

			For $i = 0 To Ubound($aDrills) - 1
				If $aDrills[$i][0] <> -1 Then
					$tempTestX = Abs($aDrills[$i][0] - $aDarkDrills[0][0])
					$tempTestY = Abs($aDrills[$i][1] - $aDarkDrills[0][1])

					If $debugSetLog = 1 Then SetLog("tempX: " & $tempTestX & " tempY: " & $tempTestY, $COLOR_PURPLE)

					; If the tests are less than error, give pass onto test phase
					If $tempTestX < $error And $tempTestY < $error Then
						;$testX = $tempTestX
						;$testY = $tempTestY
						$bDrillFound = True
						ExitLoop
					EndIf
				EndIf
			Next
			;If $debugSetLog = 1 Then SetLog("testX: " & $testX & " testY: " & $testY, $COLOR_PURPLE)

			; Test Phase, if test error is greater than expected, or test error is default value.
			;If ($testX > $error Or $testY > $error) And ($testX <> -1 Or $testY <> -1) Then
			If Not $bDrillFound Then
				For $i = 0 To UBound($aDarkDrills, 2) - 1
					$aDarkDrills[0][$i] = -1
				Next
				SetLog("Removing drill since it wasn't found, so it was probably destroyed.", $COLOR_FUCHSIA)
				; Resort the array
				_ArraySort($aDarkDrills, 1, 0, 0, 3)
			EndIf
		EndIf
	WEnd

	Return $performedZap
EndFunc   ;==>ExtremeZap
