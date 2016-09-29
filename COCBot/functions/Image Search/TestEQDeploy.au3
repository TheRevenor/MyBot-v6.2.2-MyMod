
Func TestEQDeploy()

	$RunState = True
	Setlog(" »»» Initial TestEQDeploy ««« ")
	Local $subDirectory = @ScriptDir & "\TestsImages"
	DirCreate($subDirectory)

	Local $TestEQDeployTimer = TimerInit()

	; Earthquake Spell 4 tile radius , and so the diameter length would be 8
	; Tile x = 16px and y = 12px
	; Earthquake Spell diameter length | x= 128px and y = 96px
	Local $TileX = 128
	Local $TileY = 96

	; Capture the screen for comparison
	_CaptureRegion()

	; Store a copy of the image handle
	Local $editedImage = $hBitmap

	; Create the timestamp and filename
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $fileName = String($Date & "_" & $Time & ".png")

	; Needed for editing the picture
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 2) ; Create a pencil Color FF0000/RED
	Local $hPenWHITE = _GDIPlus_PenCreate(0xFFFFFFFF, 2) ; Create a pencil Color FFFFF/WHITE
	Local $hPenGREEN = _GDIPlus_PenCreate(0xFF00FF00, 2) ; Create a pencil Color 00FF00/LIME

	; Let's detect the TH
	Local $result, $listPixelByLevel, $pixelWithLevel, $level, $pixelStr, $TH[2]
	Local $aTownHallLocal[3] = [-1, -1, -1]
	Local $center = [430, 338]
	Local $MixX = 76, $MinY = 70, $MaxX = 790, $MaxY = 603
	Local $aTownHall

	Setlog(" »»» Initial detection TH and Red Lines ««« ")
	; detection TH and Red Lines with Imgloc
	Local $directory = @ScriptDir & "\images\Resources\TH"
	$aTownHall = returnHighestLevelSingleMatch($directory)
	Setlog(" »»» Ends detection TH and Red Lines ««« ")

	If Number($aTownHall[4]) > 0 Then
		; SetLog Debug
		Setlog(" »»» $aTownHall Rows: " & UBound($aTownHall))
		Setlog("filename: " & $aTownHall[0])
		Setlog("objectname: " & $aTownHall[1])
		Setlog("objectlevel: " & $aTownHall[2])
		Setlog("totalobjects: " & $aTownHall[4])
		Setlog(" »»» $aTownHall[5] Rows: " & UBound($aTownHall[5]))
		Setlog("$aTownHall[5]: " & $aTownHall[5])
		$pixelStr = $aTownHall[5]
		Setlog(" »»» X coord: " & $pixelStr[0][0])
		Setlog(" »»» Y coord: " & $pixelStr[0][1])

		; Fill the variables with values
		$TH[0] = $pixelStr[0][0]
		$TH[1] = $pixelStr[0][1]
		$level = $aTownHall[2]
		Setlog("RedLine String: " & $aTownHall[6])
	Else
		SetLog("ImgLoc TownHall Error..!!", $COLOR_RED)
	EndIf

	Setlog("Time Taken|$aTownHall: " & Round(TimerDiff($TestEQDeployTimer) / 1000, 2) & "'s") ; Time taken
	$TestEQDeployTimer = TimerInit()

	If isInsideDiamond($TH) Then
		Setlog("TownHall level: " & $level & "|" & $TH[0] & "-" & $TH[1])
	Else
		SetLog("Found TownHall with Invalid Location?", $COLOR_RED)
	EndIf

	; Let's Draw a Rectangulo on TH detection
	_GDIPlus_GraphicsDrawRect($hGraphic, $TH[0] - 5, $TH[1] - 5, 10, 10, $hPenRED)
	_GDIPlus_GraphicsDrawString($hGraphic, "TH" & $level, $TH[0] + 10, $TH[1], "Verdana", 15)

	; Red Lines

	Local $Redlines = Imgloc2MBR($aTownHall[6])
	Setlog("Time Taken|$Redlines|Imgloc2MBR: " & Round(TimerDiff($TestEQDeployTimer) / 1000, 2) & "'s") ; Time taken
	$TestEQDeployTimer = TimerInit()

	Setlog(" » RedLine string: " & $Redlines)

	Local $listPixelBySide = StringSplit($Redlines, "#")
	$PixelTopLeft = GetPixelSide($listPixelBySide, 1)
	$PixelBottomLeft = GetPixelSide($listPixelBySide, 2)
	$PixelBottomRight = GetPixelSide($listPixelBySide, 3)
	$PixelTopRight = GetPixelSide($listPixelBySide, 4)

	Setlog(" »» " & UBound($PixelTopLeft) + UBound($PixelBottomLeft) + UBound($PixelBottomRight) + UBound($PixelTopRight) & " points detected!")

	; Let's Detect the Most $RedLinepixel near the TH
	Local $tempFinalPixelTopLef[1][3]
	Local $tempFinalPixelBottomLeft[1][3]
	Local $tempFinalPixelBottomRight[1][3]
	Local $tempFinalPixelTopRight[1][3]

	For $i = 0 To UBound($PixelTopLeft) - 1
		Local $PixelTemp = $PixelTopLeft[$i]
		Local $Pixel = Pixel_Distance($PixelTemp[0], $PixelTemp[1], $TH[0], $TH[1])
		ReDim $tempFinalPixelTopLef[$i + 1][3]
		$tempFinalPixelTopLef[$i][0] = $PixelTemp[0]
		$tempFinalPixelTopLef[$i][1] = $PixelTemp[1]
		$tempFinalPixelTopLef[$i][2] = $Pixel
	Next

	For $i = 0 To UBound($PixelBottomLeft) - 1
		Local $PixelTemp = $PixelBottomLeft[$i]
		Local $Pixel = Pixel_Distance($PixelTemp[0], $PixelTemp[1], $TH[0], $TH[1])
		ReDim $tempFinalPixelBottomLeft[$i + 1][3]
		$tempFinalPixelBottomLeft[$i][0] = $PixelTemp[0]
		$tempFinalPixelBottomLeft[$i][1] = $PixelTemp[1]
		$tempFinalPixelBottomLeft[$i][2] = $Pixel
	Next
	For $i = 0 To UBound($PixelBottomRight) - 1
		Local $PixelTemp = $PixelBottomRight[$i]
		Local $Pixel = Pixel_Distance($PixelTemp[0], $PixelTemp[1], $TH[0], $TH[1])
		ReDim $tempFinalPixelBottomRight[$i + 1][3]
		$tempFinalPixelBottomRight[$i][0] = $PixelTemp[0]
		$tempFinalPixelBottomRight[$i][1] = $PixelTemp[1]
		$tempFinalPixelBottomRight[$i][2] = $Pixel
	Next
	For $i = 0 To UBound($PixelTopRight) - 1
		Local $PixelTemp = $PixelTopRight[$i]
		Local $Pixel = Pixel_Distance($PixelTemp[0], $PixelTemp[1], $TH[0], $TH[1])
		ReDim $tempFinalPixelTopRight[$i + 1][3]
		$tempFinalPixelTopRight[$i][0] = $PixelTemp[0]
		$tempFinalPixelTopRight[$i][1] = $PixelTemp[1]
		$tempFinalPixelTopRight[$i][2] = $Pixel
	Next

	Setlog("Time Taken|$Pixel_Distance Loop: " & Round(TimerDiff($TestEQDeployTimer) / 1000, 2) & "'s") ; Time taken
	$TestEQDeployTimer = TimerInit()

	_ArraySort($tempFinalPixelTopLef, 0, -1, -1, 2)
	_ArraySort($tempFinalPixelBottomLeft, 0, -1, -1, 2)
	_ArraySort($tempFinalPixelBottomRight, 0, -1, -1, 2)
	_ArraySort($tempFinalPixelTopRight, 0, -1, -1, 2)

	Local $MostNearTH[4][3]

	$MostNearTH[0][0] = $tempFinalPixelTopLef[0][0]
	$MostNearTH[0][1] = $tempFinalPixelTopLef[0][1]
	$MostNearTH[0][2] = $tempFinalPixelTopLef[0][2]

	$MostNearTH[1][0] = $tempFinalPixelBottomLeft[0][0]
	$MostNearTH[1][1] = $tempFinalPixelBottomLeft[0][1]
	$MostNearTH[1][2] = $tempFinalPixelBottomLeft[0][2]

	$MostNearTH[2][0] = $tempFinalPixelBottomRight[0][0]
	$MostNearTH[2][1] = $tempFinalPixelBottomRight[0][1]
	$MostNearTH[2][2] = $tempFinalPixelBottomRight[0][2]

	$MostNearTH[3][0] = $tempFinalPixelTopRight[0][0]
	$MostNearTH[3][1] = $tempFinalPixelTopRight[0][1]
	$MostNearTH[3][2] = $tempFinalPixelTopRight[0][2]

	_ArraySort($MostNearTH, 0, -1, -1, 2)

	Local $MasterPixel[2]
	$MasterPixel[0] = $MostNearTH[0][0]
	$MasterPixel[1] = $MostNearTH[0][1]

	Local $RedLinepixelCloserTH[2]

	Switch StringLeft(Slice8($MasterPixel), 1)
		Case 1, 2
			$MAINSIDE = "BOTTOM-RIGHT"
			$MixX = 430
			$MaxX = 790
			$MinY = 338
			$MaxY = 603
			Local $PixelRedLine = $PixelBottomRight
			$RedLinepixelCloserTH[0] = $tempFinalPixelBottomRight[0][0]
			$RedLinepixelCloserTH[1] = $tempFinalPixelBottomRight[0][1]
		Case 3, 4
			$MAINSIDE = "TOP-RIGHT"
			$MixX = 430
			$MaxX = 790
			$MinY = 70
			$MaxY = 338
			Local $PixelRedLine = $PixelTopRight
			$RedLinepixelCloserTH[0] = $tempFinalPixelTopRight[0][0]
			$RedLinepixelCloserTH[1] = $tempFinalPixelTopRight[0][1]
		Case 5, 6
			$MAINSIDE = "TOP-LEFT"
			$MixX = 76
			$MaxX = 430
			$MinY = 70
			$MaxY = 338
			Local $PixelRedLine = $PixelTopLeft
			$RedLinepixelCloserTH[0] = $tempFinalPixelTopLef[0][0]
			$RedLinepixelCloserTH[1] = $tempFinalPixelTopLef[0][1]
		Case 7, 8
			$MAINSIDE = "BOTTOM-LEFT"
			$MixX = 76
			$MaxX = 430
			$MinY = 338
			$MaxY = 603
			Local $PixelRedLine = $PixelBottomLeft
			$RedLinepixelCloserTH[0] = $tempFinalPixelBottomLeft[0][0]
			$RedLinepixelCloserTH[1] = $tempFinalPixelBottomLeft[0][1]
	EndSwitch
	Setlog("Forced side: " & $MAINSIDE)

	; Let's Draw a Rectangule of the MainSide
	_GDIPlus_GraphicsDrawRect($hGraphic, $MixX, $MinY, $MaxX - $MixX, $MaxY - $MinY, $hPenGREEN)
	_GDIPlus_GraphicsDrawString($hGraphic, "SIDE: " & $MAINSIDE, $MixX + 50, $MinY, "Verdana", 15)


	; Let's Draw the Red Line
	For $i = 0 To UBound($PixelRedLine) - 1
		Local $RedLinepixel = $PixelRedLine[$i]
		_GDIPlus_GraphicsDrawRect($hGraphic, $RedLinepixel[0] - 1, $RedLinepixel[1] - 1, 2, 2, $hPenRED)
	Next

	; Let's Draw a Line between $RedLinepixelCloserTH and TH
	_GDIPlus_GraphicsDrawLine($hGraphic, $RedLinepixelCloserTH[0], $RedLinepixelCloserTH[1], $TH[0], $TH[1], $hPenWHITE)

	Local $MiddleDistance[2] = [Floor(Abs($RedLinepixelCloserTH[0] - $TH[0]) / 2), Floor(Abs($RedLinepixelCloserTH[1] - $TH[1]) / 2)]

	If $RedLinepixelCloserTH[0] < $TH[0] And $RedLinepixelCloserTH[1] < $TH[1] Then ; Top Left Of The TH
		$MiddleDistance[0] = Abs($MiddleDistance[0] + $RedLinepixelCloserTH[0])
		$MiddleDistance[1] = Abs($MiddleDistance[1] + $RedLinepixelCloserTH[1])
		;_GDIPlus_GraphicsDrawRect($hGraphic, $MiddleDistance[0], $MiddleDistance[1], Abs($MiddleDistance[0] - $Th[0]), Abs($MiddleDistance[1] - $Th[1]), $hPenWHITE)
	EndIf
	If $RedLinepixelCloserTH[0] < $TH[0] And $RedLinepixelCloserTH[1] > $TH[1] Then ; Bottom Left Of The TH
		$MiddleDistance[0] = Abs($MiddleDistance[0] + $RedLinepixelCloserTH[0])
		$MiddleDistance[1] = Abs($MiddleDistance[1] - $RedLinepixelCloserTH[1])
		;_GDIPlus_GraphicsDrawRect($hGraphic, $MiddleDistance[0], $TH[1], Abs($MiddleDistance[0] - $Th[0]), Abs($MiddleDistance[1] - $Th[1]), $hPenWHITE)
	EndIf
	If $RedLinepixelCloserTH[0] > $TH[0] And $RedLinepixelCloserTH[1] > $TH[1] Then ; Bottom Right Of The TH
		$MiddleDistance[0] = Abs($MiddleDistance[0] - $RedLinepixelCloserTH[0])
		$MiddleDistance[1] = Abs($MiddleDistance[1] - $RedLinepixelCloserTH[1])
		;_GDIPlus_GraphicsDrawRect($hGraphic, $Th[0], $TH[1], Abs($MiddleDistance[0] - $Th[0]), Abs($MiddleDistance[1] - $Th[1]), $hPenWHITE)
	EndIf
	If $RedLinepixelCloserTH[0] > $TH[0] And $RedLinepixelCloserTH[1] < $TH[1] Then ; Top right Of The TH
		$MiddleDistance[0] = Abs($MiddleDistance[0] - $RedLinepixelCloserTH[0])
		$MiddleDistance[1] = Abs($MiddleDistance[1] + $RedLinepixelCloserTH[1])
		;_GDIPlus_GraphicsDrawRect($hGraphic, $Th[0], $MiddleDistance[1], Abs($MiddleDistance[0] - $Th[0]), Abs($MiddleDistance[1] - $Th[1]), $hPenWHITE)
	EndIf

	Setlog(" »» Middle Distance is: " & $MiddleDistance[0] & "-" & $MiddleDistance[1])

	; Let's Draw the Middle distance
	_GDIPlus_GraphicsDrawRect($hGraphic, $MiddleDistance[0] - 3, $MiddleDistance[1] - 3, 6, 6, $hPenWHITE)

	; Let´s make the Square to detect the walls
	Local $x = $MiddleDistance[0] - ($TileX / 2)
	Local $y = $MiddleDistance[1] - ($TileY / 2)
	Local $x1 = Floor(Abs($MiddleDistance[0] - $TH[0]) / 2)
	Local $y1 = Floor(Abs($MiddleDistance[1] - $TH[1]) / 2)

	If $MiddleDistance[0] < $TH[0] And $MiddleDistance[1] < $TH[1] Then ; Top Left Of The TH
		$x1 = Abs($x1 + $MiddleDistance[0])
		$y1 = Abs($y1 + $MiddleDistance[1])
	EndIf
	If $MiddleDistance[0] < $TH[0] And $MiddleDistance[1] > $TH[1] Then ; Bottom Left Of The TH
		$x1 = Abs($x1 + $MiddleDistance[0])
		$y1 = Abs($y1 - $MiddleDistance[1])
	EndIf
	If $MiddleDistance[0] > $TH[0] And $MiddleDistance[1] > $TH[1] Then ; Bottom Right Of The TH
		$x1 = Abs($x1 - $MiddleDistance[0])
		$y1 = Abs($y1 - $MiddleDistance[1])
	EndIf
	If $MiddleDistance[0] > $TH[0] And $MiddleDistance[1] < $TH[1] Then ; Top right Of The TH
		$x1 = Abs($x1 - $MiddleDistance[0])
		$y1 = Abs($y1 + $MiddleDistance[1])
	EndIf

	;_GDIPlus_GraphicsDrawEllipse($hGraphic, $x1 - 30, $y1 - 30, 60, 60, $hPenGREEN)
	_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $TileX, $TileY, $hPenRED)
	_GDIPlus_GraphicsDrawString($hGraphic, "|Walls|", $x + 10, $y + 10, "Verdana", 15)

	$TestEQDeployTimer = TimerInit()

	Local $FinalPixelWithDistance = GetWalls($x - 20 , $y - 20 , $TileX + 40 , $TileY + 40)
	Setlog("Time Taken|Walls detection: " & Round(TimerDiff($TestEQDeployTimer) / 1000, 2) & "'s") ; Time taken

	For $i = 0 To UBound($FinalPixelWithDistance) - 1
		_GDIPlus_GraphicsDrawRect($hGraphic, $FinalPixelWithDistance[$i][0] - 2, $FinalPixelWithDistance[$i][0] - 2, 4, 4, $hPenWHITE)
	Next

	; Clean up resources
	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & "\" & $fileName)
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_PenDispose($hPenWHITE)
	_GDIPlus_PenDispose($hPenGREEN)
	_GDIPlus_GraphicsDispose($hGraphic)

	; Lets Open the folder

	Run("Explorer.exe " & $subDirectory)
	$RunState = False

