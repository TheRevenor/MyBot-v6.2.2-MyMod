; #FUNCTION# ====================================================================================================================
; Name ..........: Donate Stats
; Description ...: This file include functions Related to Donate Stats
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MR.ViPER (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

CreateDonatedVars()

Func CreateDonatedVars($ForcedVal = 0, $showLog = 0)
	For $i = 0 To UBound($TroopName) - 1
		Assign("Donated" & Eval("e" & $TroopName[$i]) & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
		If $showLog = 1 Then SetLog("Donated" & Eval("e" & $TroopName[$i]) & "ViPER" & ", Troop Name: " & NameOfTroop(Eval("e" & $TroopName[$i])), $COLOR_BLUE)
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		Assign("Donated" & Eval("e" & $TroopDarkName[$i]) & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
		If $showLog = 1 Then SetLog("Donated" & Eval("e" & $TroopDarkName[$i]) & "ViPER" & ", DARK Troop Name: " & NameOfTroop(Eval("e" & $TroopDarkName[$i])), $COLOR_GREEN)
	Next

	Assign("Donated" & $ePSpell & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
	Assign("Donated" & $eESpell & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
	Assign("Donated" & $eHaSpell & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
	Assign("Donated" & $eSkSpell & "ViPER", $ForcedVal, $ASSIGN_FORCEGLOBAL)
EndFunc

Func DonatedTroop($type, $showLog = 0)
	$newVal = Number(Eval("Donated" & $type & "ViPER")) + 1
	Assign("Donated" & $type & "ViPER", $newVal, 4)
	;UpdateDonateStatsGUI($type, $newVal)
	If $showLog = 1 Then SetLog("Donated" & $type & "ViPER = " & Eval("Donated" & $type & "ViPER"), $COLOR_BLUE)
	If $showLog = 0 Then SetLog(" » Donated " & NameOfTroop($type) & " " & Eval("Donated" & $type & "ViPER"), $COLOR_BLUE)
EndFunc

Func DonatedSpell($type, $showLog = 0)
	$newVal = Number(Eval("Donated" & $type & "ViPER")) + 1
	Assign("Donated" & $type & "ViPER", $newVal, 4)
	;UpdateDonateStatsGUI($type, $newVal)
	If $showLog = 1 Then SetLog("Donated" & $type & "ViPER = " & Eval("Donated" & $type & "ViPER"), $COLOR_BLUE)
	If $showLog = 0 Then SetLog(" » Donated " & NameOfTroop($type) & " " & Eval("Donated" & $type & "ViPER"), $COLOR_BLUE)
EndFunc

Func ResetDonateStats()
	For $i = 0 To UBound($TroopName) - 1
		$type = Eval("e" & $TroopName[$i])
		Assign("Donated" & $type & "ViPER", 0, 4)
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		$type = Eval("e" & $TroopDarkName[$i])
		Assign("Donated" & $type & "ViPER", 0, 4)
	Next
	Assign("Donated" & $ePSpell & "ViPER", 0, 4)
	Assign("Donated" & $eESpell & "ViPER", 0, 4)
	Assign("Donated" & $eHaSpell & "ViPER", 0, 4)
	Assign("Donated" & $eSkSpell & "ViPER", 0, 4)
EndFunc 

#cs
Func UpdateDonateStatsGUI($type, $value)
	GUICtrlSetData(Eval("lblDonated" & $type), $value)
	$totalETroops = 0
	$totalDTroops = 0
	$totalSpells = 0
	For $i = 0 To UBound($TroopName) - 1
		$totalETroops += Eval("Donated" & Eval("e" & $TroopName[$i]) & "ViPER")
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		$totalDTroops += Eval("Donated" & Eval("e" & $TroopDarkName[$i]) & "ViPER")
	Next
	$totalSpells = Number(Eval("Donated" & $ePSpell & "ViPER")) + Number(Eval("Donated" & $eESpell & "ViPER")) + Number(Eval("Donated" & $eHaSpell & "ViPER")) + Number(Eval("Donated" & $eSkSpell & "ViPER"))
	GUICtrlSetData($lblTotalDonated,"Total Donated: " & $totalETroops)
	GUICtrlSetData($lblTotalDonatedDark,"Total Donated: " & $totalDTroops)
	GUICtrlSetData($lblTotalDonatedSpell,"Total Donated: " & $totalSpells)
EndFunc
#ce