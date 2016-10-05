; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...: This file contens the attack algorithm SCRIPTED
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Sardo (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $MAINSIDE = "TOP-RIGHT"
Global $FRONT_LEFT = "TOP-RIGHT-DOWN"
Global $FRONT_RIGHT = "TOP-RIGHT-UP"
Global $RIGHT_FRONT = "TOP-LEFT-UP"
Global $RIGHT_BACK = "TOP-LEFT-DOWN"
Global $LEFT_FRONT = "BOTTOM-RIGHT-UP"
Global $LEFT_BACK = "BOTTOM-RIGHT-DOWN"
Global $BACK_LEFT = "BOTTOM-LEFT-DOWN"
Global $BACK_RIGHT = "BOTTOM-LEFT-UP"


Global $PixelTopLeftDropLine
Global $PixelTopRightDropLine
Global $PixelBottomLeftDropLine
Global $PixelBottomRightDropLine
Global $PixelTopLeftUPDropLine
Global $PixelTopLeftDOWNDropLine
Global $PixelTopRightUPDropLine
Global $PixelTopRightDOWNDropLine
Global $PixelBottomLeftUPDropLine
Global $PixelBottomLeftDOWNDropLine
Global $PixelBottomRightUPDropLine
Global $PixelBottomRightDOWNDropLine


Global $ExternalArea[8][3] = [ _
		[15, 338, "LEFT"], _
		[836, 338, "RIGHT"], _
		[430, 29, "TOP"], _
		[430, 642, "BOTTOM"], _
		[15 + (430 - 15) / 2, 29 + (338 - 29) / 2, "TOP-LEFT"], _
		[430 + (836 - 430) / 2, 29 + (338 - 29) / 2, "TOP-RIGHT"], _
		[15 + (430 - 15) / 2, 338 + (642 - 338) / 2, "BOTTOM-LEFT"], _
		[430 + (836 - 430) / 2, 338 + (642 - 338) / 2, "BOTTOM-RIGHT"] _
		]
Global $InternalArea[8][3] = [[73, 338, "LEFT"], _
		[785, 338, "RIGHT"], _
		[430, 70, "TOP"], _
		[430, 603, "BOTTOM"], _
		[73 + (430 - 73) / 2, 68 + (338 - 68) / 2, "TOP-LEFT"], _
		[430 + (785 - 430) / 2, 68 + (338 - 68) / 2, "TOP-RIGHT"], _
		[73 + (430 - 73) / 2, 338 + (603 - 338) / 2, "BOTTOM-LEFT"], _
		[430 + (785 - 430) / 2, 338 + (603 - 338) / 2, "BOTTOM-RIGHT"] _
		]


; #FUNCTION# ====================================================================================================================
; Name ..........: Algorithm_AttackCSV
; Description ...:
; Syntax ........: Algorithm_AttackCSV([$testattack = False])
; Parameters ....: $testattack          - [optional]
; Return values .: None
; Author ........: Sardo (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func Algorithm_AttackCSV($testattack = False, $captureredarea = True)

	;	00 read attack file SIDE row and valorize variables
	ParseAttackCSV_Read_SIDE_variables()
	If _Sleep($iDelayRespond) Then Return

	Local $hTimerTOTAL = TimerInit()

	;	01 - TROOPS ------------------------------------------------------------------------------------------------------------------------------------------
	debugAttackCSV("Troops to be used (purged from troops) ")
	For $i = 0 To UBound($atkTroops) - 1 ; identify the position of this kind of troop
		debugAttackCSV("SLOT n.: " & $i & " - Troop: " & NameOfTroop($atkTroops[$i][0]) & " (" & $atkTroops[$i][0] & ") - Quantity: " & $atkTroops[$i][1])
	Next

;~ 	;	02 - REDAREA -----------------------------------------------------------------------------------------------------------------------------------------
;~ 	Local $hTimer = TimerInit()

;~ 	_CaptureRegion2()
;~ 	if $captureredarea then _GetRedArea()
;~ 	If _Sleep($iDelayRespond) Then Return

;~ 	Setlog("> Get all Red Area in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)

	Local $hTimer = TimerInit()

	Local $htimerREDAREA = Round(TimerDiff($hTimer) / 1000, 2)
	debugAttackCSV("Calculated  (in " & $htimerREDAREA & " seconds) :")
	debugAttackCSV("	[" & UBound($PixelTopLeft) & "] pixels TopLeft")
	debugAttackCSV("	[" & UBound($PixelTopRight) & "] pixels TopRight")
	debugAttackCSV("	[" & UBound($PixelBottomLeft) & "] pixels BottomLeft")
	debugAttackCSV("	[" & UBound($PixelBottomRight) & "] pixels BottomRight")

	;	03 - TOWNHALL ------------------------------------------------------------------------
	If $searchTH = "-" Then

		If $attackcsv_locate_townhall = 1 Then
			SuspendAndroid()
			$hTimer = TimerInit()
			Local $searchTH = checkTownHallADV2(0, 0, False)
			If $searchTH = "-" Then ; retry with autoit search after $iDelayVillageSearch5 seconds
				If _Sleep($iDelayAttackCSV1) Then Return
				If $debugsetlog = 1 Then SetLog("2nd attempt to detect the TownHall!", $COLOR_RED)
				$searchTH = checkTownhallADV2()
			EndIf
			If $searchTH = "-" Then ; retry with c# search, matching could not have been caused by heroes that partially hid the townhall
				If _Sleep($iDelayAttackCSV2) Then Return
				If $debugImageSave = 1 Then DebugImageSave("VillageSearch_NoTHFound2try_", False)
				THSearch()
			EndIf
			Setlog("> Townhall located in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
			ResumeAndroid()
		Else
			Setlog("> Townhall search not needed, skip")
		EndIf
	Else
		Setlog("> Townhall has already been located in while searching for an image", $COLOR_BLUE)
	EndIf
	If _Sleep($iDelayRespond) Then Return

	_CaptureRegion2()

	;	04 - MINES, COLLECTORS, DRILLS -----------------------------------------------------------------------------------------------------------------------

	;reset variables
	Global $PixelMine[0]
	Global $PixelElixir[0]
	Global $PixelDarkElixir[0]
	Local $PixelNearCollectorTopLeftSTR = ""
	Local $PixelNearCollectorBottomLeftSTR = ""
	Local $PixelNearCollectorTopRightSTR = ""
	Local $PixelNearCollectorBottomRightSTR = ""


	;	04.01 If drop troop near gold mine
	If $attackcsv_locate_mine = 1 Then
		;SetLog("Locating mines")
		$hTimer = TimerInit()
		SuspendAndroid()
		$PixelMine = GetLocationMine()
		ResumeAndroid()
		If _Sleep($iDelayRespond) Then Return
		CleanRedArea($PixelMine)
		Local $htimerMine = Round(TimerDiff($hTimer) / 1000, 2)
		If (IsArray($PixelMine)) Then
			For $i = 0 To UBound($PixelMine) - 1
				$pixel = $PixelMine[$i]
				Local $str = $pixel[0] & "-" & $pixel[1] & "-" & "MINE"
				If isInsideDiamond($pixel) Then
					If $pixel[0] <= $InternalArea[2][0] Then
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP LEFT SIDE")
							$PixelNearCollectorTopLeftSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM LEFT SIDE")
							$PixelNearCollectorBottomLeftSTR &= $str & "|"
						EndIf
					Else
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP RIGHT SIDE")
							$PixelNearCollectorTopRightSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM RIGHT SIDE")
							$PixelNearCollectorBottomRightSTR &= $str & "|"
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		Setlog("> Mines located in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
	Else
		Setlog("> Mines detection not needed, skip", $COLOR_BLUE)
	EndIf
	If _Sleep($iDelayRespond) Then Return

	;	04.02  If drop troop near elisir
	If $attackcsv_locate_elixir = 1 Then
		;SetLog("Locating elixir")
		$hTimer = TimerInit()
		SuspendAndroid()
		$PixelElixir = GetLocationElixir()
		ResumeAndroid()
		If _Sleep($iDelayRespond) Then Return
		CleanRedArea($PixelElixir)
		Local $htimerMine = Round(TimerDiff($hTimer) / 1000, 2)
		If (IsArray($PixelElixir)) Then
			For $i = 0 To UBound($PixelElixir) - 1
				$pixel = $PixelElixir[$i]
				Local $str = $pixel[0] & "-" & $pixel[1] & "-" & "ELIXIR"
				If isInsideDiamond($pixel) Then
					If $pixel[0] <= $InternalArea[2][0] Then
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP LEFT SIDE")
							$PixelNearCollectorTopLeftSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM LEFT SIDE")
							$PixelNearCollectorBottomLeftSTR &= $str & "|"
						EndIf
					Else
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP RIGHT SIDE")
							$PixelNearCollectorTopRightSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM RIGHT SIDE")
							$PixelNearCollectorBottomRightSTR &= $str & "|"
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		Setlog("> Elixir collectors located in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
	Else
		Setlog("> Elixir collectors detection not needed, skip", $COLOR_BLUE)
	EndIf
	If _Sleep($iDelayRespond) Then Return

	;	04.03 If drop troop near drill
	If $attackcsv_locate_drill = 1 Then
		;SetLog("Locating drills")
		$hTimer = TimerInit()
		SuspendAndroid()
		$PixelDarkElixir = GetLocationDarkElixir()
		ResumeAndroid()
		If _Sleep($iDelayRespond) Then Return
		CleanRedArea($PixelDarkElixir)
		Local $htimerMine = Round(TimerDiff($hTimer) / 1000, 2)
		If (IsArray($PixelDarkElixir)) Then
			For $i = 0 To UBound($PixelDarkElixir) - 1
				$pixel = $PixelDarkElixir[$i]
				Local $str = $pixel[0] & "-" & $pixel[1] & "-" & "DRILL"
				If isInsideDiamond($pixel) Then
					If $pixel[0] <= $InternalArea[2][0] Then
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP LEFT SIDE")
							$PixelNearCollectorTopLeftSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM LEFT SIDE")
							$PixelNearCollectorBottomLeftSTR &= $str & "|"
						EndIf
					Else
						If $pixel[1] <= $InternalArea[0][1] Then
							;Setlog($str & " :  TOP RIGHT SIDE")
							$PixelNearCollectorTopRightSTR &= $str & "|"
						Else
							;Setlog($str & " :  BOTTOM RIGHT SIDE")
							$PixelNearCollectorBottomRightSTR &= $str & "|"
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		Setlog("> Drills located in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
	Else
		Setlog("> Drills detection not needed, skip", $COLOR_BLUE)
	EndIf
	If _Sleep($iDelayRespond) Then Return

	If StringLen($PixelNearCollectorTopLeftSTR) > 0 Then $PixelNearCollectorTopLeftSTR = StringLeft($PixelNearCollectorTopLeftSTR, StringLen($PixelNearCollectorTopLeftSTR) - 1)
	If StringLen($PixelNearCollectorTopRightSTR) > 0 Then $PixelNearCollectorTopRightSTR = StringLeft($PixelNearCollectorTopRightSTR, StringLen($PixelNearCollectorTopRightSTR) - 1)
	If StringLen($PixelNearCollectorBottomLeftSTR) > 0 Then $PixelNearCollectorBottomLeftSTR = StringLeft($PixelNearCollectorBottomLeftSTR, StringLen($PixelNearCollectorBottomLeftSTR) - 1)
	If StringLen($PixelNearCollectorBottomRightSTR) > 0 Then $PixelNearCollectorBottomRightSTR = StringLeft($PixelNearCollectorBottomRightSTR, StringLen($PixelNearCollectorBottomRightSTR) - 1)
	$PixelNearCollectorTopLeft = GetListPixel3($PixelNearCollectorTopLeftSTR)
	$PixelNearCollectorTopRight = GetListPixel3($PixelNearCollectorTopRightSTR)
	$PixelNearCollectorBottomLeft = GetListPixel3($PixelNearCollectorBottomLeftSTR)
	$PixelNearCollectorBottomRight = GetListPixel3($PixelNearCollectorBottomRightSTR)

	If $attackcsv_locate_gold_storage = 1 Then
		SuspendAndroid()
		$GoldStoragePos = GetLocationGoldStorage()
		ResumeAndroid()
	EndIf

	If $attackcsv_locate_elixir_storage = 1 Then
		SuspendAndroid()
		$ElixirStoragePos = GetLocationElixirStorage()
		ResumeAndroid()
	EndIf


	; 05 - DARKELIXIRSTORAGE ------------------------------------------------------------------------
	If $attackcsv_locate_dark_storage = 1 Then
		$hTimer = TimerInit()
		SuspendAndroid()
		Local $PixelDarkElixirStorage = GetLocationDarkElixirStorageWithLevel()
		ResumeAndroid()
		If _Sleep($iDelayRespond) Then Return
		CleanRedArea($PixelDarkElixirStorage)
		Local $pixel = StringSplit($PixelDarkElixirStorage, "#", 2)
		If UBound($pixel) >= 2 Then
			Local $pixellevel = $pixel[0]
			Local $pixelpos = StringSplit($pixel[1], "-", 2)
			If UBound($pixelpos) >= 2 Then
				Local $temp = [Int($pixelpos[0]), Int($pixelpos[1])]
				$darkelixirStoragePos = $temp
			EndIf
		EndIf
		Setlog("> Dark Elixir Storage located in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
	Else
		Setlog("> Dark Elixir Storage detection not need, skip", $COLOR_BLUE)
	EndIf

	Setlog(">> Total time: " & Round(TimerDiff($hTimerTOTAL) / 1000, 2) & " seconds", $COLOR_BLUE)

	; 06 - DEBUGIMAGE ------------------------------------------------------------------------
	If $makeIMGCSV = 1 Then AttackCSVDEBUGIMAGE() ;make IMG debug

	; 07 - START TH SNIPE BEFORE ATTACK CSV IF NEED ------------------------------------------
	If $THSnipeBeforeDBEnable = 1 And $searchTH = "-" Then FindTownHall(True) ;search townhall if no previous detect
	If $THSnipeBeforeDBEnable = 1 Then
		If $searchTH <> "-" Then
			If SearchTownHallLoc() Then
				Setlog(_PadStringCenter(" TH snipe Before Scripted Attack ", 54, "="), $color_blue)
				$THusedKing = 0
				$THusedQueen = 0
				AttackTHParseCSV()
			Else
				If $debugsetlog = 1 Then Setlog("TH snipe before scripted attack skip, th internal village", $color_purple)
			EndIf
		Else
			If $debugsetlog = 1 Then Setlog("TH snipe before scripted attack skip, no th found", $color_purple)
		EndIf
	EndIf

	; 08 - LAUNCH PARSE FUNCTION -------------------------------------------------------------
	SetSlotSpecialTroops()
	If _Sleep($iDelayRespond) Then Return
	ParseAttackCSV($testattack)

EndFunc   ;==>Algorithm_AttackCSV

Func ParseAndMakeDropLines($MAINSIDE)

	Local $hTimer = TimerInit()

	; Oldest Method |MBRFunction

	;Local $colorVariation = 30
	;Local $xSkip = 1
	;Local $ySkip = 5
	;Local $result = DllCall($hFuncLib, "str", "getRedArea", "ptr", $hHBitmap2, "int", $xSkip, "int", $ySkip, "int", $colorVariation)

	; New Method |ImgLoc

	Local $result[1]
	$result[0] = GetImgLoc2MBR()
	If $debugsetlog Then Setlog("Debug: Redline chosen")
	;Setlog(" »» NEW REDlines Imgloc: " & $result[0])
	Setlog("> NEW REDlines Imgloc in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)

	Local $listPixelBySide = StringSplit($result[0], "#")
	$PixelTopLeft = GetPixelSide($listPixelBySide, 1)
	$PixelBottomLeft = GetPixelSide($listPixelBySide, 2)
	$PixelBottomRight = GetPixelSide($listPixelBySide, 3)
	$PixelTopRight = GetPixelSide($listPixelBySide, 4)

	ReDim $PixelRedArea[UBound($PixelTopLeft) + UBound($PixelBottomLeft) + UBound($PixelTopRight) + UBound($PixelBottomRight)]
	ReDim $PixelRedAreaFurther[UBound($PixelTopLeft) + UBound($PixelBottomLeft) + UBound($PixelTopRight) + UBound($PixelBottomRight)]

	Local $hTimer = TimerInit()

	;If $MAINSIDE = "BOTTOM-RIGHT" Then
		CleanRedArea($PixelBottomRight)
		If UBound($PixelBottomRight) < 20 Then
			$PixelBottomRight = _GetVectorOutZone($eVectorRightBottom)
		EndIf
		debugAttackCSV("RedArea cleaned")
		debugAttackCSV("	[" & UBound($PixelBottomRight) & "] pixels BottomRight")
		$PixelBottomRightDropLine = MakeDropLine($PixelBottomRight, StringSplit($InternalArea[3][0] & "-" & $InternalArea[3][1] + 20, "-", $STR_NOCOUNT), StringSplit($InternalArea[1][0] + 30 & "-" & $InternalArea[1][1], "-", $STR_NOCOUNT))
		;-- BOTTOM RIGHT
		Local $tempvectstr1 = ""
		Local $tempvectstr2 = ""
		For $i = 0 To UBound($PixelBottomRightDropLine) - 1
			$pixel = $PixelBottomRightDropLine[$i]
			Switch StringLeft(Slice8($pixel), 1)
				Case "1"
					$tempvectstr1 &= $pixel[0] & "-" & $pixel[1] & "|"
				Case "2"
					$tempvectstr2 &= $pixel[0] & "-" & $pixel[1] & "|"
			EndSwitch
		Next
		If StringLen($tempvectstr1) > 0 Then $tempvectstr1 = StringLeft($tempvectstr1, StringLen($tempvectstr1) - 1)
		If StringLen($tempvectstr2) > 0 Then $tempvectstr2 = StringLeft($tempvectstr2, StringLen($tempvectstr2) - 1)
		$PixelBottomRightDOWNDropLine = GetListPixel($tempvectstr1)
		$PixelBottomRightUPDropLine = GetListPixel($tempvectstr2)
		Setlog("> BOTTOM-RIGHT DROP LINE EDGE in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
		$hTimer = TimerInit()
	;EndIf

	;If $MAINSIDE = "TOP-RIGHT" Then
		CleanRedArea($PixelTopRight)
		If UBound($PixelTopRight) < 20 Then
			$PixelTopRight = _GetVectorOutZone($eVectorRightTop)
		EndIf
		debugAttackCSV("RedArea cleaned")
		debugAttackCSV("	[" & UBound($PixelTopRight) & "] pixels TopRight")
		$PixelTopRightDropLine = MakeDropLine($PixelTopRight, StringSplit($InternalArea[2][0] & "-" & $InternalArea[2][1] - 25, "-", $STR_NOCOUNT), StringSplit($InternalArea[1][0] + 30 & "-" & $InternalArea[1][1], "-", $STR_NOCOUNT))
		;-- TOP RIGHT
		Local $tempvectstr1 = ""
		Local $tempvectstr2 = ""
		For $i = 0 To UBound($PixelTopRightDropLine) - 1
			$pixel = $PixelTopRightDropLine[$i]
			Switch StringLeft(Slice8($pixel), 1)
				Case "3"
					$tempvectstr1 &= $pixel[0] & "-" & $pixel[1] & "|"
				Case "4"
					$tempvectstr2 &= $pixel[0] & "-" & $pixel[1] & "|"
			EndSwitch
		Next
		If StringLen($tempvectstr1) > 0 Then $tempvectstr1 = StringLeft($tempvectstr1, StringLen($tempvectstr1) - 1)
		If StringLen($tempvectstr2) > 0 Then $tempvectstr2 = StringLeft($tempvectstr2, StringLen($tempvectstr2) - 1)
		$PixelTopRightDOWNDropLine = GetListPixel($tempvectstr1)
		$PixelTopRightUPDropLine = GetListPixel($tempvectstr2)
		Setlog("> TOP-RIGHT DROP LINE EDGE in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
		$hTimer = TimerInit()
	;EndIf

	;If $MAINSIDE = "TOP-LEFT" Then
		CleanRedArea($PixelTopLeft)
		If UBound($PixelTopLeft) < 20 Then
			$PixelTopLeft = _GetVectorOutZone($eVectorLeftTop)
		EndIf
		debugAttackCSV("RedArea cleaned")
		debugAttackCSV("	[" & UBound($PixelTopLeft) & "] pixels TopLeft")
		$PixelTopLeftDropLine = MakeDropLine($PixelTopLeft, StringSplit($InternalArea[0][0] - 30 & "-" & $InternalArea[0][1], "-", $STR_NOCOUNT), StringSplit($InternalArea[2][0] & "-" & $InternalArea[2][1] - 25, "-", $STR_NOCOUNT))
		;-- TOP LEFT
		Local $tempvectstr1 = ""
		Local $tempvectstr2 = ""
		For $i = 0 To UBound($PixelTopLeftDropLine) - 1
			$pixel = $PixelTopLeftDropLine[$i]
			Switch StringLeft(Slice8($pixel), 1)
				Case "6"
					$tempvectstr1 &= $pixel[0] & "-" & $pixel[1] & "|"
				Case "5"
					$tempvectstr2 &= $pixel[0] & "-" & $pixel[1] & "|"
			EndSwitch
		Next
		If StringLen($tempvectstr1) > 0 Then $tempvectstr1 = StringLeft($tempvectstr1, StringLen($tempvectstr1) - 1)
		If StringLen($tempvectstr2) > 0 Then $tempvectstr2 = StringLeft($tempvectstr2, StringLen($tempvectstr2) - 1)
		$PixelTopLeftDOWNDropLine = GetListPixel($tempvectstr1)
		$PixelTopLeftUPDropLine = GetListPixel($tempvectstr2)
		Setlog("> TOP-LEFT DROP LINE EDGE in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
		$hTimer = TimerInit()
	;EndIf

	;If $MAINSIDE = "BOTTOM-LEFT" Then
		CleanRedArea($PixelBottomLeft)
		If UBound($PixelBottomLeft) < 20 Then
			$PixelBottomLeft = _GetVectorOutZone($eVectorLeftBottom)
		EndIf
		debugAttackCSV("RedArea cleaned")
		debugAttackCSV("	[" & UBound($PixelBottomLeft) & "] pixels BottomLeft")
		$PixelBottomLeftDropLine = MakeDropLine($PixelBottomLeft, StringSplit($InternalArea[0][0] - 30 & "-" & $InternalArea[0][1], "-", $STR_NOCOUNT), StringSplit($InternalArea[3][0] & "-" & $InternalArea[3][1] + 20, "-", $STR_NOCOUNT))
		;-- BOTTOM LEFT
		Local $tempvectstr1 = ""
		Local $tempvectstr2 = ""
		For $i = 0 To UBound($PixelBottomLeftDropLine) - 1
			$pixel = $PixelBottomLeftDropLine[$i]
			Switch StringLeft(Slice8($pixel), 1)
				Case "8"
					$tempvectstr1 &= $pixel[0] & "-" & $pixel[1] & "|"
				Case "7"
					$tempvectstr2 &= $pixel[0] & "-" & $pixel[1] & "|"
			EndSwitch
		Next
		If StringLen($tempvectstr1) > 0 Then $tempvectstr1 = StringLeft($tempvectstr1, StringLen($tempvectstr1) - 1)
		If StringLen($tempvectstr2) > 0 Then $tempvectstr2 = StringLeft($tempvectstr2, StringLen($tempvectstr2) - 1)
		$PixelBottomLeftDOWNDropLine = GetListPixel($tempvectstr1)
		$PixelBottomLeftUPDropLine = GetListPixel($tempvectstr2)
		Setlog("> BOTTOM-LEFT DROP LINE EDGE in  " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_BLUE)
	;EndIf

	If _Sleep($iDelayRespond) Then Return

EndFunc   ;==>ParseAndMakeDropLines