EndFunc   ;==>TestEQDeploy

Func Pixel_Distance($x1, $y1, $x2, $y2) ;Pythagoras theorem for 2D
	Local $a, $b, $c
	If $x2 = $x1 And $y2 = $y1 Then
		Return 0
	Else
		$a = $y2 - $y1
		$b = $x2 - $x1
		$c = Sqrt($a * $a + $b * $b)
		Return $c
	EndIf
EndFunc   ;==>Pixel_Distance

Func Imgloc2MBR($string)

	Local $AllPoints = StringSplit($string, "|", $STR_NOCOUNT)
	Local $EachPoint[UBound($AllPoints)][2]
	Local $_PixelTopLeft, $_PixelBottomLeft, $_PixelBottomRight, $_PixelTopRight

	For $i = 0 To UBound($AllPoints) - 1
		Local $temp = StringSplit($AllPoints[$i], ",", $STR_NOCOUNT)
		$EachPoint[$i][0] = Number($temp[0])
		$EachPoint[$i][1] = Number($temp[1])
		; Setlog(" $EachPoint[0]: " & $EachPoint[$i][0] & " | $EachPoint[1]: " & $EachPoint[$i][1])
	Next

	_ArraySort($EachPoint, 0, 0, 0, 0)

	For $i = 0 To UBound($EachPoint) - 1
		If $EachPoint[$i][0] > 60 And $EachPoint[$i][0] < 430 And $EachPoint[$i][1] > 35 And $EachPoint[$i][1] < 336 Then
			$_PixelTopLeft &= String("|" & $EachPoint[$i][0] & "-" & $EachPoint[$i][1])

		ElseIf $EachPoint[$i][0] > 60 And $EachPoint[$i][0] < 430 And $EachPoint[$i][1] > 336 And $EachPoint[$i][1] < 630 Then
			$_PixelBottomLeft &= String("|" & $EachPoint[$i][0] & "-" & $EachPoint[$i][1])

		ElseIf $EachPoint[$i][0] > 430 And $EachPoint[$i][0] < 805 And $EachPoint[$i][1] > 336 And $EachPoint[$i][1] < 630 Then
			$_PixelBottomRight &= String("|" & $EachPoint[$i][0] & "-" & $EachPoint[$i][1])

		ElseIf $EachPoint[$i][0] > 430 And $EachPoint[$i][0] < 805 And $EachPoint[$i][1] > 35 And $EachPoint[$i][1] < 336 Then
			$_PixelTopRight &= String("|" & $EachPoint[$i][0] & "-" & $EachPoint[$i][1])

		EndIf
	Next

	If Not StringIsSpace($_PixelTopLeft) Then $_PixelTopLeft = StringTrimLeft($_PixelTopLeft, 1)
	If Not StringIsSpace($_PixelBottomLeft) Then $_PixelBottomLeft = StringTrimLeft($_PixelBottomLeft, 1)
	If Not StringIsSpace($_PixelBottomRight) Then $_PixelBottomRight = StringTrimLeft($_PixelBottomRight, 1)
	If Not StringIsSpace($_PixelTopRight) Then $_PixelTopRight = StringTrimLeft($_PixelTopRight, 1)

	Local $NewRedLineString = $_PixelTopLeft & "#" & $_PixelBottomLeft & "#" & $_PixelBottomRight & "#" & $_PixelTopRight

	Return $NewRedLineString

