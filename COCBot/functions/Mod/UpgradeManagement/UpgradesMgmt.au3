#cs FUNCTION ====================================================================================================================
; Name ..........: MoveUpgrades
; Description ...: Move upgrade-box-checked buildings down or up one row OR to the bottom or top of the list
; Syntax ........: None
; Parameters ....: $bDirUp				boolean, up=True, down=False
;				   $bTillEnd			boolean, till end of the list, default False
; Return values .: Success:				None
;				   Failure:				None
;				   @error:				None
; Author ........: MMHK (July-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
#ce ===============================================================================================================================

Func MoveUpgrades($bDirUp, $bTillEnd = False)
	; save all GUI check box stats to the array variables
	btnchkbxUpgrade()
	btnchkbxRepeat()

	Local $iStart, $iStop, $iStep, $bSwap
	If $bDirUp Then
		$iStart = 0
		$iStop = $iUpgradeSlots - 1
		$iStep = 1
	Else
		$iStart = $iUpgradeSlots - 1
		$iStop = 0
		$iStep = -1
	EndIf
	Do
		$bSwap = False
		For $i = $iStart To $iStop Step $iStep
			If $ichkbxUpgrade[$i] <> 1 Or $i = $iStart Then ContinueLoop
			If $ichkbxUpgrade[$i-$iStep] <> 1 Then
				$bSwap = True
				SwapUpgrades($i, $i-$iStep)
			EndIf
		Next
	Until (Not $bTillEnd) Or (Not $bSwap)

	applyUpgradesGUI()
EndFunc

Func SwapUpgrades($i, $j)
	_ArraySwap($ipicUpgradeStatus, $i, $j)
	_ArraySwap($ichkbxUpgrade, $i, $j)
	_ArraySwap($aUpgrades, $i, $j)
	_ArraySwap($ichkUpgrdeRepeat, $i, $j)
EndFunc

Func applyUpgradesGUI()

	For $i = 0 To $iUpgradeSlots - 1 ; apply the buildings upgrade variable to GUI

		GUICtrlSetImage($picUpgradeStatus[$i], $pIconLib, $ipicUpgradeStatus[$i]) ; set status pic

		If $ichkbxUpgrade[$i] = 1 Then ; set upgrade check box
			GUICtrlSetState($chkbxUpgrade[$i], $GUI_CHECKED)
		Else
			GUICtrlSetState($chkbxUpgrade[$i], $GUI_UNCHECKED)
		EndIf

		GUICtrlSetData($txtUpgradeName[$i], $aUpgrades[$i][4]) ; set unit name
		GUICtrlSetData($txtUpgradeLevel[$i], $aUpgrades[$i][5]) ; set unit level

		Switch $aUpgrades[$i][3] ; set upgrade loot type
			Case "Gold"
				GUICtrlSetImage($picUpgradeType[$i], $pIconLib, $eIcnGold)
			Case "Elixir"
				GUICtrlSetImage($picUpgradeType[$i], $pIconLib, $eIcnElixir)
			Case "Dark"
				GUICtrlSetImage($picUpgradeType[$i], $pIconLib, $eIcnDark)
			Case Else
				GUICtrlSetImage($picUpgradeType[$i], $pIconLib, $eIcnBlank)
		EndSwitch

		If $aUpgrades[$i][2] > 0 Then ; set unit cost
			GUICtrlSetData($txtUpgradeValue[$i], _NumberFormat($aUpgrades[$i][2]))
		Else
			GUICtrlSetData($txtUpgradeValue[$i], "")
		EndIf

		GUICtrlSetData($txtUpgradeTime[$i], StringStripWS($aUpgrades[$i][6], $STR_STRIPALL)) ; set upgrade time

		If $ichkUpgrdeRepeat[$i] = 1 Then ; set repeat check box
			GUICtrlSetState($chkUpgrdeRepeat[$i], $GUI_CHECKED)
		Else
			GUICtrlSetState($chkUpgrdeRepeat[$i], $GUI_UNCHECKED)
		EndIf

	Next
EndFunc
