; #FUNCTION# ====================================================================================================================
; Name ..........: DeleteTroopsInArmyOverview
; Description ...: Opens and waits for Army Overiew window and Delete Wrong Troops
; Syntax ........: DeleteTroopsInArmyOverview()
; Parameters ....:
; Return values .: None
; Author ........: TheRevenor (09-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func DeleteTroopsInArmyOverview()
	SetLog(" »» Checking Wrong Troops In ArmyOverview !!", $COLOR_ORANGE)

	If _Sleep($iDelayTrain3) Then Return
	;OPEN ARMY OVERVIEW WITH NEW BUTTON
	openArmyOverview()
	If _Sleep($iDelayTrain3) Then Return

	If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
		If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
		If IsTrainPage() Then 
			GetArmyCapacity()
			If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
			getArmyTroopCount()
			If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
			getArmyHeroCount()
			If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
			getArmySpellCapacity()
			If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
			getArmySpellCount()
			If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
		EndIf
	EndIf
	If _Sleep($iDelayTrain3) Then Return

	Click(640, 500, 1, 0, "Click Edit Troops")
	If _Sleep($iDelayTrain3) Then Return

	DeletedTroops()

	If _ColorCheck(_GetPixelColor(710, 432 + $midOffsetY, True), Hex(0x70BC20, 6), 20) Then ; Click Okay
		Click(710, 462, 1, 0, "Click Okay") 
		If _Sleep($iDelayTrain3) Then Return
	EndIf

	If _ColorCheck(_GetPixelColor(550, 406 + $midOffsetY, True), Hex(0x66B40F, 6), 20) Then ; Click Confirm Deletion
		Click(550, 436, 1, 0, "Click Confirm")
		If _Sleep($iDelayTrain3) Then Return
		$fullArmy = False
		SetLog(" »» Deleting Troops In ArmyOverview Finish..", $COLOR_GREEN)
	Else
		SetLog(" »» Not Found Wrong Troops, Checking Finish..", $COLOR_GREEN)
	EndIf

	ClickP($aAway, 1, 0, "#0000") ;Click Away
	If _Sleep(4000) Then Return

EndFunc   ;==>DeleteTroopsInArmyOverview

Func DeletedTroops()

	If $debugSetlog = 1 Then SetLog("Troops in excess!...", $COLOR_PURPLE)
	If $debugsetlogTrain = 1 Then SetLog("Start-Loop Regular Troops Only To Donate ")
	For $i = 0 To UBound($TroopName) - 1
		If $debugsetlogTrain = 1 Then SetLog("Troop :" & NameOfTroop(Eval("e" & $TroopName[$i])))
		If (Eval("Cur" & $TroopName[$i]) * -1) > Eval($TroopName[$i] & "Comp") Then ; verify if the exist excess of troops

			$Delete = (Eval("Cur" & $TroopName[$i]) * -1) - Eval($TroopName[$i] & "Comp") ; existent troops - troops selected in GUI
			If $debugsetlogTrain = 1 Then SetLog("$Delete :" & $Delete)
			$SlotTemp = Eval("SlotInArmy" & $TroopName[$i])
			If $debugsetlogTrain = 1 Then SetLog("$SlotTemp :" & $SlotTemp)

			If _Sleep(250) Then Return
			If _ColorCheck(_GetPixelColor(170 + (62 * $SlotTemp), 235 + $midOffsetY, True), Hex(0xD40003, 6), 10) Then ; Verify if existe the RED [-] button
				Click(170 + (62 * $SlotTemp), 235 + $midOffsetY, $Delete, 300)
				SetLog(" » Deleted " & $Delete & " " & NameOfTroop(Eval("e" & $TroopName[$i])), $COLOR_RED)
				Assign("Cur" & $TroopName[$i], Eval("Cur" & $TroopName[$i]) + $Delete) ; Remove From $CurTroop the deleted Troop quantity
			EndIf
		EndIf
	Next

	If $debugsetlogTrain = 1 Then SetLog("Start-Loop Dark Troops Only To Donate ")
	For $i = 0 To UBound($TroopDarkName) - 1
		If $debugsetlogTrain = 1 Then SetLog("Troop :" & NameOfTroop(Eval("e" & $TroopDarkName[$i])))
		If (Eval("Cur" & $TroopDarkName[$i]) * -1) > Eval($TroopDarkName[$i] & "Comp") Then ; verify if the exist excess of troops

			$Delete = (Eval("Cur" & $TroopDarkName[$i]) * -1) - Eval($TroopDarkName[$i] & "Comp") ; existent troops - troops selected in GUI
			If $debugsetlogTrain = 1 Then SetLog("$Delete :" & $Delete)
			$SlotTemp = Eval("SlotInArmy" & $TroopDarkName[$i])
			If $debugsetlogTrain = 1 Then SetLog("$SlotTemp :" & $SlotTemp)

			If _Sleep(250) Then Return
			If _ColorCheck(_GetPixelColor(170 + (62 * $SlotTemp), 235 + $midOffsetY, True), Hex(0xD40003, 6), 10) Then ; Verify if existe the RED [-] button
				Click(170 + (62 * $SlotTemp), 235 + $midOffsetY, $Delete, 300)
				SetLog(" » Deleted " & $Delete & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i])), $COLOR_RED)
				Assign("Cur" & $TroopDarkName[$i], Eval("Cur" & $TroopDarkName[$i]) + $Delete) ; Remove From $CurTroop the deleted Troop quantity
			EndIf
		EndIf
	Next

EndFunc    ;==>DeletedTroops