EndFunc   ;==>Imgloc2MBR

Func GetWalls($x, $y, $x1, $y2)

	; Capture the screen for comparison
	_CaptureRegion2($x, $y, $x1, $y2)

	Local $aResult[1][6], $aCoordArray[0][0], $aCoords, $aCoordsSplit, $aValue
	Local $directory = @ScriptDir & "\images\Resources\Walls"

	Local $res = DllCall($hImgLib, "str", "SearchMultipleTilesBetweenLevels", "handle", $hHBitmap2, "str", $directory, "str", "DCD", "Int", 0, "str", "", "Int", 0, "Int", 10000)

	If $res[0] <> "" Then
		; Get the keys for the dictionary item.
		Local $aKeys = StringSplit($res[0], "|", $STR_NOCOUNT)

		; Redimension the result array to allow for the new entries
		ReDim $aResult[UBound($aKeys)][6]

		; Loop through the array
		For $i = 0 To UBound($aKeys) - 1
			; Get the property values
			$aResult[$i][0] = returnPropertyValue($aKeys[$i], "filename")
			$aResult[$i][1] = returnPropertyValue($aKeys[$i], "objectname")
			$aResult[$i][2] = returnPropertyValue($aKeys[$i], "objectlevel")
			$aResult[$i][3] = returnPropertyValue($aKeys[$i], "fillLevel")
			$aResult[$i][4] = returnPropertyValue($aKeys[$i], "totalobjects")

			; Get the coords property
			$aValue = returnPropertyValue($aKeys[$i], "objectpoints")
			$aCoords = StringSplit($aValue, "|", $STR_NOCOUNT)
			ReDim $aCoordArray[UBound($aCoords)][2]

			; Loop through the found coords
			For $j = 0 To UBound($aCoords) - 1
				; Split the coords into an array
				$aCoordsSplit = StringSplit($aCoords[$j], ",", $STR_NOCOUNT)
				If UBound($aCoordsSplit) = 2 Then
					; Store the coords into a two dimensional array
					$aCoordArray[$j][0] = $aCoordsSplit[0] + $x; X coord.
					$aCoordArray[$j][1] = $aCoordsSplit[1] + $y; Y coord.
				EndIf
			Next

			; Store the coords array as a sub-array
			$aResult[$i][5] = $aCoordArray
		Next
	EndIf

	Setlog(" GetWalls | Distance ")
	Local $temp , $FinalResult[1][2]
	Local $z  = 0

	For $i = 0 To UBound($aResult) - 1
		$temp = $aResult[$i][5]
		For $x = 0 To UBound($temp) - 1
			$FinalResult[$z][0] = $temp[$x][0]
			$FinalResult[$z][1] = $temp[$x][1]
			$z += 1
			ReDim $FinalResult[$z][2]
		Next
	Next

	Setlog(" »" & UBound($FinalResult) & " Walls Detected!")

	Setlog(" GetWalls | Distance II ")
	Local $FinalPixelWithDistance[1][2]
	$z = 0
	If UBound($FinalResult) > 1 Then
		For $i = 0 To UBound($FinalResult) - 1
			For $x = 0 To UBound($FinalResult) - 1 Step -1
				Local $aDistance = Pixel_Distance($FinalResult[$i][0], $FinalResult[$i][0], $FinalResult[$x][0], $FinalResult[$x][0])
				If  $aDistance <= 60 and $aDistance >= 30 Then
					$FinalPixelWithDistance[$z][0] = $FinalResult[$i][0]
					$FinalPixelWithDistance[$z][1] = $FinalResult[$i][1]
					$z += 1
					ReDim $FinalPixelWithDistance[$z][2]
				EndIf
			Next
		Next
	Else
		$FinalPixelWithDistance[0][0] = $FinalResult[0][0]
		$FinalPixelWithDistance[0][1] = $FinalResult[0][1]
	EndIf

	Setlog(" »" & UBound($FinalPixelWithDistance) & " Walls with 60px distance!")

	Return $FinalPixelWithDistance ; will be a 2D array $FinalPixelWithDistance[$i][2] with X = $FinalPixelWithDistance[$i][0] and Y = $FinalPixelWithDistance[$i][1]
EndFunc   ;==>GetWalls
