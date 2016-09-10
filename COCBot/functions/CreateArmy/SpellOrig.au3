; #FUNCTION# ====================================================================================================================
; Name ..........: BrewSpells
; Description ...: Create Normal Spells and Dark Spells
; Syntax ........: BrewSpells()
; Parameters ....:
; Return values .: None
; Author ........: ProMac ( 08-2015)
; Modified ......: Monkeyhunter (01/05-2016) , ProMac( 08-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func BrewSpells()

	; ATTENTION : This function only works if the ArmyOverView Windows is open
	Local $iLightningSpell, $iHealSpell, $iRageSpell, $iJumpSpell, $iFreezeSpell, $iCloneSpell, $iPoisonSpell, $iEarthSpell, $iHasteSpell, $iSkeletonSpell

	If $iTotalCountSpell = 0 Then Return

	If $numFactorySpellAvaiables = 1 And ($iLightningSpellComp > 0 Or $iRageSpellComp > 0 Or $iHealSpellComp > 0 Or $iJumpSpellComp > 0 Or $iFreezeSpellComp > 0 Or $iCloneSpellComp > 0) Then
		$iBarrHere = 0
		While Not (isSpellFactory())
			If Not (IsTrainPage()) Then Return
			_TrainMoveBtn(+1) ;click Next button
			$iBarrHere += 1
			If _Sleep($iDelayTrain3) Then ExitLoop
			If $iBarrHere = 8 Then ExitLoop
		WEnd
		If isSpellFactory() Then
			If $iLightningSpellComp > 0 Then ; Lightning Spells
				Local $iTempLightningSpell = Number(getBarracksTroopQuantity(175 + 107 * 0, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempLightningSpell = $iLightningSpellComp Then ; check if replacement spells trained,
						$iLightningSpell = 0
					Else
						$iLightningSpell = $iLightningSpellComp - $iTempLightningSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iLightningSpell = $iLightningSpellComp - ($CurLightningSpell + $iTempLightningSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Lightning Spell: " & $iLightningSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iLightningSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 0, 375 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 0
						setlog("Not enough Elixir to create Lightning Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iLightningSpellComp > $iTempLightningSpell Then
							GemClick(220 + 107 * 0, 354 + $midOffsetY, $iLightningSpellComp - $iTempLightningSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iLightningSpellComp - $iTempLightningSpell & " Lightning Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iLightningSpell > 0 Then
							GemClick(220 + 107 * 0, 354 + $midOffsetY, $iLightningSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iLightningSpell & " Lightning Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Lightning Spell(s)")
				EndIf
			EndIf
			If $iHealSpellComp > 0 Then ; Heal Spells
				Local $iTempHealSpell = Number(getBarracksTroopQuantity(175 + 107 * 1, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempHealSpell = $iHealSpellComp Then ; check if replacement spells trained,
						$iHealSpell = 0
					Else
						$iHealSpell = $iHealSpellComp - $iTempHealSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iHealSpell = $iHealSpellComp - ($CurHealSpell + $iTempHealSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Heal Spell: " & $iHealSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iHealSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 1, 375 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then
						setlog("Not enough Elixir to create Heal Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iHealSpellComp > $iTempHealSpell Then
							GemClick(220 + 107 * 1, 354 + $midOffsetY, $iHealSpellComp - $iTempHealSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iHealSpellComp - $iTempHealSpell & " Heal Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iHealSpell > 0 Then
							GemClick(220 + 107 * 1, 354 + $midOffsetY, $iHealSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iHealSpell & " Heal Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Heal Spell(s)")
				EndIf
			EndIf
			If $iRageSpellComp > 0 Then ; Rage Spells
				Local $iTempRageSpell = Number(getBarracksTroopQuantity(175 + 107 * 2, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempRageSpell = $iRageSpellComp Then ; check if replacement spells trained,
						$iRageSpell = 0
					Else
						$iRageSpell = $iRageSpellComp - $iTempRageSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iRageSpell = $iRageSpellComp - ($CurRageSpell + $iTempRageSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Rage Spell: " & $iRageSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iRageSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 2, 375 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then
						setlog("Not enough Elixir to create Rage Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iRageSpellComp > $iTempRageSpell Then
							GemClick(220 + 107 * 2, 354 + $midOffsetY, $iRageSpellComp - $iTempRageSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iRageSpellComp - $iTempRageSpell & " Rage Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iRageSpell > 0 Then
							GemClick(220 + 107 * 2, 354 + $midOffsetY, $iRageSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iRageSpell & " Rage Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Rage Spell(s)")
				EndIf
			EndIf
			If $iJumpSpellComp > 0 Then ; Jump Spells
				Local $iTempJumpSpell = Number(getBarracksTroopQuantity(175 + 107 * 3, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempJumpSpell = $iJumpSpellComp Then ; check if replacement spells trained,
						$iJumpSpell = 0
					Else
						$iJumpSpell = $iJumpSpellComp - $iTempJumpSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iJumpSpell = $iJumpSpellComp - ($CurJumpSpell + $iTempJumpSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Jump Spell: " & $iJumpSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iJumpSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 3, 375 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 0
						setlog("Not enough Elixir to create Jump Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iJumpSpell > $iTempJumpSpell Then
							GemClick(220 + 107 * 3, 354 + $midOffsetY, $iJumpSpell - $iTempJumpSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iJumpSpell - $iTempJumpSpell & " Jump Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iJumpSpell > 0 Then
							GemClick(220 + 107 * 3, 354 + $midOffsetY, $iJumpSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iJumpSpell & " Jump Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Jump Spell(s)")
				EndIf
			EndIf
			If $iFreezeSpellComp > 0 Then ; Freeze Spells
				Local $iTempFreezeSpell = Number(getBarracksTroopQuantity(175 + 107 * 4, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempFreezeSpell = $iFreezeSpellComp Then ; check if replacement spells trained,
						$iFreezeSpell = 0
					Else
						$iFreezeSpell = $iFreezeSpellComp - $iTempFreezeSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iFreezeSpell = $iFreezeSpellComp - ($CurFreezeSpell + $iTempFreezeSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Freeze Spell: " & $iFreezeSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iFreezeSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 4, 375 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 0
						setlog("Not enough Elixir to create Freeze Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iFreezeSpell > $iTempFreezeSpell Then
							GemClick(220 + 107 * 4, 354 + $midOffsetY, $iFreezeSpell - $iTempFreezeSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iFreezeSpell - $iTempFreezeSpell & " Freeze Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iFreezeSpell > 0 Then
							GemClick(220 + 107 * 4, 354 + $midOffsetY, $iFreezeSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iFreezeSpell & " Freeze Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Freeze Spell(s)")
				EndIf
			EndIf
			If $iCloneSpellComp > 0 Then ; Clone Spells
				Local $iTempCloneSpell = Number(getBarracksTroopQuantity(175 + 107 * 1, 401 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempCloneSpell = $iCloneSpellComp Then ; check if replacement spells trained,
						$iCloneSpell = 0
					Else
						$iCloneSpell = $iCloneSpellComp - $iTempCloneSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iCloneSpell = $iCloneSpellComp - ($CurCloneSpell + $iTempCloneSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Clone Spell: " & $iCloneSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iCloneSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _ColorCheck(_GetPixelColor(235 + 107 * 1, 480 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 0
						setlog("Not enough Elixir to create Clone Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iCloneSpell > $iTempCloneSpell Then
							GemClick(220 + 107 * 1, 450 + $midOffsetY, $iCloneSpell - $iTempCloneSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iCloneSpell - $iTempCloneSpell & " Clone Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iCloneSpell > 0 Then
							GemClick(220 + 107 * 1, 450 + $midOffsetY, $iCloneSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iCloneSpell & " Clone Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Clone Spell(s)")
				EndIf
			EndIf
		Else
			SetLog("Spell Factory not found...", $COLOR_BLUE)
		EndIf
	EndIf

	If $numFactoryDarkSpellAvaiables = 1 And ($iPoisonSpellComp > 0 Or $iEarthSpellComp > 0 Or $iHasteSpellComp > 0 Or $iSkeletonSpellComp > 0) Then
		$iBarrHere = 0
		While Not (isDarkSpellFactory())
			If Not (IsTrainPage()) Then Return
			_TrainMoveBtn(+1) ;click Next button
			$iBarrHere += 1
			If $iBarrHere = 8 Then ExitLoop
			If _Sleep($iDelayTrain3) Then Return
		WEnd
		If isDarkSpellFactory() Then
			If $iPoisonSpellComp > 0 Then ; Poison Spells
				Local $iTempPoisonSpell = Number(getBarracksTroopQuantity(175 + 107 * 0, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempPoisonSpell = $iPoisonSpellComp Then ; check if replacement spells trained,
						$iPoisonSpell = 0
					Else
						$iPoisonSpell = $iPoisonSpellComp - $iTempPoisonSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iPoisonSpell = $iPoisonSpellComp - ($CurPoisonSpell + $iTempPoisonSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Poison Spell: " & $iPoisonSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iPoisonSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _sleep($iDelayTrain2) Then Return
						If _ColorCheck(_GetPixelColor(231 + 107 * 0, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False And _ ; White into number 0
							_ColorCheck(_GetPixelColor(234 + 107 * 0, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 5
						setlog("Not enough Elixir to create Poison Spell", $COLOR_RED)
						If $debugsetlogTrain = 1 Then setlog("colorceck: " & 233 + 107 * 0 & "," & 375 + $midOffsetY, $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iPoisonSpell > $iTempPoisonSpell Then
							GemClick(222, 354 + $midOffsetY, $iPoisonSpell - $iTempPoisonSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iPoisonSpell - $iTempPoisonSpell & " Poison Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iPoisonSpell > 0 Then
							GemClick(222, 354 + $midOffsetY, $iPoisonSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iPoisonSpell & " Poison Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Poison Spell(s)")
				EndIf
			EndIf

			If $iEarthSpellComp > 0 Then ; EarthQuake Spells
				Local $iTempEarthSpell = Number(getBarracksTroopQuantity(175 + 107 * 1, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempEarthSpell = $iEarthSpellComp Then ; check if replacement spells trained,
						$iEarthSpell = 0
					Else
						$iEarthSpell = $iEarthSpellComp - $iTempEarthSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iEarthSpell = $iEarthSpellComp - ($CurEarthSpell + $iTempEarthSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Earthquake Spell: " & $iEarthSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iEarthSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _sleep($iDelayTrain2) Then Return
						If _ColorCheck(_GetPixelColor(231 + 107 * 1, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False And _ ; White into number 0
							_ColorCheck(_GetPixelColor(234 + 107 * 1, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 5
						setlog("Not enough Elixir to create Earthquake Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iEarthSpell > $iTempEarthSpell Then
							GemClick(329, 354 + $midOffsetY, $iEarthSpell - $iTempEarthSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iEarthSpell - $iTempEarthSpell & " EarthQuake Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iEarthSpell > 0 Then
							GemClick(329, 354 + $midOffsetY, $iEarthSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iEarthSpell & " EarthQuake Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done EarthQuake Spell(s)")
				EndIf
			EndIf

			If $iHasteSpellComp > 0 Then ; Haste Spells
				Local $iTempHasteSpell = Number(getBarracksTroopQuantity(175 + 107 * 2, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempHasteSpell = $iHasteSpellComp Then ; check if replacement spells trained,
						$iHasteSpell = 0
					Else
						$iHasteSpell = $iHasteSpellComp - $iTempHasteSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iHasteSpell = $iHasteSpellComp - ($CurHasteSpell + $iTempHasteSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Haste Spell: " & $iHasteSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iHasteSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _sleep($iDelayTrain2) Then Return
						If _ColorCheck(_GetPixelColor(231 + 107 * 2, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False And _ ; White into number 0
							_ColorCheck(_GetPixelColor(234 + 107 * 2, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 5
						setlog("Not enough Elixir to create Haste Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iHasteSpell > $iTempHasteSpell Then
							GemClick(430, 354 + $midOffsetY, $iHasteSpell - $iTempHasteSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iHasteSpell - $iTempHasteSpell & " Haste Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iHasteSpell > 0 Then
							GemClick(430, 354 + $midOffsetY, $iHasteSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iHasteSpell & " Haste Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Haste Spell(s)")
				EndIf
			EndIf
			If $iSkeletonSpellComp > 0 Then ; Skeleton Spells
				Local $iTempSkeletonSpell = Number(getBarracksTroopQuantity(175 + 107 * 3, 295 + $midOffsetY))
				If $bFullSpell = True And $fullArmy = True Then ;if spell factory full
					If $iTempSkeletonSpell = $iSkeletonSpellComp Then ; check if replacement spells trained,
						$iSkeletonSpell = 0
					Else
						$iSkeletonSpell = $iSkeletonSpellComp - $iTempSkeletonSpell ; add spells to queue to match GUI
					EndIf
				Else
					$iSkeletonSpell = $iSkeletonSpellComp - ($CurSkeletonSpell + $iTempSkeletonSpell) ; not full, add more spell if needed
				EndIf
				If $debugsetlogTrain = 1 Then SetLog("Making Skeleton Spell: " & $iSkeletonSpell)
				If _sleep($iDelayTrain2) Then Return
				If $iSkeletonSpell > 0 Or $iChkBarrackSpell = 1 Then
					If _sleep($iDelayTrain2) Then Return
					If _ColorCheck(_GetPixelColor(231 + 107 * 3, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False And _ ; White into number 0
						_ColorCheck(_GetPixelColor(234 + 107 * 3, 370 + $midOffsetY, True), Hex(0xFFFFFF, 6), 20) = False Then ; White into number 5
						setlog("Not enough Elixir to create Skeleton Spell", $COLOR_RED)
						Return
					ElseIf _ColorCheck(_GetPixelColor(200, 346 + $midOffsetY, True), Hex(0x414141, 6), 20) Then
						setlog("Spell Factory Full", $COLOR_RED)
						Return
					Else
						If $iChkBarrackSpell = 1 And $iSkeletonSpell > $iTempSkeletonSpell Then
							GemClick(540, 354 + $midOffsetY, $iSkeletonSpell - $iTempSkeletonSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iSkeletonSpell - $iTempSkeletonSpell & " Skeleton Spell(s) (Barrack Mode)", $COLOR_BLUE)
						ElseIf $iSkeletonSpell > 0 Then
							GemClick(540, 354 + $midOffsetY, $iSkeletonSpell, $iDelayTrain7, "#0290")
							SetLog("Created " & $iSkeletonSpell & " Skeleton Spell(s)", $COLOR_BLUE)
						EndIf
					EndIf
				Else
					Setlog("Already done Skeleton Spell(s)")
				EndIf
			EndIf
		Else
			SetLog("Dark Spell Factory not found...", $COLOR_BLUE)
		EndIf
	EndIf

EndFunc   ;==>BrewSpells
