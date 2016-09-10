; #FUNCTION# ====================================================================================================================
; Name ..........: Algorithm_MilkingAttack.au3
; Description ...: Attacks a base with the Milking Algorithm
; Syntax ........: Algorithm_MilkingAttack()
; Parameters ....: None
; Return values .: None
; Author ........: Sardo (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: Noo
; ===============================================================================================================================

Func MilkingDebug()
	Local $debugselogLocal = $debugsetlog
	Local $MilkingExtractorsMatch
	$debugsetlog = 1
	Setlog("1 - Zoom out")
	CheckZoomOut()
	Local $TimeCheckMilkingAttack = TimerInit()
	Setlog("2 - Detect Elixir Collectors")
	Setlog("  2.1 Detect RedArea")
	MilkingDetectRedArea()
	$MilkFarmObjectivesSTR = ""
;~ 	Setlog("  2.2 Detect Elixir Extractors")
;~ 	$MilkingExtractorsMatch = MilkingDetectElixirExtractors()

	Setlog("  2.2bis detect elixir extractors2")
	$MilkingExtractorsMatch = MilkingDetectElixirExtractors()

	Setlog("  2.3 Detect Mine Extractors")
	$MilkingExtractorsMatch += MilkingDetectMineExtractors()
	Setlog("  2.4 Detect Dark Elixir Extractors")
	Local $TimeCheckMilkingAttackSeconds = Round(TimerDiff($TimeCheckMilkingAttack) / 1000, 2)
	Setlog("Computing Time Milking Attack : " & $TimeCheckMilkingAttackSeconds & " seconds", $color_blue)
	$debugsetlog = $debugselogLocal
	Setlog("Make DebugImage")
	MilkFarmObjectivesDebugImage($MilkFarmObjectivesSTR, 0)

EndFunc   ;==>MilkingDebug

Func CheckMilkingBaseTest()

	Local $MilkingElixirImages = _FileListToArray(@ScriptDir & "\images\Milking\Elixir", "*.*")
        If @error = 1 Then
            MsgBox(0, "", "Folder" &  @ScriptDir & "\images\Milking\Elixir" & " not Found.")
        EndIf
        If @error = 4 Then
            MsgBox(0, "", "No Files in folder " &@ScriptDir & "\images\Milking\Elixir" )
        EndIf
	Setlog("Locate Elixir..." )
	$hTimer = TimerInit()

	_CaptureRegion2()
	_CaptureRegion()
	$sendHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	Local $MilkFarmAtkPixelListSTR = ""
	Local $ElixirVect = StringSplit(GetLocationElixirWithLevel(), "~", 2) 
	Local $elixirfounds = UBound($ElixirVect)
	Local $elixirmatch = 0
	Local $elixirdiscard = 0
	For $i = 0 To UBound($ElixirVect) - 1


	;	If $debugsetlog = 1 Then Setlog($i & " : " & $ElixirVect[$i]) ;[15:51:30] 0 : 2#405-325 -> level 6

			;03.02 check isinsidediamond
			Local $temp = StringSplit($ElixirVect[$i], "#", 2) ;TEMP ["2", "404-325"]
			If UBound($temp) = 2 Then

				Setlog("examine elixir vector #" & $i & " placed in " & $ElixirVect[$i],$COLOR_RED)
				Local $pixelTemp = StringSplit($ElixirVect[$i],"-",2)
				$pixelTemp[0] += 0
				$pixelTemp[1] += 10
				Local $arrPixelsCloser = _FindPixelCloser($PixelRedArea, $pixelTemp, 1)
				Setlog("pixelcloser=" & $arrPixelsCloser & "ubound = " & Ubound($arrPixelsCloser))
				For $t=0 to Ubound($arrPixelsCloser) -1
					Local $temp = $arrPixelsCloser[$t]

					Setlog("$arrPixelsCloser " & $arrPixelsCloser[$t] & " ubound = " & Ubound($temp) & " " & $temp[0] & "-" & $temp[1])
				Next

				If UBound($arrPixelsCloser) > 1 Then

				EndIf
			Else
				If $debugsetlog = 1 Then Setlog(" - discard #1 no valid point", $color_purple)
				$elixirdiscard += 1
			EndIf
		Setlog("............ next ..........")
	Next

EndFunc

