; #FUNCTION# ====================================================================================================================
; Name ..........: TrainBoosted.au3
; Description ...: Train the troops (Fill the barracks), when is necessary take advantage of a Boosted barrack
; Syntax ........: TrainNormalTroopsBoosted() , TrainDarkTroopsBoosted()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (08-2016)
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TrainNormalTroops()

	If $debugsetlogTrain = 1 Then SetLog("Func TrainNormalTroops ", $COLOR_PURPLE) ; If $debugsetlogTrain = 1 Then

	Local $anotherTroops
	Local $tempCounter = 0
	Local $tempElixir = ""
	Local $tempDElixir = ""
	Local $tempElixirSpent = 0
	Local $tempDElixirSpent = 0
	Local $tmpNumber


	; #############################################################################################################################################
	; ###########################################  1st Stage : Prepare training & Variables & Values ##############################################
	; #############################################################################################################################################

	; Reset variables $Cur+TroopName ( used to assign the quantity of troops to train and existent in armycamp)
	; Only reset if the Last attacks was a TH Snipes or First Start.
	; Global $Cur+TroopName = 0

	For $i = 0 To UBound($TroopName) - 1
		If $debugsetlogTrain = 1 Then SetLog("Reset the $Cur" & $TroopName[$i], $COLOR_PURPLE)
		Assign("Cur" & $TroopName[$i], 0)
	Next

	If _Sleep($iDelayTrain4) Then Return

	;OPEN ARMY OVERVIEW WITH NEW BUTTON
	GoesToArmyOverViewWindow()

	If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
		If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
		If IsTrainPage() Then BarracksStatus(False)
	EndIf
	If _Sleep(500) Then Return

	GoesToFirstBarrack()
	If _Sleep(2000) Then Return ; ---> can be made with WaitforPixel()
	If $debugsetlogTrain = 1 Then Setlog("Deleting Queue Troops")
	DeleteQueueTroops()
	If $debugsetlogTrain = 1 Then Setlog("Deleting Queue DarkTroops")

	GoesToArmyOverViewWindow()
	If _Sleep(1000) Then Return ; ---> can be made with WaitforPixel()
	If IsTrainPage() Then getArmyCapacity()
	If $Fullarmy Then Return
	If IsTrainPage() Then getArmyNormalTroopCount()

	If $CurCamp = 0 Then ; In case Of fail
		ClickP($aAway, 2, 0, "#0268") ;Click Away to clear open windows in case user interupted
		If _Sleep(1000) Then Return
		openArmyOverview()
		If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
			If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
			If IsTrainPage() Then getArmyNormalTroopCount()
		EndIf
	EndIf

	If _Sleep($iDelayRunBot6) Then Return ; wait for window to open
	If Not (IsTrainPage()) Then Return ; exit if I'm not in train page

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page

	; Verify the Global variable $TroopName+Comp and return the GUI selected troops by user
	;

	For $i = 0 To UBound($TroopName) - 1
		If Eval($TroopName[$i] & "Comp") <> "0" Then
			$isNormalBuild = True
		EndIf
	Next

	If $isNormalBuild = "" Then
		$isNormalBuild = False
	EndIf
	If $debugsetlogTrain = 1 Then SetLog(" » Is it necessary to make normal Troops: " & $isNormalBuild, $COLOR_PURPLE)

	; PREPARE TROOPS IF FULL ARMY
	; Barracks status to false , after the first loop and train Selected Troops composition = True
	;
	If $debugsetlogTrain = 1 Then Setlog(" » $Fullarmy = " & $fullarmy & " |$CurCamp = " & $CurCamp & " |$TotalCamp = " & $TotalCamp, $COLOR_PURPLE)


	; If is fullArmy or FirstStart the $Cur will Store the correct troops - necessary troops to make. Or we are using the Barracks modes is not necessary
	; count/make the donated troops. Reset the Donate variable to 0

	For $i = 0 To UBound($TroopName) - 1
		Assign("Don" & $TroopName[$i], 0)
	Next


	; ###################################################################################################################################################
	; ############################################################### Barrack Total status ##############################################################
	; ################################################################# Assign variables ################################################################
	; ############################################################## Check Boosted barracks #############################################################
	; ############################################################### Boost remaining Time ##############################################################
	; ###################################################################################################################################################

	Local $numBarracksAvailable = $numBarracksAvaiables ; Avaiables | misspelling
	Local $numDarkBarracksAvailable = $numDarkBarracksAvaiables ; Avaiables | misspelling

	For $i = 0 To $numBarracksAvaiables - 1
		$BarrackTimeRemain[$i] = 0
	Next

	; Array with the total training time of each Barrack | Current house spacing | If it is Boosted Barrack | Remain Boosted time | Max Unit Queue Length

	Local $BarrackTotalStatus[$numBarracksAvailable][5]

	If $debugsetlogTrain = 1 Then Setlog(" » Num Barracks Available : " & $numBarracksAvailable)
	If $debugsetlogTrain = 1 Then Setlog(" » Declared Local Scope : $BarrackTotalStatus[" & UBound($BarrackTotalStatus) & "][5]")

	; Check What barrack|dark barrack was boosted with ColorCheck on ArmyOverView Window

	ReDim $CheckIfWasBoostedOnBarrack[$numBarracksAvailable]
	$CheckIfWasBoostedOnBarrack = CheckBarrackBoost(True, False, True, False)

	For $i = 0 To UBound($CheckIfWasBoostedOnBarrack) - 1
		If $debugsetlogTrain = 1 Then Setlog("$CheckIfWasBoostedOnBarrack[" & $i & "]: " & $CheckIfWasBoostedOnBarrack[$i])
	Next

	If $CheckIfWasBoostedOnBarrack = -1 Then
		Setlog(" » Error on $CheckIfWasBoostedOnBarrack", $COLOR_RED)
		For $i = 0 To UBound($numBarracksAvailable) - 1
			$CheckIfWasBoostedOnBarrack[$i] = 0
		Next
	EndIf

	; Verify is Exist a Boosted Barrack [$i][0], if not will store '0' on [$i][1]
	; Verify the remain time of Boost barrack , if exceed  the 3600 seconds | 1Hour will reset the variables.
	For $i = 0 To ($numBarracksAvailable - 1)
		Local $LocalTemp = 0

		; if exist a Flag from boostbarrack.au3 and True[=1] after Boosted Check on Barrack
		If $InitBoostTime[$i][0] = 0 And $CheckIfWasBoostedOnBarrack[$i] = 1 Then
			Setlog("Did You Boost the Barrack nº " & $i + 1 & " Manually?", $COLOR_RED)
			VerifyRemainBoostTime($i + 1) ; THIS WILL NOT FLAG 0 to 1 | Forcing To Search again the Time
			openArmyOverview()
		Else
			If $InitBoostTime[$i][0] = 1 Then
				$LocalTemp = Floor(TimerDiff($InitBoostTime[$i][1]) / 1000)
				If $LocalTemp > 3600 Or $LocalTemp < 0 Then
					$InitBoostTime[$i][1] = 0
					$InitBoostTime[$i][0] = 0
				Else
					Local $TEMPInitBoostTime = 3600 - $LocalTemp
					$InitBoostTime[$i][0] = 1
					Setlog(" » Barrack nº " & $i + 1 & " was Boosted | Boost remaining time: " & Sec2Time($TEMPInitBoostTime))
				EndIf
			EndIf
		EndIf
	Next

	; GO TO First NORMAL BARRACK
	; Find First barrack $i

	If IsTrainPage() Then GoesToFirstBarrack()

	; #############################################################################################################################################
	; ###################################################  2nd Stage : Calculating of Troops to Make ##############################################
	; #############################################################################################################################################

	If $debugsetlogTrain = 1 Then SetLog(" » Total ArmyCamp :" & $TotalCamp, $COLOR_PURPLE)

	;SetLog(" » Let's take advantage of Boosted barrack!", $COLOR_GREEN)
	If $debugsetlogTrain = 1 Then SetLog(" » Your Army will be :", $COLOR_GREEN)

	$anotherTroops = 0

	For $i = 0 To UBound($TroopName) - 1
		If Eval($TroopName[$i] & "Comp") > 0 Then
			Assign(("Cur" & $TroopName[$i]), Eval("Cur" & $TroopName[$i]) + Eval($TroopName[$i] & "Comp"))
			If $debugsetlogTrain = 1 And Number($anotherTroops + Eval($TroopName[$i] & "Comp")) <> 0 Then SetLog("-- AnotherTroops to train:" & $anotherTroops & " + " & Eval($TroopName[$i] & "Comp") & "*" & $TroopHeight[$i], $COLOR_PURPLE)
			$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i] ; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected on $TroopComp )
			If Eval("Cur" & $TroopName[$i]) < 0 Then ; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected on $TroopComp )
				$anotherTroops += (Eval("Cur" & $TroopName[$i]) * -1) * $TroopHeight[$i]
			EndIf
			If $debugsetlogTrain = 1 Then SetLog(" » " & Eval("Cur" & $TroopName[$i]) & " " & NameOfTroop(Eval("e" & $TroopName[$i])))
		EndIf
	Next

	For $i = 0 To UBound($TroopDarkName) - 1
		If $icmbDarkTroopComp = 1 And Eval($TroopDarkName[$i] & "Comp") > 0 Then
			$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i]
			If $debugsetlogTrain = 1 Then SetLog(" » " & Eval("Cur" & $TroopDarkName[$i]) & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i])))
		EndIf
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		If Eval("Don" & $TroopDarkName[$i]) > 0 Then
			$anotherTroops += Eval("Don" & $TroopDarkName[$i]) * $TroopHeight[$i]
		EndIf
	Next

	If $debugsetlogTrain = 1 Then SetLog(" » $AnotherTroops TOTAL to train:" & $anotherTroops, $COLOR_PURPLE)

	; #############################################################################################################################################
	; ###################################################  3rd Stage : Allocate Troops on each barrack ############################################
	; ####################################################### make necessary variables to use with ################################################
	; #############################################################################################################################################

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page

	; Verify the Total of house space for the troops to train
	Local $TotalTroopsTOtrain = 0
	For $i = 0 To UBound($TroopName) - 1
		If Eval("Cur" & $TroopName[$i]) > 0 Then
			$TotalTroopsTOtrain += Eval("Cur" & $TroopName[$i]) * $TroopHeight[$i]
		EndIf
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		If Eval("Cur" & $TroopDarkName[$i]) > 0 Then
			$TotalTroopsTOtrain += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i]
		EndIf
	Next

	; Next code will check the total troops to make and the total camp , if is necessary will remove some Arch|Barbs|Goblins to match Existent troops + To train = Total camp space ...
	; Some times on queue we have at 3 more barbs or archers , this happens because the % on Arch|Barbs|Goblins

	SetLog(" » Total Barrack Space to be Train: " & $TotalTroopsTOtrain)
	SetLog(" » Existent Army: " & $CurCamp & " To train : " & $TotalTroopsTOtrain & " | [T]: " & $CurCamp + $TotalTroopsTOtrain)
	If $fullarmy = True Then SetLog(" » Full Army: " & $CurCamp & " To Queue Troops : " & $TotalTroopsTOtrain & " | [T]: " & $CurCamp + $TotalTroopsTOtrain)


	If $CurCamp + $TotalTroopsTOtrain > $TotalCamp Then
		Local $ExceedTroops = ($CurCamp + $TotalTroopsTOtrain) - $TotalCamp
		If Eval("CurGobl") > 0 Then
			Setlog(" » Removing " & $ExceedTroops & " " & NameOfTroop(Eval("eGobl")), $COLOR_RED)
			Assign("CurGobl", Eval("CurGobl") - $ExceedTroops)
			$TotalTroopsTOtrain = $TotalTroopsTOtrain - $ExceedTroops
		ElseIf Eval("CurGobl") <= 0 And Eval("CurBarb") > 0 Then
			Setlog(" » Removing " & $ExceedTroops & " " & NameOfTroop(Eval("eBarb")), $COLOR_RED)
			Assign("CurBarb", Eval("CurBarb") - $ExceedTroops)
			$TotalTroopsTOtrain = $TotalTroopsTOtrain - $ExceedTroops
		ElseIf Eval("CurGobl") <= 0 And Eval("CurBarb") <= 0 And Eval("CurArch") > 0 Then
			Setlog(" » Removing " & $ExceedTroops & " " & NameOfTroop(Eval("eArch")), $COLOR_RED)
			Assign("CurArch", Eval("CurArch") - $ExceedTroops)
			$TotalTroopsTOtrain = $TotalTroopsTOtrain - $ExceedTroops
		EndIf
	EndIf


	; 4D array with all normal troops, from the highest training time for the lowest
	; [0] is the name = of $TroopName|$TroopDarkName
	; [1] is the training time in seconds
	; [2] is the housing space
	; [3] is the quantity to make - > this will be filled with $CurTroop[$i]

	Local $TroopsToMake[12][5] = [ _
			["Pekk", 900, 25, 0, 75], _
			["Drag", 900, 20, 0, 60], _
			["BabyD", 600, 10, 0, 80], _
			["Heal", 600, 14, 0, 45], _
			["Mine", 300, 5, 0, 85], _
			["Ball", 300, 5, 0, 45], _
			["Wiza", 300, 4, 0, 50], _
			["Giant", 120, 5, 0, 30], _
			["Wall", 60, 2, 0, 40], _
			["Gobl", 30, 1, 0, 35], _
			["Arch", 25, 1, 0, 25], _
			["Barb", 20, 1, 0, 20]]


	; Fill the $TroopsToMake[$x][3] with the quantity to make with the existent $Cur[troopName] Global variable
	; NameOfTroop() Returns the string value of the troopname in singular or plural form | NameOfTroop.au3
	For $i = 0 To UBound($TroopName) - 1 ;  Normal troops
		If Eval("Cur" & $TroopName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 11
				If $TroopsToMake[$x][0] = $TroopName[$i] Then
					If $debugsetlogTrain = 1 Then Setlog("$TroopsToMake[$x][0] : " & $TroopsToMake[$x][0] & " | $TroopName[$i]: " & $TroopName[$i])
					$TroopsToMake[$x][3] = Eval("Cur" & $TroopName[$i])
					If $TroopsToMake[$x][3] > 1 Then $plural = 1
					Setlog(" »» Preparing to Train " & $TroopsToMake[$x][3] & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), $plural))
					ExitLoop
				EndIf
				If $RunState = False Then Return
			Next
		EndIf
	Next

	; Fill the Variable with 0 for each max Barracks available or get the correct value from Global variables
	For $i = 0 To ($numBarracksAvailable - 1)
		If $InitBoostTime[$i][0] = 1 Then
			$LocalTemp = Floor(TimerDiff($InitBoostTime[$i][1]) / 1000)
			Local $TEMPInitBoostTime = 3600 - $LocalTemp
			$BarrackTotalStatus[$i][3] = $TEMPInitBoostTime ; Remain Boost Time | from 3600's (1h00) to 0's : time in seconds like the training time
		Else
			$BarrackTotalStatus[$i][3] = $InitBoostTime[$i][1]
		EndIf
		$BarrackTotalStatus[$i][0] = $BarrackTimeRemain[$i] ; training time in seconds
		$BarrackTotalStatus[$i][1] = 0 ; house spacing | Unit Queue Length will have a limit just in case of Boost barracks ***
		$BarrackTotalStatus[$i][2] = $InitBoostTime[$i][0] ; Boosted Barrack? 0 = Force OCR , 1 = TimerInit() | with true training time will divide by 4
		$BarrackTotalStatus[$i][4] = $BarrackCapacity[$i] ; Maximum Unit Queue Length | Barrack level | 75 is a Barrack Lv10 | with pekka
		If $BarrackCapacity[$i] = 0 Then $BarrackTotalStatus[$i][4] = 75 ; In case of any error Reading The Unit Queue Length
	Next

	; Lets verify what Barracks are Boosted and use it first! adding a small time to the no Boosted Barrack
	For $i = 0 To ($numBarracksAvailable - 1)
		If $BarrackTotalStatus[$i][3] = 0 Then
			$BarrackTotalStatus[$i][0] = 20
		EndIf
	Next

	; Variable to assign each troop quantity on each barrack | max Barracks available
	; Local $PekkEBarrack0 , $PekkEBarrack1 , $PekkEBarrack2 , $PekkEBarrack3
	; Making a loop to assign the 0 and forcing the variable declaration on local scope

	For $i = 0 To UBound($TroopsToMake) - 1
		For $x = 0 To ($numBarracksAvailable - 1)
			Assign($TroopsToMake[$i][0] & "EBarrack" & $x, 0, $ASSIGN_FORCELOCAL)
			If $debugsetlogTrain = 1 Then Setlog(" » Declared Local scope: " & $TroopsToMake[$i][0] & "EBarrack" & $x & " = 0")
			If @error Then _logErrorDateDiff(@error)
			If Not IsDeclared($TroopsToMake[$i][0] & "EBarrack" & $x) Then
				Setlog(" » Error creating in local scope the variable: " & Eval($TroopsToMake[$i][0] & "EBarrack" & $x), $COLOR_RED)
			EndIf
		Next
	Next

	Local $BarrackNotAvailableForTheTroop[$numBarracksAvailable]

	For $x = 0 To ($numBarracksAvailable - 1)
		$BarrackNotAvailableForTheTroop[$x] = 0
	Next

	; If is necessary make a troop but is not available in all barracks will proceed with a sort on the $TroopsToMake
	; In descending order Value ($TroopsToMake[$i][4])

	For $i = 0 To 11
		For $x = 0 To ($numBarracksAvailable - 1)
			If $TroopsToMake[$i][3] > 0 And $TroopsToMake[$i][4] > $BarrackCapacity[$x] Then
				Setlog(" » " & NameOfTroop(Eval("e" & $TroopsToMake[$i][0]), $plural) & " are not available on Barrack nº " & $x + 1, $COLOR_RED)
				$LetsSortNB = True
			EndIf
		Next
		If $LetsSortNB = True Then
			_ArraySort($TroopsToMake, 1, 0, 0, 4)
			If @error Then _logErrorDateDiff(@error)
			ExitLoop
		EndIf
	Next

	; ###################################################################################################################################################
	; ############################################################ Barracks Troops distribution #########################################################
	; ################################################################ Main Core - balanced #############################################################
	; ###################################################################################################################################################

	Local $TimeStored[$numBarracksAvailable] ; This will store the correct time on boosted Barrcaks after filled
	For $i = 0 To ($numBarracksAvailable - 1)
		$TimeStored[$i] = 0
	Next

	Local $z = 0, $AreAllFull = 0

	For $i = 0 To UBound($TroopsToMake) - 1 ; From pekka to barbarians | OR  Miner to Barbarian if was Sorted before

		If $TroopsToMake[$i][3] > 0 Then ; if is necessary to train

			$plural = 0
			If $TroopsToMake[$i][3] > 0 Then $plural = 1

			Local $m = 0
			Local $TotalCapacityOfBarracks = 0

			; This will disable the Barracks without this Troop
			For $x = 0 To ($numBarracksAvailable - 1)

				;	Reset the variables from the previous Troop , remember the loop is from Pekka to Barbarians
				; 	$BarrackTotalStatus[$x][1]
				If $BarrackNotAvailableForTheTroop[$x] = 1 And ($BarrackTotalStatus[$x][1] < $BarrackTotalStatus[$x][4]) Then
					If $debugsetlogTrain = 1 Then Setlog(" » | $BarrackNotAvailableForTheTroop[" & $x & "] = 0")
					$BarrackNotAvailableForTheTroop[$x] = 0
					$BarrackTotalStatus[$x][0] -= 10000
					If $debugsetlogTrain = 1 Then Setlog(" » | $BarrackTotalStatus[" & $x & "] was = " & $BarrackTotalStatus[$x][0] + 10000 & " Now = " & $BarrackTotalStatus[$x][0])
				EndIf

				; $TroopsToMake[$i][4]  is the Barrack capacity , represents the Level.
				If $TroopsToMake[$i][4] > $BarrackCapacity[$x] Then
					$BarrackTotalStatus[$x][0] += 10000
					$BarrackNotAvailableForTheTroop[$x] = 1
					If $debugsetlogTrain = 1 Then Setlog(" »»» $BarrackNotAvailableForTheTroop[" & $x & "] = 1")
				Else
					$TotalCapacityOfBarracks += $BarrackCapacity[$x]
					$m += 1
				EndIf
			Next

			; Just a Log remember the user of the quantities do not fit on the barracks
			If $TroopsToMake[$i][3] * $TroopsToMake[$i][2] > $TotalCapacityOfBarracks Then
				Setlog(" » Total of " & $TroopsToMake[$i][3] & " " & NameOfTroop(Eval("e" & $TroopsToMake[$i][0]), $plural) & " don't fit in " & $m & " [NB] in one loop", $COLOR_BLUE)
			EndIf


			; Distribution logically of each troop for each Barrack available and shorter time
			Local $QuantityToMake = $TroopsToMake[$i][3]
			If $debugsetlogTrain = 1 Then Setlog(" » " & NameOfTroop(Eval("e" & $TroopsToMake[$i][0]), $plural) & " Quantity: " & $QuantityToMake)
			Local $BarrackToTrain = 0
			Local $AssignedQuantity = 0

			Do
				$z += 1
				$BarrackToTrain = _ArrayMinIndex($BarrackTotalStatus, 0, -1, -1, 0) ; if all barracks are equal then will return lower index
				If $BarrackTotalStatus[$BarrackToTrain][1] >= $BarrackTotalStatus[$BarrackToTrain][4] Then ; Current Unit Queue and the Max Barrack Unit Queue
					SetLog("Queue Spacing is Full!! on Barrack nº :" & $BarrackToTrain + 1, $COLOR_RED) ; ** flag for boosted barrack !!
					$TimeStored[$BarrackToTrain] = $BarrackTotalStatus[$BarrackToTrain][0]
					$BarrackTotalStatus[$BarrackToTrain][0] += 8000
					; Lets check If all Barrcaks ARE FULL and exit
					$AreAllFull = 0
					For $t = 0 To $numBarracksAvailable - 1
						If $BarrackTotalStatus[$t][1] >= $BarrackTotalStatus[$t][4] Then $AreAllFull += 1
					Next
					If $AreAllFull = $numBarracksAvailable Then ExitLoop (2)
				Else
					Assign($TroopsToMake[$i][0] & "EBarrack" & $BarrackToTrain, Eval($TroopsToMake[$i][0] & "EBarrack" & $BarrackToTrain) + 1) ; assing 1 troop each loop verifying the Barrack time
					$BarrackTotalStatus[$BarrackToTrain][1] += $TroopsToMake[$i][2]
					$AssignedQuantity += 1
					; Check if it is a boosted barrack and if the remain boosted time if higher then remain train troops on that barrack
					If $BarrackTotalStatus[$BarrackToTrain][3] > $BarrackTotalStatus[$BarrackToTrain][0] Then
						$BarrackTotalStatus[$BarrackToTrain][0] += ($TroopsToMake[$i][1] / 4) ; reducing the time required to train this 'one' troop by a factor of four for the duration of the boost.
					Else
						$BarrackTotalStatus[$BarrackToTrain][0] += $TroopsToMake[$i][1]
					EndIf
				EndIf

				If $RunState = False Then Return
				If _Sleep(30) Then Return

				If $AssignedQuantity > $QuantityToMake Then ExitLoop
				If $z = 240 Then ExitLoop (2)
			Until $AssignedQuantity = $QuantityToMake

			For $x = 0 To UBound($BarrackTotalStatus) - 1
				Local $plural = 0
				If Eval($TroopsToMake[$i][0] & "EBarrack" & $x) > 1 Then $plural = 1
				If $debugsetlogTrain = 1 Then Setlog( NameOfTroop(Eval("e" & $TroopsToMake[$i][0]), $plural) & " On Barrack " & $x + 1 & " |Q: " & Eval($TroopsToMake[$i][0] & "EBarrack" & $x) & "| Barrack Space used : " & $BarrackTotalStatus[$x][1] & "|" & $BarrackTotalStatus[$x][4])
			Next
		EndIf
	Next

	; Lets store the last Remain Train Time in a Global Variable to use if is necessary to make Donated Troops

	For $i = 0 To ($numBarracksAvailable - 1)
		If $TimeStored[$i] > 0 Then $BarrackTotalStatus[$i][0] = $TimeStored[$i]
		$BarrackTimeRemain[$i] = $BarrackTotalStatus[$i][0]
	Next

	If $debugsetlogTrain = 1 Then SetLog("--------- END COMPUTE TROOPS TO MAKE ---------", $COLOR_PURPLE)

	; #############################################################################################################################################
	; ###################################################  4th Stage : Train IT Troops on each barrack ############################################
	; #############################################################################################################################################

	; RESET TROOPFIRST AND TROOPSECOND
	; Are the most important functions in this stage!!
	; troopFirst stores the troops quantities when enter on barrack | the current number of training troops | OCR
	; troopSecond stores quantities AFTER train IT, the result Between (troopSecond - troopFirst) will resove it from $Cur'TroopName'

	For $i = 0 To UBound($TroopName) - 1
		Assign(("troopFirst" & $TroopName[$i]), 0)
		Assign(("troopSecond" & $TroopName[$i]), 0)
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		Assign(("troopFirst" & $TroopDarkName[$i]), 0)
		Assign(("troopSecond" & $TroopDarkName[$i]), 0)
	Next

	; First Normal Barrack available | $brrNum = 0
	$brrNum = 0

	; ############################################################################################################################################
	; ############################################################### Train Custom MODE ##########################################################
	; ############################################################################################################################################

	If $debugsetlogTrain = 1 Then SetLog("---------TRAIN NEW CUSTOM MODE-----------", $COLOR_PURPLE)

	While isBarrack() And $isNormalBuild
		$brrNum += 1
		If $debugsetlogTrain = 1 Then SetLog("====== Checking available Barrack: " & $brrNum & " ======", $COLOR_PURPLE)

		;CLICK REMOVE TROOPS
		If _Sleep($iDelayTrain2) Then Return
		$icount = 0
		If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
			While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
				;_PostMessage_ClickDrag(550, 240, 170, 240, "left", 1000)
				ClickDrag(550, 240, 170, 240, 1000)
				$icount += 1
				If _Sleep($iDelayTrain2) Then Return
				If $icount = 7 Then ExitLoop
			WEnd
		EndIf
		$icount = 0
		While Not _ColorCheck(_GetPixelColor(593, 200 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
			If Not (IsTrainPage()) Then Return ;exit if no train page
			Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0284") ; Remove Troops in training
			$icount += 1
			If $RunState = False Then Return
			If $icount = 100 Then ExitLoop
		WEnd
		If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 'not disappears » green arrow'", $COLOR_PURPLE)


		If _Sleep($iDelayTrain1) Then Return

		For $i = 0 To UBound($TroopName) - 1
			If Eval($TroopName[$i] & "Comp") <> "0" Then
				$heightTroop = 294 + $midOffsetY
				$positionTroop = $TroopNamePosition[$i]
				If $TroopNamePosition[$i] > 5 Then
					$heightTroop = 396 + $midOffsetY
					$positionTroop = $TroopNamePosition[$i] - 6
				EndIf
				$tmpNumber = 0
				$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
				If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog("[B" & $brrNum + 1 & "] » ASSIGN $TroopFirst" & $TroopName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
				Assign(("troopFirst" & $TroopName[$i]), $tmpNumber)
				If Eval("troopFirst" & $TroopName[$i]) = 0 Then
					If _Sleep($iDelayTrain1) Then Return
					If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog("[B" & $brrNum + 1 & "] » ASSIGN $TroopFirst" & $TroopName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
					Assign(("troopFirst" & $TroopName[$i]), $tmpNumber)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next

		$BarrackToTrain = $brrNum - 1


		For $i = 0 To UBound($TroopName) - 1
			; Only runs loops on Existing GUI Custom Troops with positive $Cur
			; $Cur|TroopName will be updated forward in the line 670 with $troopSecond|TroopName , removing the quantity troops made in the current barrack
			If Eval("Cur" & $TroopName[$i]) > 0 Then

				If Not (IsTrainPage()) Then Return ;exit from train
				If $RunState = False Then Return ; Bot stops
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

				; loop on all $TroopsToMake to macth the troops name and TrainIT
				For $x = 0 To UBound($TroopsToMake) - 1
					If $TroopsToMake[$x][0] = $TroopName[$i] And Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
						TrainIt(Eval("e" & $TroopsToMake[$x][0]), Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain))
						$BarrackStatus[$BarrackToTrain] = True
						SetLog("[NB" & $BarrackToTrain + 1 & "] » Trained " & Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), 1), $COLOR_GREEN)
					EndIf
				Next
			EndIf
		Next


		; Just a Setlog with each Barrack remain train times
		Setlog("Barrack nº" & $brrNum & " with remain train of " & Sec2Time($BarrackTotalStatus[$BarrackToTrain][0]), $COLOR_GREEN)

		If _Sleep($iDelayTrain1) Then Return
		For $i = 0 To UBound($TroopName) - 1
			If Eval($TroopName[$i] & "Comp") <> "0" Then
				$heightTroop = 294 + $midOffsetY
				$positionTroop = $TroopNamePosition[$i]
				If $TroopNamePosition[$i] > 5 Then
					$heightTroop = 396 + $midOffsetY
					$positionTroop = $TroopNamePosition[$i] - 6
				EndIf
				$tmpNumber = 0
				$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
				If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog(("[B" & $brrNum + 1 & "] » ASSIGN $troopSecond" & $TroopName[$i] & ": " & $tmpNumber), $COLOR_PURPLE)
				Assign(("troopSecond" & $TroopName[$i]), $tmpNumber)
				If Eval("troopSecond" & $TroopName[$i]) = 0 Then
					If _Sleep($iDelayTrain4) Then Return ; just a delay | ocr
					$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
					Assign(("troopSecond" & $TroopName[$i]), $tmpNumber)
					If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog(("[B" & $brrNum + 1 & "] » ASSIGN $troopSecond" & $TroopName[$i] & ": " & $tmpNumber), $COLOR_PURPLE)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next

		; Here will be remove from $Cur'TroopName' the trained troops
		; Possible issues : if the troopfirst was 9 but in one second was trained| finished from queue , will be 8 and you add 1 , will not removed from the $Cur
		; How can we resolve that ? of course 99% of the times the barrack will be empty when procides the tropfirst! but
		For $i = 0 To UBound($TroopName) - 1
			If Eval("troopSecond" & $TroopName[$i]) > Eval("troopFirst" & $TroopName[$i]) And Eval($TroopName[$i] & "Comp") <> "0" Then
				$ArmyComp += (Eval("troopSecond" & $TroopName[$i]) - Eval("troopFirst" & $TroopName[$i])) * $TroopHeight[$i]
				If $debugsetlogTrain = 1 Then SetLog((" » $Cur" & $TroopName[$i]) & " = " & Eval("Cur" & $TroopName[$i]) & " - (" & Eval("troopSecond" & $TroopName[$i]) & " - " & Eval("troopFirst" & $TroopName[$i]) & ")", $COLOR_PURPLE)
				Assign(("Cur" & $TroopName[$i]), Eval("Cur" & $TroopName[$i]) - (Eval("troopSecond" & $TroopName[$i]) - Eval("troopFirst" & $TroopName[$i])))
			EndIf
			If $RunState = False Then Return
		Next


		Local $TroopCapacityAfterTraining = getBarrackArmy(525, 276)
		Local $TotalTime = getBarracksTotalTime(634, 203)

		Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity
		$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
		$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
		$BarrackStatusTrain[2] = $BarrackCapacity[$BarrackToTrain]
		If $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
			$BarrackStatusTrain[3] = $TotalTime[0]
			If $InitBoostTime[$BarrackToTrain][1] > 0 Then
				$BarrackTimeRemain[$BarrackToTrain] = $TotalTime[1] / 4
			Else
				$BarrackTimeRemain[$BarrackToTrain] = $TotalTime[1]
			EndIf
		Else
			$BarrackStatusTrain[3] = 0
			$BarrackTimeRemain[$BarrackToTrain] = 0
		EndIf

		If $InitBoostTime[$BarrackToTrain][1] > 0 Then
			SetLog(" »» NB[" & $BarrackToTrain + 1 & "] Max Queue: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Total Time: " & $BarrackStatusTrain[3] & "s [B]", $COLOR_BLUE)
		Else
			SetLog(" » NB[" & $BarrackToTrain + 1 & "] Max Queue: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Total Time: " & $BarrackStatusTrain[3] & "s", $COLOR_BLUE)

		EndIf


		; Goes to another barrack proceding with the barracks loop
		If Not (IsTrainPage()) Then Return
		If $brrNum >= $numBarracksAvaiables Then ExitLoop ; make sure no more infiniti loop
		_TrainMoveBtn(+1) ;click Next button
		If _Sleep($iDelayTrain2) Then Return
	WEnd

	If $debugsetlogTrain = 1 Then SetLog("---============== END TRAIN =============---", $COLOR_PURPLE)

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page

EndFunc   ;==>TrainNormalTroops

Func getArmyNormalTroopCount()

	If $debugsetlogTrain = 1 Then SETLOG("Begin getArmyNormalTroopCount:", $COLOR_PURPLE)

	Local $FullTemp = ""
	Local $TroopQ = 0
	Local $TroopTypeT = ""

	_CaptureRegion2(120, 165 + $midOffsetY, 740, 220 + $midOffsetY)
	If $debugSetlog = 1 Then SetLog("$hHBitmap2 made", $COLOR_PURPLE)
	If _Sleep($iDelaycheckArmyCamp5) Then Return
	If $debugsetlogTrain = 1 Then SetLog("Calling MBRfunctions.dll/searchIdentifyTroopTrained ", $COLOR_PURPLE)

	$FullTemp = DllCall($hFuncLib, "str", "searchIdentifyTroopTrained", "ptr", $hHBitmap2)
	If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
	If $debugsetlogTrain = 1 Then
		If IsArray($FullTemp) Then
			SetLog("Dll return $FullTemp :" & $FullTemp[0], $COLOR_PURPLE)
		Else
			SetLog("Dll return $FullTemp : ERROR" & $FullTemp, $COLOR_PURPLE)
		EndIf
	EndIf

	If IsArray($FullTemp) Then
		$TroopTypeT = StringSplit($FullTemp[0], "|")
	EndIf

	If $debugsetlogTrain = 1 Then
		If IsArray($TroopTypeT) Then
			SetLog("$Trooptype split # : " & $TroopTypeT[0], $COLOR_PURPLE)
		Else
			SetLog("$Trooptype split # : ERROR " & $TroopTypeT, $COLOR_PURPLE)
		EndIf
	EndIf
	If $debugsetlogTrain = 1 Then SetLog("Start the Loop", $COLOR_PURPLE)


	For $i = 0 To UBound($aDTtroopsToBeUsed, 1) - 1 ; Reset the variables
		$aDTtroopsToBeUsed[$i][1] = 0
	Next

	If IsArray($TroopTypeT) And $TroopTypeT[1] <> "" Then

		For $i = 1 To $TroopTypeT[0]

			$TroopQ = "0"
			If _sleep($iDelaycheckArmyCamp1) Then Return
			Local $Troops = StringSplit($TroopTypeT[$i], "#", $STR_NOCOUNT)
			If $debugsetlogTrain = 1 Then SetLog("$TroopTypeT[$i] split : " & $i, $COLOR_PURPLE)

			If IsArray($Troops) And $Troops[0] <> "" Then

				If $Troops[0] = $eBarb Then
					$TroopQ = $Troops[2]
					$CurBarb = -($TroopQ)
				ElseIf $Troops[0] = $eArch Then
					$TroopQ = $Troops[2]
					$CurArch = -($TroopQ)
				ElseIf $Troops[0] = $eGiant Then
					$TroopQ = $Troops[2]
					$CurGiant = -($TroopQ)
				ElseIf $Troops[0] = $eGobl Then
					$TroopQ = $Troops[2]
					$CurGobl = -($TroopQ)
				ElseIf $Troops[0] = $eWall Then
					$TroopQ = $Troops[2]
					$CurWall = -($TroopQ)
				ElseIf $Troops[0] = $eBall Then
					$TroopQ = $Troops[2]
					$CurBall = -($TroopQ)
				ElseIf $Troops[0] = $eHeal Then
					$TroopQ = $Troops[2]
					$CurHeal = -($TroopQ)
				ElseIf $Troops[0] = $eWiza Then
					$TroopQ = $Troops[2]
					$CurWiza = -($TroopQ)
				ElseIf $Troops[0] = $eDrag Then
					$TroopQ = $Troops[2]
					$CurDrag = -($TroopQ)
				ElseIf $Troops[0] = $ePekk Then
					$TroopQ = $Troops[2]
					$CurPekk = -($TroopQ)
				ElseIf $Troops[0] = $eBabyD Then
					$TroopQ = $Troops[2]
					$CurPekk = -($TroopQ)
				ElseIf $Troops[0] = $eMine Then
					$TroopQ = $Troops[2]
					$CurPekk = -($TroopQ)
				EndIf
				Local $plural = 0
				If $TroopQ > 1 Then $plural = 1
				If $TroopQ <> 0 Then SetLog(" - No. of " & NameOfTroop($Troops[0], $plural) & ": " & $TroopQ)

			EndIf
		Next

	EndIf


	$ArmyComp = $CurCamp


EndFunc   ;==>getArmyNormalTroopCount

Func TrainDarkTroops()

	SetLog("Func TrainDarkTroopsBoosted ", $COLOR_PURPLE) ; If $debugsetlogTrain = 1 Then

	Local $anotherTroops
	Local $tempCounter = 0
	Local $tempElixir = ""
	Local $tempDElixir = ""
	Local $tempElixirSpent = 0
	Local $tempDElixirSpent = 0
	Local $tmpNumber

	Local $numDarkBarracksAvailable = $numDarkBarracksAvaiables
	Local $BarrackDarkTotalStatus[$numDarkBarracksAvailable][5]

	; #############################################################################################################################################
	; ###########################################  1st Stage : Prepare training & Variables & Values ##############################################
	; #############################################################################################################################################

	;OPEN ARMY OVERVIEW WITH NEW BUTTON
	GoesToArmyOverViewWindow()

	If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
		If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
		If IsTrainPage() Then BarracksStatus(False)
	EndIf
	If _Sleep(500) Then Return

	GoesToFirstDarkBarrack()

	If _Sleep(1000) Then Return ; ---> can be made with WaitforPixel()
	If $debugsetlogTrain = 1 Then Setlog("Deleting Queue Troops")

	DeleteQueueDarkTroopsOnBoostedBarracks()

	If _Sleep(200) Then Return ; ---> can be made with WaitforPixel()
	If $debugsetlogTrain = 1 Then Setlog("GoesToArmyOverViewWindow")

	GoesToArmyOverViewWindow()

	If _Sleep(1000) Then Return ; ---> can be made with WaitforPixel()
	If IsTrainPage() Then getArmyDarkTroopCount()

	If _Sleep(250) Then Return ; ---> can be made with WaitforPixel()

	Local $CheckIfWasBoostedOnDarkBarrack[$numDarkBarracksAvailable]
	$CheckIfWasBoostedOnDarkBarrack = CheckBarrackBoost(True, False, False, True)

	For $i = 0 To UBound($CheckIfWasBoostedOnDarkBarrack) - 1
		If $debugsetlogTrain = 1 Then Setlog("$CheckIfWasBoostedOnDarkBarrack[" & $i & "]: " & $CheckIfWasBoostedOnDarkBarrack[$i])
	Next

	If $CheckIfWasBoostedOnDarkBarrack = -1 Then
		Setlog(" » Error on $CheckIfWasBoostedOnDarkBarrack", $COLOR_RED)
		For $i = 0 To UBound($numDarkBarracksAvailable) - 1
			$CheckIfWasBoostedOnDarkBarrack[$i] = 0
		Next
	EndIf

	For $i = 0 To UBound($TroopDarkName) - 1
		Assign("Don" & $TroopDarkName[$i], 0)
	Next

	For $i = 0 To ($numDarkBarracksAvailable - 1)
		Local $LocalTemp = 0

		; if exist a Flag from boostbarrack.au3 and True[=1] after Boosted Check on Barrack
		If $InitBoostTimeDark[$i][0] = 0 And $CheckIfWasBoostedOnDarkBarrack[$i] = 1 Then
			Setlog("Did You Boost the Dark Barrack nº " & $i + 1 & " Manually?", $COLOR_RED)
			VerifyRemainDarkBoostTime($i + 1) ; THIS WILL NOT FLAG 0 to 1 | Forcing To Search again the Time
			openArmyOverview()
			If $InitBoostTimeDark[$i][1] > 0 Then
				If $FirstStart Then Setlog(" » let's disable the 'SmartWait4Train'!")
				If $FirstStart Then Setlog(" » To take advantage of the boost(x4)...")
				If $ichkCloseWaitEnable = 1 Then
					$ichkCloseWaitEnable = 0
					GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
				EndIf
			EndIf
		Else
			If $InitBoostTimeDark[$i][0] = 1 Then
				$LocalTemp = Floor(TimerDiff($InitBoostTimeDark[$i][1]) / 1000)
				If $LocalTemp > 3600 Or $LocalTemp < 0 Then
					$InitBoostTimeDark[$i][1] = 0
					$InitBoostTimeDark[$i][0] = 0
				Else
					Local $TEMPInitBoostTime = 3600 - $LocalTemp
					$InitBoostTimeDark[$i][0] = 1
					Setlog(" » Dark Barrack nº " & $i + 1 & " was Boosted | Boost remaining time: " & Sec2Time($TEMPInitBoostTime))
					If $InitBoostTimeDark[$i][1] > 0 Then
						If $FirstStart Then Setlog(" » let's disable the 'SmartWait4Train'!")
						If $FirstStart Then Setlog(" » To take advantage of the boost(x4)...")
						If $ichkCloseWaitEnable = 1 Then
							$ichkCloseWaitEnable = 0
							GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If $InitBoostTimeDark[$i][0] = 0 And $CheckIfWasBoostedOnDarkBarrack[$i] = 0 Then $InitBoostTimeDark[$i][1] = 0
	Next

	For $i = 0 To UBound($TroopDarkName) - 1
		If $icmbDarkTroopComp = 1 And Eval($TroopDarkName[$i] & "Comp") > 0 Then
			Assign(("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) + Eval($TroopDarkName[$i] & "Comp"))
			If $debugsetlogTrain = 1 Then SetLog(" » " & Eval("Cur" & $TroopDarkName[$i]) & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i])))
		EndIf
	Next

	If IsTrainPage() Then GoesToFirstDarkBarrack()

	Local $DtroopsToMake[7][5] = [ _
			["Lava", 900, 30, 0, 90], _
			["Gole", 900, 30, 0, 70], _
			["Witc", 600, 12, 0, 80], _
			["Bowl", 300, 6, 0, 100], _
			["Valk", 300, 8, 0, 60], _
			["Hogs", 120, 5, 0, 50], _
			["Mini", 45, 2, 0, 40]]

	For $i = 0 To UBound($TroopDarkName) - 1 ; Dark troops
		If Eval("Cur" & $TroopDarkName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 6
				If $DtroopsToMake[$x][0] = $TroopDarkName[$i] Then
					If $debugsetlogTrain = 1 Then Setlog("$TroopsToMake[$x][0] : " & $DtroopsToMake[$x][0] & " | $TroopName[$i]: " & $TroopDarkName[$i])
					$DtroopsToMake[$x][3] = Eval("Cur" & $TroopDarkName[$i])
					If $DtroopsToMake[$x][3] > 1 Then $plural = 1
					Setlog(" »» Preparing to Train " & $DtroopsToMake[$x][3] & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), $plural))
					ExitLoop
				EndIf
				If $RunState = False Then Return
			Next
		EndIf
	Next

	For $i = 0 To ($numDarkBarracksAvailable - 1)
		If $InitBoostTimeDark[$i][0] = 1 Then
			$LocalTemp = Floor(TimerDiff($InitBoostTimeDark[$i][1]) / 1000)
			Local $TEMPInitBoostTime = 3600 - $LocalTemp
			$BarrackDarkTotalStatus[$i][3] = $TEMPInitBoostTime ; Remain Boost Time | from 3600's (1h00) to 0's : time in seconds like the training time
		Else
			$BarrackDarkTotalStatus[$i][3] = $InitBoostTimeDark[$i][1]
		EndIf
		$BarrackDarkTotalStatus[$i][0] = 0 ; training time in seconds
		$BarrackDarkTotalStatus[$i][1] = 0 ; house spacing | Unit Queue Length will have a limit just in case of Boost barracks ***
		$BarrackDarkTotalStatus[$i][2] = $InitBoostTimeDark[$i][0] ;Boosted Barrack? 0 = Force OCR , 1 = TimerInit() | with true training time will divide by 4
		$BarrackDarkTotalStatus[$i][4] = $DarkBarrackCapacity[$i] ; Maximum Unit Queue Length | Barrack level | 75 is a Barrack Lv10 | with pekka
		If $DarkBarrackCapacity[$i] = 0 Then $BarrackDarkTotalStatus[$i][4] = 80 ; In case of any error Reading The Unit Queue Length
	Next

	For $i = 0 To ($numDarkBarracksAvailable - 1)
		$DarkBarrackTimeRemain[$i] = 0
	Next

	; Lets verify what Barracks are Boosted and use it first! adding a small time to the no Boosted Barrack
	For $i = 0 To ($numDarkBarracksAvailable - 1)
		If $BarrackDarkTotalStatus[$i][3] = 0 then
			$BarrackDarkTotalStatus[$i][0] = 20
		EndIf
	Next

	For $i = 0 To UBound($DtroopsToMake) - 1
		For $x = 0 To ($numDarkBarracksAvailable - 1)
			Assign($DtroopsToMake[$i][0] & "EBarrack" & $x, 0, $ASSIGN_FORCELOCAL)
			If $debugsetlogTrain = 1 Then Setlog(" » Declared Local scope: " & $DtroopsToMake[$i][0] & "EBarrack" & $x & " = 0")
			If @error Then _logErrorDateDiff(@error)
			If Not IsDeclared($DtroopsToMake[$i][0] & "EBarrack" & $x) Then
				Setlog(" » Error creating in local scope the variable: " & Eval($DtroopsToMake[$i][0] & "EBarrack" & $x), $COLOR_RED)
			EndIf
		Next
	Next

	Local $BarrackNotAvailableForTheDarkTroop[$numDarkBarracksAvailable]

	For $x = 0 To ($numDarkBarracksAvailable - 1)
		$BarrackNotAvailableForTheDarkTroop[$x] = 0
	Next

	; If is necessary make a troop but is not available in all barracks will proceed with a sort on the $DtroopsToMake
	; In descending order Value ($DtroopsToMake[$i][4])

	For $i = 0 To UBound($DtroopsToMake) - 1
		For $x = 0 To ($numDarkBarracksAvailable - 1)
			If $DtroopsToMake[$i][3] > 0 And $DtroopsToMake[$i][4] > $DarkBarrackCapacity[$x] Then
				Setlog(" » " & NameOfTroop(Eval("e" & $DtroopsToMake[$i][0]), $plural) & " are not available on Dark Barrack nº " & $x + 1, $COLOR_RED)
				$LetsSortNB = True
			EndIf
		Next
		If $LetsSortNB = True Then
			_ArraySort($DtroopsToMake, 1, 0, 0, 4)
			If @error Then _logErrorDateDiff(@error)
			ExitLoop
		EndIf
	Next

	Local $TimeStored[$numDarkBarracksAvailable] ; This will store the correct time on boosted Barrcaks after filled
	For $i = 0 To ($numDarkBarracksAvailable - 1)
		$TimeStored[$i] = 0
	Next

	Local $z = 0, $AreAllFull = 0

	For $i = 0 To UBound($DtroopsToMake) - 1 ; From Lava Hound to Minion

		If $DtroopsToMake[$i][3] > 0 Then ; if is necessary to train

			$plural = 0
			If $DtroopsToMake[$i][3] > 1 Then $plural = 1

			Local $m = 0
			Local $TotalCapacityOfBarracks = 0

			; This will disable the Barracks without this Troop
			For $x = 0 To ($numDarkBarracksAvailable - 1)
				;	Reset the variables from the previous Troop , remember the loop is from Pekka to Barbarians
				; 	$BarrackTotalStatus[$x][1]
				If $BarrackNotAvailableForTheDarkTroop[$x] = 1 And ($BarrackDarkTotalStatus[$x][1] < $BarrackDarkTotalStatus[$x][4]) Then
					If $debugsetlogTrain = 1 Then Setlog(" » | $BarrackNotAvailableForTheDarkTroop[" & $x & "] = 0")
					$BarrackNotAvailableForTheDarkTroop[$x] = 0
					$BarrackDarkTotalStatus[$x][0] -= 10000
					If $debugsetlogTrain = 1 Then Setlog(" » | $BarrackTotalStatus[" & $x & "] was = " & $BarrackDarkTotalStatus[$x][0] + 10000 & " Now = " & $BarrackDarkTotalStatus[$x][0])
				EndIf
				; $TroopsToMake[$i][4]  is the Barrack capacity , represents the Level.
				If $DtroopsToMake[$i][4] > $DarkBarrackCapacity[$x] Then
					$BarrackDarkTotalStatus[$x][0] += 10000
					$BarrackNotAvailableForTheDarkTroop[$x] = 1
					If $debugsetlogTrain = 1 Then Setlog(" »»» $BarrackNotAvailableForTheDarkTroop[" & $x & "] = 1")
				Else
					$TotalCapacityOfBarracks += $DarkBarrackCapacity[$x]
					$m += 1
				EndIf
			Next

			; Just a Log remember the user of the quantities do not fit on the barracks
			If $DtroopsToMake[$i][3] * $DtroopsToMake[$i][2] > $TotalCapacityOfBarracks Then
				Setlog(" » Total of " & $DtroopsToMake[$i][3] & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$i][0]), $plural) & " don't fit in " & $m & " [DB] in one loop", $COLOR_BLUE)
			EndIf

			Local $QuantityToMake = $DtroopsToMake[$i][3]
			If $debugsetlogTrain = 1 Then Setlog(" » " & NameOfTroop(Eval("e" & $DtroopsToMake[$i][0])) & " Quantity: " & $QuantityToMake)
			Local $BarrackToTrain = 0
			Local $AssignedQuantity = 0

			Do
				$z += 1
				$BarrackToTrain = _ArrayMinIndex($BarrackDarkTotalStatus, 0, -1, -1, 0) ; if all barracks are equal then will return lower index
				If $BarrackDarkTotalStatus[$BarrackToTrain][1] >= $BarrackDarkTotalStatus[$BarrackToTrain][4] Then ; Current Unit Queue and the Max Barrack Unit Queue
					SetLog("Queue Spacing is Full!! on Barrack nº :" & $BarrackToTrain + 1, $COLOR_RED) ; *** Need More Work | ** flag for boosted barrack !!
					$TimeStored[$BarrackToTrain] = $BarrackDarkTotalStatus[$BarrackToTrain][0]
					$BarrackDarkTotalStatus[$BarrackToTrain][0] += 2500
					; Lets check If all Barrcaks ARE FULL and exit
					$AreAllFull = 0
					For $t = 0 To $numDarkBarracksAvailable - 1
						If $BarrackDarkTotalStatus[$t][1] >= $BarrackDarkTotalStatus[$t][4] Then $AreAllFull += 1
					Next
					If $AreAllFull = $numDarkBarracksAvailable Then ExitLoop (2)
				Else
					Assign($DtroopsToMake[$i][0] & "EBarrack" & $BarrackToTrain, Eval($DtroopsToMake[$i][0] & "EBarrack" & $BarrackToTrain) + 1) ; assing 1 troop each loop verifying the Barrack time
					$BarrackDarkTotalStatus[$BarrackToTrain][1] += $DtroopsToMake[$i][2]
					$AssignedQuantity += 1
					; Check if it is a boosted barrack and if the remain boosted time if higher then remain train troops on that barrack
					If $BarrackDarkTotalStatus[$BarrackToTrain][3] > $BarrackDarkTotalStatus[$BarrackToTrain][0] Then
						$BarrackDarkTotalStatus[$BarrackToTrain][0] += ($DtroopsToMake[$i][1] / 4) ; reducing the time required to train this 'one' troop by a factor of four for the duration of the boost.
					Else
						$BarrackDarkTotalStatus[$BarrackToTrain][0] += $DtroopsToMake[$i][1]
					EndIf
				EndIf

				If $RunState = False Then Return
				If $AssignedQuantity > $QuantityToMake Then ExitLoop
				If $z = 200 Then ExitLoop (2)
			Until $AssignedQuantity = $QuantityToMake

			For $x = 0 To UBound($BarrackDarkTotalStatus) - 1
				Local $plural = 0
				If Eval($DtroopsToMake[$i][0] & "EBarrack" & $x) > 1 Then $plural = 1
				If $debugsetlogTrain = 1 Then Setlog( NameOfTroop(Eval("e" & $DtroopsToMake[$i][0]), $plural) & " On Dark B. " & $x + 1 & " |Q: " & Eval($DtroopsToMake[$i][0] & "EBarrack" & $x) & "| Barrack Space used : " & $BarrackDarkTotalStatus[$x][1] & "|" & $BarrackDarkTotalStatus[$x][4])
			Next
		EndIf
	Next

	; Lets store the last Remain Train Time in a Global Variable to use if is necessary to make Donated Troops

	For $i = 0 To ($numDarkBarracksAvailable - 1)
		If $TimeStored[$i] > 0 Then $BarrackDarkTotalStatus[$i][0] = $TimeStored[$i]
		$DarkBarrackTimeRemain[$i] = $BarrackDarkTotalStatus[$i][0]
	Next

	For $i = 0 To UBound($TroopDarkName) - 1
		Assign(("troopFirst" & $TroopDarkName[$i]), 0)
		Assign(("troopSecond" & $TroopDarkName[$i]), 0)
	Next

	$brrDarkNum = 0
	While isDarkBarrack()
		$brrDarkNum += 1
		If $debugsetlogTrain = 1 Then SetLog("====== Checking available Dark Barrack: " & $brrDarkNum & " ======", $COLOR_PURPLE)
		If ($fullarmy = True) Or $FirstStart Then ; Delete Troops That is being trained
			$icount = 0
			If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
				While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
					;_PostMessage_ClickDrag(550, 240, 170, 240, "left", 1000)
					ClickDrag(550, 240, 170, 240, 1000)
					$icount += 1
					If _Sleep($iDelayTrain1) Then Return
					If $icount = 7 Then ExitLoop
				WEnd
			EndIf
			$icount = 0
			While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
				If Not (IsTrainPage()) Then Return ;exit if no train page
				Click(568, 177 + $midOffsetY, 10, 0, "#0287") ; Remove Troops in training
				$icount += 1
				If $icount = 100 Then ExitLoop
				If $RunState = False Then Return
			WEnd
			If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 9", $COLOR_PURPLE)
		EndIf

		If _Sleep($iDelayTrain4) Then Return

		For $i = 0 To UBound($TroopDarkName) - 1
			If Eval($TroopDarkName[$i] & "Comp") <> "0" Then
				$heightTroop = 294 + $midOffsetY
				$positionTroop = $TroopDarkNamePosition[$i]
				If $TroopDarkNamePosition[$i] > 4 Then
					$heightTroop = 402 + $midOffsetY
					$positionTroop = $TroopDarkNamePosition[$i] - 5
				EndIf
				$tmpNumber = 0
				;read troops in windows troopsfirst
				If _Sleep($iDelayTrain1) Then Return
				$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop)) ; read troop quantity
				If _Sleep($iDelayTrain1) Then Return
				If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog("ASSIGN $TroopFirst" & $TroopDarkName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
				Assign(("troopFirst" & $TroopDarkName[$i]), $tmpNumber)
				If IsNumber(Eval("troopFirst" & $TroopDarkName[$i])) = 0 Then
					If _Sleep($iDelayTrain4) Then Return ; just a delay | ocr
					$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop)) ; read troop quantity
					If $debugsetlogTrain = 1 Then SetLog("ASSIGN $TroopFirst" & $TroopDarkName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
					Assign(("troopFirst" & $TroopDarkName[$i]), $tmpNumber)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next

		Local $BarrackToTrain = $brrDarkNum - 1

		For $i = 0 To UBound($TroopDarkName) - 1
			Local $plural = 0
			; Only runs loops on Existing GUI Custom Troops with positive $Cur
			; $Cur|TroopName will be updated forward in the line 670 with $troopSecond|TroopName , removing the quantity troops made in the current barrack
			If Eval("Cur" & $TroopDarkName[$i]) > 0 Then

				If Not (IsTrainPage()) Then Return ;exit from train
				If $RunState = False Then Return ; Bot stops
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

				; loop on all $TroopsToMake to macth the troops name and TrainIT
				For $x = 0 To UBound($DtroopsToMake) - 1
					If $DtroopsToMake[$x][0] = $TroopDarkName[$i] And Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
						TrainIt(Eval("e" & $DtroopsToMake[$x][0]), Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain))
						$BarrackDarkStatus[$BarrackToTrain] = True
						If Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 1 Then $plural = 1
						SetLog("[DB" & $BarrackToTrain + 1 & "] » Trained " & Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), $plural), $COLOR_GREEN)
					EndIf
				Next
			EndIf
		Next
		Setlog("Dark Barrack nº" & $BarrackToTrain + 1 & " with remain train of " & Sec2Time($BarrackDarkTotalStatus[$BarrackToTrain][0]), $COLOR_GREEN)

		If _Sleep($iDelayTrain4) Then Return
		For $i = 0 To UBound($TroopDarkName) - 1
			If Eval($TroopDarkName[$i] & "Comp") <> "0" Then
				$heightTroop = 294 + $midOffsetY
				$positionTroop = $TroopDarkNamePosition[$i]
				If $TroopDarkNamePosition[$i] > 4 Then
					$heightTroop = 402 + $midOffsetY
					$positionTroop = $TroopDarkNamePosition[$i] - 5
				EndIf
				If _Sleep($iDelayTrain1) Then Return
				$tmpNumber = 0
				$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop))
				If _Sleep($iDelayTrain1) Then Return
				If $debugsetlogTrain = 1 Then SetLog(" » ASSIGN $troopSecond" & $TroopDarkName[$i] & " = " & $tmpNumber, $COLOR_PURPLE)
				Assign(("troopSecond" & $TroopDarkName[$i]), $tmpNumber)
				If IsNumber(Eval("troopSecond" & $TroopDarkName[$i])) = 0 Then
					If _Sleep($iDelayTrain4) Then Return ; just a delay | ocr
					$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop))
					If $debugsetlogTrain = 1 Then SetLog(" » ASSIGN $troopSecond" & $TroopDarkName[$i] & " = " & $tmpNumber, $COLOR_PURPLE)
					Assign(("troopSecond" & $TroopDarkName[$i]), $tmpNumber)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next
		For $i = 0 To UBound($TroopDarkName) - 1
			If Eval("troopSecond" & $TroopDarkName[$i]) > Eval("troopFirst" & $TroopDarkName[$i]) And Eval($TroopDarkName[$i] & "Comp") <> "0" Then
				$ArmyComp += (Eval("troopSecond" & $TroopDarkName[$i]) - Eval("troopFirst" & $TroopDarkName[$i])) * $TroopDarkHeight[$i]
				If $debugsetlogTrain = 1 Then SetLog(" » ASSIGN after $troopSecond - $Cur" & $TroopDarkName[$i] & " = " & Eval("Cur" & $TroopDarkName[$i]) & " - (" & Eval("troopSecond" & $TroopDarkName[$i]) & " - " & Eval("troopFirst" & $TroopDarkName[$i]) & ")", $COLOR_PURPLE)
				Assign(("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) - (Eval("troopSecond" & $TroopDarkName[$i]) - Eval("troopFirst" & $TroopDarkName[$i])))
				If $debugsetlogTrain = 1 Then
					SetLog("**** " & "txtNum" & $TroopDarkName[$i] & "=" & Eval($TroopDarkName[$i] & "Comp"), $COLOR_PURPLE)
					SetLog("**** " & "Cur" & $TroopDarkName[$i] & "=" & Eval("Cur" & $TroopDarkName[$i]), $COLOR_PURPLE)
				EndIf
				If Eval("Cur" & $TroopDarkName[$i]) = 0 Then Setlog(" » The " & NameOfTroop(Eval("e" & $TroopDarkName[$i]), 1) & " are all done!", $COLOR_GREEN)
			EndIf
		Next
		Local $TroopCapacityAfterTraining = getBarrackArmy(525, 276)
		Local $TotalTime = getBarracksTotalTime(634, 203)

		Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity
		$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
		$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
		$BarrackStatusTrain[2] = $DarkBarrackCapacity[$brrDarkNum - 1]
		If $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
			$BarrackStatusTrain[3] = $TotalTime[0]
			If $InitBoostTimeDark[$brrDarkNum - 1][1] > 0 Then
				$DarkBarrackTimeRemain[$brrDarkNum - 1] = $TotalTime[1] / 4
			Else
				$DarkBarrackTimeRemain[$brrDarkNum - 1] = $TotalTime[1]
			EndIf
		Else
			$BarrackStatusTrain[3] = 0
			$DarkBarrackTimeRemain[$brrDarkNum - 1] = 0
		EndIf

		If $InitBoostTimeDark[$brrDarkNum - 1][1] > 0 Then
			SetLog(" »» DB[" & $brrDarkNum & "] Max Queue: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Total Time: " & $BarrackStatusTrain[3] & "s [B]", $COLOR_BLUE)
		Else
			SetLog(" » DB[" & $brrDarkNum & "] Max Queue: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Total Time: " & $BarrackStatusTrain[3] & "s", $COLOR_BLUE)
		EndIf

		If Not (IsTrainPage()) Then Return
		$icount = 0
		If $brrDarkNum >= $numDarkBarracksAvaiables Then ExitLoop ; make sure no more infiniti loop
		_TrainMoveBtn(+1) ;click Next button
		If _Sleep($iDelayTrain2) Then Return
	WEnd

	If $debugsetlogTrain = 1 Then SetLog("---============== END TRAIN =============---", $COLOR_PURPLE)

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page
	$fullarmy = False

EndFunc   ;==>TrainDarkTroopsBoosted

Func getArmyDarkTroopCount()

	If $debugsetlogTrain = 1 Then SETLOG("Begin getArmyDarkTroopCount:", $COLOR_PURPLE)

	Local $FullTemp = ""
	Local $TroopQ = 0
	Local $TroopTypeT = ""

	_CaptureRegion2(120, 165 + $midOffsetY, 740, 220 + $midOffsetY)
	If $debugSetlog = 1 Then SetLog("$hHBitmap2 made", $COLOR_PURPLE)
	If _Sleep($iDelaycheckArmyCamp5) Then Return
	If $debugsetlogTrain = 1 Then SetLog("Calling MBRfunctions.dll/searchIdentifyTroopTrained ", $COLOR_PURPLE)

	$FullTemp = DllCall($hFuncLib, "str", "searchIdentifyTroopTrained", "ptr", $hHBitmap2)
	If _Sleep($iDelaycheckArmyCamp6) Then Return ; 10ms improve pause button response
	If $debugsetlogTrain = 1 Then
		If IsArray($FullTemp) Then
			SetLog("Dll return $FullTemp :" & $FullTemp[0], $COLOR_PURPLE)
		Else
			SetLog("Dll return $FullTemp : ERROR" & $FullTemp, $COLOR_PURPLE)
		EndIf
	EndIf

	If IsArray($FullTemp) Then
		$TroopTypeT = StringSplit($FullTemp[0], "|")
	EndIf

	If $debugsetlogTrain = 1 Then
		If IsArray($TroopTypeT) Then
			SetLog("$Trooptype split # : " & $TroopTypeT[0], $COLOR_PURPLE)
		Else
			SetLog("$Trooptype split # : ERROR " & $TroopTypeT, $COLOR_PURPLE)
		EndIf
	EndIf
	If $debugsetlogTrain = 1 Then SetLog("Start the Loop", $COLOR_PURPLE)

	If IsArray($TroopTypeT) And $TroopTypeT[1] <> "" Then
		For $i = 1 To $TroopTypeT[0]
			$TroopQ = 0
			If _sleep($iDelaycheckArmyCamp1) Then Return
			Local $Troops = StringSplit($TroopTypeT[$i], "#", $STR_NOCOUNT)
			If $debugsetlogTrain = 1 Then SetLog("$TroopTypeT[$i] split : " & $i, $COLOR_PURPLE)

			; THIS IS IMPORTANT $CUR += -(x) Because the $CUR is not empty ( because of the Troop on Queued not removed)

			If IsArray($Troops) And $Troops[0] <> "" Then
				If $Troops[0] = $eMini Then
					$TroopQ = $Troops[2]
					$CurMini += -($TroopQ)
				ElseIf $Troops[0] = $eHogs Then
					$TroopQ = $Troops[2]
					$CurHogs += -($TroopQ)
				ElseIf $Troops[0] = $eValk Then
					$TroopQ = $Troops[2]
					$CurValk += -($TroopQ)
				ElseIf $Troops[0] = $eGole Then
					$TroopQ = $Troops[2]
					$CurGole += -($TroopQ)
				ElseIf $Troops[0] = $eWitc Then
					$TroopQ = $Troops[2]
					$CurWitc += -($TroopQ)
				ElseIf $Troops[0] = $eLava Then
					$TroopQ = $Troops[2]
					$CurLava += -($TroopQ)
				ElseIf $Troops[0] = $eBowl Then
					$TroopQ = $Troops[2]
					$CurBowl += -($TroopQ)
				EndIf
				Local $plural = 0
				If $TroopQ > 1 Then $plural = 1
				If $TroopQ <> 0 Then SetLog(" - No. of " & NameOfTroop($Troops[0], $plural) & ": " & $TroopQ)
			EndIf
		Next
	EndIf

	$ArmyComp = $CurCamp

EndFunc   ;==>getArmyDarkTroopCount

Func DeleteQueueDarkTroopsOnBoostedBarracks()

	SetLog(" »» Checking Queued Dark Troops!!", $COLOR_PURPLE)

	; We need the training times for each troop
	Local $DtroopsToMake[7][4] = [ _
			["Lava", 900, 30, 0], _
			["Gole", 900, 30, 0], _
			["Witc", 600, 12, 0], _
			["Bowl", 300, 6, 0], _
			["Valk", 300, 8, 0], _
			["Hogs", 120, 5, 0], _
			["Mini", 45, 2, 0]]

	; Let's reset the $Cur , we will store that later
	For $i = 0 To UBound($TroopDarkName) - 1
		If $debugsetlogTrain = 1 Then SetLog("Reset the $Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
		Assign("Cur" & $TroopDarkName[$i], 0)
	Next

	; Let's reset the OCR variables
	For $i = 0 To UBound($TroopDarkName) - 1
		Assign(("troopFirst" & $TroopDarkName[$i]), 0)
		Assign(("troopSecond" & $TroopDarkName[$i]), 0)
	Next

	Local $iBarrHere = 0
	$brrDarkNum = 0

	; A routine to go for the first Dark barrcak Available
	While isDarkBarrack() = False
		If Not (IsTrainPage()) Then Return
		_TrainMoveBtn(+1) ;click Next button
		$iBarrHere += 1
		If _Sleep($iDelayTrain3) Then Return
		If (isDarkBarrack() Or $iBarrHere = 8) Then ExitLoop
	WEnd

	; The loop on Dark barracks
	While isDarkBarrack()

		If _Sleep(700) Then Return

		$brrDarkNum += 1
		$BarrackDarkStatus[$brrDarkNum - 1] = False
		If $debugsetlogTrain = 1 Then SetLog(" » Checking available Dark Barrack: " & $brrDarkNum, $COLOR_PURPLE)

		; Delete Troops That is being trained
		$icount = 0
		If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
			While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
				;_PostMessage_ClickDrag(550, 240, 170, 240, "left", 1000)
				ClickDrag(550, 240, 170, 240, 1000)
				$icount += 1
				If _Sleep($iDelayTrain1) Then Return
				If $icount = 7 Then ExitLoop
			WEnd
			While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
				If Not (IsTrainPage()) Then Return ;exit if no train page
				SetLog(" »» Deleting Queued Dark Troops!!", $COLOR_PURPLE)
				Click(568, 177 + $midOffsetY, 10, 0, "#0287") ; Remove Troops in training
				$icount += 1
				If $icount = 100 Then ExitLoop
				If $RunState = False Then Return
			WEnd

		Else
			$DarkBarrackCapacity[$brrDarkNum - 1] = getBarrackCapacity(218, 177)
			SetLog(" » Dark Barrack nº " & $brrDarkNum & " Max Capacity is: " & $DarkBarrackCapacity[$brrDarkNum - 1], $COLOR_GREEN)

			Local $BarrackStatusTrain[2] ; [0]Total Army capacity , [1] Total Time
			$BarrackStatusTrain[0] = $DarkBarrackCapacity[$brrDarkNum - 1]

			Local $TotalTime = getBarracksTotalTime(634, 203)

			If $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
				$BarrackStatusTrain[1] = $TotalTime[0]
				If $InitBoostTimeDark[$brrDarkNum - 1][1] > 0 Then
					$DarkBarrackTimeRemain[$brrDarkNum - 1] = $TotalTime[1] / 4
				Else
					$DarkBarrackTimeRemain[$brrDarkNum - 1] = $TotalTime[1]
				EndIf
			Else
				$DarkBarrackTimeRemain[$brrDarkNum - 1] = 0
			EndIf

			Local $MoreThenOneTroopSlot = 0 ; Exist only one troop kind or more?

			; This part is important , will check the troops quantities and times, check IF any is finishing and don't delete it ...
			; We will not waste XX minutes - like a golem and delete it when is finishing.....
			For $i = 0 To UBound($TroopDarkName) - 1
				If Eval($TroopDarkName[$i] & "Comp") <> "0" Then
					$heightTroop = 294 + $midOffsetY
					$positionTroop = $TroopDarkNamePosition[$i]
					If $TroopDarkNamePosition[$i] > 4 Then
						$heightTroop = 402 + $midOffsetY
						$positionTroop = $TroopDarkNamePosition[$i] - 5
					EndIf
					$tmpNumber = 0
					;read troops in windows troopsfirst
					If _Sleep($iDelayTrain1) Then Return
					$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop)) ; read troop quantity
					If _Sleep($iDelayTrain1) Then Return
					Assign(("troopFirst" & $TroopDarkName[$i]), $tmpNumber)

					If $tmpNumber > 0 Then
						$MoreThenOneTroopSlot += 1
					EndIf
				EndIf
			Next

			If $MoreThenOneTroopSlot = 0 Then Click(568, 177 + $midOffsetY, 20, 0, "#0287") ; Remove Troops in training | Slot 1 | click is just incase

			If $MoreThenOneTroopSlot > 1 Then
				Click(494, 177 + $midOffsetY, 10, 0, "#0287") ; Remove Troops in training | SLOT > 2 | will remain only troops kind on slot 1
				;read again the troops
				$MoreThenOneTroopSlot = 1
			EndIf

			If $MoreThenOneTroopSlot = 1 Then
				For $i = 0 To UBound($TroopDarkName) - 1
					For $x = 0 To UBound($DtroopsToMake) - 1
						If $DtroopsToMake[$x][0] = $TroopDarkName[$i] Then
							; Let's see the remain time of the troop in slot 1
							Local $Temp = $TotalTime[1] - ($DtroopsToMake[$x][1] * Eval("troopFirst" & $TroopDarkName[$i]) - 1)
							If $Temp >= ($DtroopsToMake[$x][0] / 3) * 2 Then ; the remain time is not less than 1/3 , we can remove all
								Click(568, 177 + $midOffsetY, 20, 0, "#0287") ; Remove all Troops in training | Slot 1
							Else
								; Let's remove the unnecessary troops from queued troops and will stay just one the almost prepared troop
								Local $plural = 0
								If $tmpNumber - 1 > 1 Then $plural = 1
								Setlog(" » Just removing " & (Eval("troopFirst" & $TroopDarkName[$i]) - 1) & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i]), $plural))
								Setlog(" »» The other is almost finishing!")
								Click(568, 177 + $midOffsetY, (Eval("troopFirst" & $TroopDarkName[$i]) - 1), 300, "#0287") ; Remove Troops in training | Slot 1 | less one , the almost finished troop
								Assign(Eval("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) - 1)
								Assign("Cur" & $TroopDarkName[$i], Eval("Cur" & $TroopDarkName[$i])) ; lets assign the 1 troop remaining on train
							EndIf
						EndIf
					Next
				Next
			EndIf
		EndIf
		If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 9", $COLOR_PURPLE)

		If $brrDarkNum >= $numDarkBarracksAvaiables Then Return ; make sure no more infiniti loop
		_TrainMoveBtn(+1) ;click Next button
		If _Sleep($iDelayTrain2) Then Return
	WEnd

EndFunc   ;==>DeleteQueueDarkTroopsOnBoostedBarracks

Func GoesToFirstDarkBarrack()

	If IsTrainPage() Then
		; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
		If $Trainavailable[5] = 1 Then
			Click($btnpos[5][0], $btnpos[5][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
			If _Sleep(1000) Then Return
		Else
			Click($btnpos[6][6], $btnpos[5][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
			If _Sleep(1000) Then Return
		EndIf
	Else
		Setlog(" ERROR YOU ARE NOT IN TRAIN PAGE!!!", $COLOR_RED)
	EndIf

EndFunc   ;==>GoesToFirstDarkBarrack

