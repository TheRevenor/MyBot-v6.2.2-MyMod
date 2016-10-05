; #FUNCTION# ====================================================================================================================
; Name ..........: Train
; Description ...: Train the troops (Fill the barracks), Uses the location of manually set Barracks to train specified troops
; Syntax ........: Train()
; Parameters ....:
; Return values .: None
; Author ........: Hungle (2014)
; Modified ......: ProMac and MR.Viper ( 09-2016 )
; Remarks .......:
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $IsDontRemove = 0

Func Train() ; Main Train Loop on Normal and Dark Barracks

	If $debugsetlogTrain = 1 Then SetLog("Func Train ", $COLOR_PURPLE)

	Local $anotherTroops
	Local $tempCounter = 0
	Local $tempElixir = ""
	Local $tempDElixir = ""
	Local $tempElixirSpent = 0
	Local $tempDElixirSpent = 0
	Local $tmpNumber
	Local $QuantNormalTroopsInQueue[4] = [0, 0, 0, 0]
	Local $QuantDarkTroopsInQueue[2] = [0, 0]

	If $bTrainEnabled = False Then Return

	; Read Resource Values For army cost Stats
	VillageReport(True, True)
	$tempCounter = 0
	While ($iElixirCurrent = "" Or ($iDarkCurrent = "" And $iDarkStart <> "")) And $tempCounter < 5
		$tempCounter += 1
		If _Sleep(100) Then Return
		VillageReport(True, True)
	WEnd
	$tempElixir = $iElixirCurrent
	$tempDElixir = $iDarkCurrent

	; in halt attack mode Make sure army reach 100% regardless of user Percentage of full army
	If ($CommandStop = 3 Or $CommandStop = 0) Then
		CheckOverviewFullArmy(True, False)
		If $fullarmy And $bFullArmySpells Then
			SetLog("You are in halt attack mode and your Army is prepared!", $COLOR_PURPLE)
			If $FirstStart Then $FirstStart = False
			Return
		EndIf
	EndIf

	; #############################################################################################################################################
	; ###########################################  1st Stage : Prepare training & Variables & Values ##############################################
	; #############################################################################################################################################

	; Reset variables $Cur+TroopName ( used to assign the quantity of troops to train and existent in armycamp)
	; Only reset if the Last attacks was a TH Snipes or First Start.
	; Global $Cur+TroopName = 0

	If $FirstStart Or ($iTScheck = 1 And $iMatchMode = $TS) Then
		For $i = 0 To UBound($TroopName) - 1
			If $debugsetlogTrain = 1 Then SetLog("Reset the $Cur" & $TroopName[$i], $COLOR_PURPLE)
			Assign("Cur" & $TroopName[$i], 0)
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		Next

		For $i = 0 To UBound($TroopDarkName) - 1
			If $debugsetlogTrain = 1 Then SetLog("Reset the $Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
			Assign("Cur" & $TroopDarkName[$i], 0)
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		Next
	EndIf

	For $i = 0 To UBound($TroopName) - 1
		Assign(("tooMany" & $TroopName[$i]), 0)
		Assign(("tooFew" & $TroopName[$i]), 0)
		If $debugsetlogTrain = 1 Then SetLog("Reset the $tooMany" & $TroopName[$i] & " and $tooFew" & $TroopName[$i], $COLOR_PURPLE)
		If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
	Next

	For $i = 0 To UBound($TroopDarkName) - 1
		Assign(("tooMany" & $TroopDarkName[$i]), 0)
		Assign(("tooFew" & $TroopDarkName[$i]), 0)
		If $debugsetlogTrain = 1 Then SetLog("Reset the $tooMany" & $TroopDarkName[$i] & " and $tooFew" & $TroopDarkName[$i], $COLOR_PURPLE)
		If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
	Next

	; Is necessary Check Total Army Camp and existent troops inside of ArmyCamp
	; $icmbTroopComp - variable used to differentiate the Troops Composition selected in GUI
	; Inside of checkArmyCamp exists:
	; $CurCamp - quantity of troops existing in ArmyCamp  / $TotalCamp - your total troops capacity
	; BarracksStatus() - Verifying how many barracks / spells factory exists and if are available to use.
	; $numBarracksAvaiables returns to be used as the divisor to assign the amount of kind troops each barracks | $TroopName+EBarrack
	;

	SetLog("Training Troops & Spells", $COLOR_BLUE)
	If _Sleep($iDelayTrain1) Then Return

	If Not ($CommandStop = 3 Or $CommandStop = 0) Then
		ClickP($aAway, 1, 0, "#0268") ;Click Away to clear open windows in case user interupted
		If _Sleep($iDelayTrain3) Then Return

		;OPEN ARMY OVERVIEW WITH NEW BUTTON
		If openArmyOverview() = False Then Return ;
	EndIf

	If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
		If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
		If IsTrainPage() Then BarracksStatus(False)
	EndIf
	If _Sleep($iDelayTrain1) Then Return

	; Will Delete the queue Troops on Barrcaks and next will check the Army Camp
	; If the Num of Barracks checked on Line 99 is diff | example a barrack finished upgrading and now is available!
	; will proced with a new Redim and Check the Capacities!
	If $FirstStart Or ($numBarracksAvaiables <> UBound($BarrackCapacity)) Or ($numDarkBarracksAvaiables <> UBound($DarkBarrackCapacity)) Then

		If ($numBarracksAvaiables <> UBound($BarrackCapacity)) Or ($numDarkBarracksAvaiables <> UBound($DarkBarrackCapacity)) Then
			ResetBarracksvariables(False)
		EndIf

		GoesToArmyOverViewWindow()

		If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
		If IsTrainPage() Then checkArmyCamp()
		If $CurCamp = 0 Then ; In case Of fail
			ClickP($aAway, 2, 0, "#0268") ;Click Away to clear open windows in case user interupted
			If _Sleep($iDelayTrain3) Then Return
			openArmyOverview()
			If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
				If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
				If IsTrainPage() Then checkArmyCamp()
			EndIf
		EndIf

		; Let see if the barracks are capable to make the troop in one Loop !!!
		Local $TempTotalcapacity = 0

		For $i = 0 To $numBarracksAvaiables - 1
			$TempTotalcapacity += $BarrackCapacity[$i]
		Next

		For $i = 0 To $numDarkBarracksAvaiables - 1
			$TempTotalcapacity += $DarkBarrackCapacity[$i]
		Next

		If $TempTotalcapacity < $TotalCamp Then
			Setlog("Barracks capacities are lower than your Army camp!!", $COLOR_RED)
			Setlog("Total Barracks capacity: " & $TempTotalcapacity & " | Army Camp: " & $ArmyComp)
			Setlog("Necessary make the Army in several train loops!!")
		EndIf

		; First Start and you have Full army, lets proceed to Spells/Heroes and don't train nothing
		If $fullarmy = True And $FirstStart = True Then
			$FirstStart = False
			For $i = 0 To UBound($TroopName) - 1
				Assign("Cur" & $TroopName[$i], 0)
			Next
			For $i = 0 To UBound($TroopDarkName) - 1
				Assign("Cur" & $TroopDarkName[$i], 0)
			Next
			$ArmyComp = $CurCamp
		Else
			$FirstStart = True
		EndIf

	Else
		If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
			If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
			If IsTrainPage() Then checkArmyCamp()
		EndIf
	EndIf

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page
	DebugTrainSystem("Initial Train routine .... ")

	; Verify the Global variable $TroopName+Comp and return the GUI selected troops by user
	;
	If $isNormalBuild = "" Or $FirstStart Then
		For $i = 0 To UBound($TroopName) - 1
			If Eval($TroopName[$i] & "Comp") <> "0" Then
				$isNormalBuild = True
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			EndIf
		Next
	EndIf
	If $isNormalBuild = "" Then
		$isNormalBuild = False
	EndIf
	If $debugsetlogTrain = 1 Then SetLog(" » Is it necessary to make normal Troops: " & $isNormalBuild, $COLOR_PURPLE)

	; Verify the Global variable $TroopDarkName+Comp and return the GUI selected troops by user
	;
	If $isDarkBuild = "" Or $FirstStart Then
		For $i = 0 To UBound($TroopDarkName) - 1
			If Eval($TroopDarkName[$i] & "Comp") <> "0" Then
				$isDarkBuild = True
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			EndIf
		Next
	EndIf
	If $isDarkBuild = "" Or $icmbDarkTroopComp = 2 Then
		$isDarkBuild = False
	EndIf
	If $debugsetlogTrain = 1 Then SetLog(" » Is it necessary to make Dark Troops: " & $isNormalBuild, $COLOR_PURPLE)

	; ################################################################################################################################
	; Lets check if is Fullarmy and all conditionals are OK to proceed with a new army | in case of false only train the donated troops
	; ################################################################################################################################
	$IsFullArmywithHeroesAndSpells = BitAND($fullarmy, BitOR(IsSearchModeActive($DB), IsSearchModeActive($TS), IsSearchModeActive($LB)))
	If $debugsetlogTrain = 1 Then Setlog("IsSearchModeActive($DB): " & IsSearchModeActive($DB))
	If $debugsetlogTrain = 1 Then Setlog("IsSearchModeActive($LB): " & IsSearchModeActive($LB))
	If $debugsetlogTrain = 1 Then Setlog("IsSearchModeActive($TS): " & IsSearchModeActive($TS))
	If $debugsetlogTrain = 1 Then Setlog("$IsFullArmywithHeroesAndSpells: " & $IsFullArmywithHeroesAndSpells)

	If _Sleep($iDelayTrain1) Then Return ; wait for window to open
	If Not (IsTrainPage()) Then Return ; exit if I'm not in train page
	If $RunState = False Then Return

	; PREPARE TROOPS IF FULL ARMY
	; Barracks status to false , after the first loop and train Selected Troops composition = True
	;
	If $debugsetlogTrain = 1 Then Setlog(" » $Fullarmy = " & $fullarmy & " |$CurCamp = " & $CurCamp & " |$TotalCamp = " & $TotalCamp, $COLOR_PURPLE)
	If $IsFullArmywithHeroesAndSpells = True Then
		$BarrackStatus[0] = False
		$BarrackStatus[1] = False
		$BarrackStatus[2] = False
		$BarrackStatus[3] = False
		$BarrackDarkStatus[0] = False
		$BarrackDarkStatus[1] = False
		SetLog(" » Your Army Composition is now Full", $COLOR_BLUE)
		If ($PushBulletEnabled = 1 Or $TelegramEnabled = 1) And $ichkAlertPBCampFull = 1 Then PushMsgToPushBullet("CampFull")
	EndIf

	; If is fullArmy or FirstStart the $Cur will Store the correct troops - necessary troops to make. Or we are using the Barracks modes is not necessary
	; count/make the donated troops. Reset the Donate variable to 0
	If $IsFullArmywithHeroesAndSpells = True Or $FirstStart = True Or $icmbTroopComp = 8 Then
		$LetsSortNB = False
		For $i = 0 To UBound($TroopName) - 1
			Assign("Don" & $TroopName[$i], 0)
			If $RunState = False Then Return
		Next
	EndIf
	If $IsFullArmywithHeroesAndSpells = True Or $FirstStart = True Or $icmbDarkTroopComp = 0 Then
		$LetsSortDB = False
		For $i = 0 To UBound($TroopDarkName) - 1
			Assign("Don" & $TroopDarkName[$i], 0)
			If $RunState = False Then Return
		Next
	EndIf

	; ###################################################################################################################################################
	; ############################################################### Barrack Total status ##############################################################
	; ################################################################# Assign variables ################################################################
	; ############################################################## Check Boosted barracks #############################################################
	; ############################################################### Boost remaining Time ##############################################################
	; ###################################################################################################################################################

	Local $numBarracksAvailable = $numBarracksAvaiables ; Avaiables | misspelling
	Local $numDarkBarracksAvailable = $numDarkBarracksAvaiables ; Avaiables | misspelling

	; Array with the total training time of each Barrack | Current house spacing | If it is Boosted Barrack | Remain Boosted time | Max Unit Queue Length

	Local $BarrackTotalStatus[$numBarracksAvailable][5]
	Local $BarrackDarkTotalStatus[$numDarkBarracksAvailable][5]

	If $debugsetlogTrain = 1 Then Setlog(" » Num Barracks Available : " & $numBarracksAvailable)
	If $debugsetlogTrain = 1 Then Setlog(" » Declared Local Scope : $BarrackTotalStatus[" & UBound($BarrackTotalStatus) & "][5]")
	If $debugsetlogTrain = 1 Then Setlog(" » Num Dark Barracks Available : " & $numDarkBarracksAvailable)
	If $debugsetlogTrain = 1 Then Setlog(" » Declared Local Scope : $BarrackDarkTotalStatus[" & UBound($BarrackDarkTotalStatus) & "][5]")


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

	ReDim $CheckIfWasBoostedOnDarkBarrack[$numDarkBarracksAvailable]

	If $icmbDarkTroopComp <> 2 Then
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
	EndIf

	; Verify is Exist a Boosted Barrack [$i][0], if not will store '0' on [$i][1]
	; Verify the remain time of Boost barrack , if exceed  the 3600 seconds | 1Hour will reset the variables.
	For $i = 0 To ($numBarracksAvailable - 1)
		Local $LocalTemp = 0

		; if exist a Flag from boostbarrack.au3 and True[=1] after Boosted Check on Barrack
		If $InitBoostTime[$i][0] = 0 And $CheckIfWasBoostedOnBarrack[$i] = 1 Then
			Setlog("Did You Boost the Barrack nº " & $i + 1 & " Manually?", $COLOR_ORANGE)
			VerifyRemainBoostTime($i + 1) ; THIS WILL NOT FLAG 0 to 1 | Forcing To Search again the Time
			openArmyOverview()
			If $InitBoostTime[$i][1] > 0 Then
				If $FirstStart Then Setlog(" » let's disable the 'SmartWait4Train'!")
				If $FirstStart Then Setlog(" » To take advantage of the boost(x4)...")
				If $ichkCloseWaitEnable = 1 Then
					$ichkCloseWaitEnable = 0
					$ichkWASCloseWaitEnable = 1
					GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
				EndIf
				If $ichkMultyFarming = 1 And $ichkMultyWithBoost = 0 Then
					$ichkMultyFarming = 0
					$ichkWASCloseWaitEnable2 = 1
					GUICtrlSetState($chkMultyFarming, $GUI_UNCHECKED)
					Setlog(" » let's disable the 'MultyFarming'!", $COLOR_ORANGE)
				EndIf
			EndIf
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
					If $InitBoostTime[$i][1] > 0 Then
						If $FirstStart Then Setlog(" » let's disable the 'SmartWait4Train'!")
						If $FirstStart Then Setlog(" » To take advantage of the boost(x4)...")
						If $ichkCloseWaitEnable = 1 Then
							$ichkCloseWaitEnable = 0
							$ichkWASCloseWaitEnable = 1
							GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
						EndIf
						If $ichkMultyFarming = 1 And $ichkMultyWithBoost = 0 Then
							$ichkMultyFarming = 0
							$ichkWASCloseWaitEnable2 = 1
							GUICtrlSetState($chkMultyFarming, $GUI_UNCHECKED)
							Setlog(" » let's disable the 'MultyFarming'!", $COLOR_ORANGE)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If $InitBoostTime[$i][0] = 0 And $CheckIfWasBoostedOnBarrack[$i] = 0 Then
			$InitBoostTime[$i][1] = 0
			If $ichkWASCloseWaitEnable = 1 Then
				$ichkCloseWaitEnable = 1
				GUICtrlSetState($chkCloseWaitEnable, $GUI_CHECKED)
				$ichkWASCloseWaitEnable = 0
				Setlog(" » let's enable the 'SmartWait4Train'!")
			EndIf
			If $ichkWASCloseWaitEnable2 = 1 Then
				$ichkCloseWaitEnable = 1
				GUICtrlSetState($chkCloseWaitEnable, $GUI_CHECKED)
				$ichkWASCloseWaitEnable2 = 0
				Setlog(" » let's enable the 'SmartWait4Train'!")
			EndIf
		EndIf
		If $RunState = False Then Return
	Next

	If $icmbDarkTroopComp <> 2 Then
		For $i = 0 To ($numDarkBarracksAvailable - 1)
			Local $LocalTemp = 0

			; if exist a Flag from boostbarrack.au3 and True[=1] after Boosted Check on Barrack
			If $InitBoostTimeDark[$i][0] = 0 And $CheckIfWasBoostedOnDarkBarrack[$i] = 1 Then
				Setlog("Did You Boost the Dark Barrack nº " & $i + 1 & " Manually?", $COLOR_ORANGE)
				VerifyRemainDarkBoostTime($i + 1) ; THIS WILL NOT FLAG 0 to 1 | Forcing To Search again the Time
				openArmyOverview()
				If $InitBoostTimeDark[$i][1] > 0 Then
					If $FirstStart Then Setlog(" » let's disable the 'SmartWait4Train'!")
					If $FirstStart Then Setlog(" » To take advantage of the boost(x4)...")
					If $ichkCloseWaitEnable = 1 Then
						$ichkCloseWaitEnable = 0
						$ichkWASCloseWaitEnable = 1
						GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
					EndIf
					If $ichkMultyFarming = 1 And $ichkMultyWithBoost = 0 Then
						$ichkMultyFarming = 0
						$ichkWASCloseWaitEnable2 = 1
						GUICtrlSetState($chkMultyFarming, $GUI_UNCHECKED)
						Setlog(" » let's disable the 'MultyFarming'!", $COLOR_ORANGE)
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
								$ichkWASCloseWaitEnable = 1
								GUICtrlSetState($chkCloseWaitEnable, $GUI_UNCHECKED)
							EndIf
							If $ichkMultyFarming = 1 And $ichkMultyWithBoost = 0 Then
								$ichkMultyFarming = 0
								$ichkWASCloseWaitEnable2 = 1
								GUICtrlSetState($chkMultyFarming, $GUI_UNCHECKED)
								Setlog(" » let's disable the 'MultyFarming'!", $COLOR_ORANGE)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			If $InitBoostTimeDark[$i][0] = 0 And $CheckIfWasBoostedOnDarkBarrack[$i] = 0 Then
				$InitBoostTimeDark[$i][1] = 0
				If $ichkWASCloseWaitEnable = 1 Then
					$ichkCloseWaitEnable = 1
					GUICtrlSetState($chkCloseWaitEnable, $GUI_CHECKED)
					$ichkWASCloseWaitEnable = 0
					Setlog(" » let's enable the 'SmartWait4Train'!")
				EndIf
				If $ichkWASCloseWaitEnable2 = 1 Then
					$ichkCloseWaitEnable = 1
					GUICtrlSetState($chkCloseWaitEnable, $GUI_CHECKED)
					$ichkWASCloseWaitEnable2 = 0
					Setlog(" » let's enable the 'SmartWait4Train'!")
				EndIf
			EndIf
			If $RunState = False Then Return
		Next
	EndIf


	; GO TO First NORMAL BARRACK
	; Find First barrack $i

	If IsTrainPage() Then GoesToFirstBarrack()

	; #############################################################################################################################################
	; ###################################################  2nd Stage : Calculating of Troops to Make ##############################################
	; #############################################################################################################################################

	If $debugsetlogTrain = 1 Then SetLog(" » Total ArmyCamp :" & $TotalCamp, $COLOR_PURPLE)

	; First scenario : Is full Army  | is necessary make a complete Troop Composition.
	; $icmbDarkTroopComp = 1|Custom Dark Troops & $icmbTroopComp <> 8|Custom Normal Troops | $CommandStop = 0 Halt Attack
	If $IsFullArmywithHeroesAndSpells = True And $icmbTroopComp <> 8 And $CommandStop <> 0 Then

		SetLog(" » Your Army is full let make a new army before attack!", $COLOR_GREEN)
		If $iTScheck = 1 And $iMatchMode = $TS Then SetLog(" » Your Last Attack was a TH snipe, Lets try to balance the army!", $COLOR_GREEN)

		$anotherTroops = 0
		$TotalTrainedTroops = 0

		If $debugsetlogTrain = 1 Then SetLog(" » Your Army will be :", $COLOR_GREEN)

		; Balance Elixir troops but not archers ,barb and goblins
		For $i = 0 To UBound($TroopName) - 1
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			If Number(Eval($TroopName[$i] & "Comp")) > 0 Then
				If $debugsetlogTrain = 1 And Eval($TroopName[$i] & "Comp") > 0 Then SetLog("ASSIGN to $Cur" & $TroopName[$i] & ":" & Eval($TroopName[$i] & "Comp") & " Units", $COLOR_GREEN)
				If $iTScheck = 1 And $iMatchMode = $TS And Eval("Cur" & $TroopName[$i]) * -1 >= Eval($TroopName[$i] & "Comp") * 2.0 Then ; 200% way too many
					SetLog("Way Too many " & $TroopName[$i] & ", Don't Train.")
					Assign(("Cur" & $TroopName[$i]), Eval($TroopName[$i] & "Comp"))
					Assign(("tooMany" & $TroopName[$i]), 1)
					; When army full, add WayTooMany to $anotherTroops to prevent Arch/Barb/Gobl filling
					$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i]
				Else
					If $iTScheck = 1 And $iMatchMode = $TS And Eval("Cur" & $TroopName[$i]) * -1 > Eval($TroopName[$i] & "Comp") * 1.10 Then ; 110% too many
						SetLog("Too many " & $TroopName[$i] & ", train last.")
						Assign(("Cur" & $TroopName[$i]), Eval($TroopName[$i] & "Comp"))
						Assign(("tooMany" & $TroopName[$i]), 1)
						; When army full, add Too Many to $anotherTroops to prevent Arch/Barb/Gobl filling
						$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i]
					ElseIf $iTScheck = 1 And $iMatchMode = $TS And (Eval("Cur" & $TroopName[$i]) * -1 < Eval($TroopName[$i] & "Comp") * .90) Then ; 90% too few
						SetLog("Too few " & $TroopName[$i] & ", train first.")
						Assign(("Cur" & $TroopName[$i]), Eval($TroopName[$i] & "Comp"))
						Assign(("tooFew" & $TroopName[$i]), 1)
						; When army full, add WayTooMany to $anotherTroops to prevent Arch/Barb/Gobl filling
						$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i]
					Else
						; Troops only to donate not to use in attack , are necessary to remove that space troop from the armycamp capacity
						If IsTroopToDonateOnly(Eval("e" & $TroopName[$i])) Then
							Assign(("Cur" & $TroopName[$i]), Eval("Cur" & $TroopName[$i]) + Eval($TroopName[$i] & "Comp"))
							$anotherTroops += (Eval("Cur" & $TroopName[$i]) + Eval($TroopName[$i] & "Comp")) * $TroopHeight[$i]
						Else
							Assign(("Cur" & $TroopName[$i]), Eval($TroopName[$i] & "Comp"))
							$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i]
						EndIf
					EndIf
					; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected to deploy in attack )
					If Eval("Cur" & $TroopName[$i]) < 0 Then
						$anotherTroops += (Eval("Cur" & $TroopName[$i]) * -1) * $TroopHeight[$i]
					EndIf
					If $debugsetlogTrain = 1 And Eval($TroopName[$i] & "Comp") > 0 Then SetLog("-- AnotherTroops to train:" & $anotherTroops & " + " & Eval($TroopName[$i] & "Comp") & "*" & $TroopHeight[$i], $COLOR_PURPLE)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next

		If $anotherTroops > 0 Then
			If $debugsetlogTrain = 1 Then SetLog(" » H.Space occupied after assign Normal Troops :" & $anotherTroops & "/" & $TotalCamp, $COLOR_PURPLE)
		EndIf

		; Balance Dark elixir troops
		For $i = 0 To UBound($TroopDarkName) - 1
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			If Number(Eval($TroopDarkName[$i] & "Comp")) <> 0 And $icmbDarkTroopComp = 1 Then
				If $debugsetlogTrain = 1 Then SetLog("Need to train ASSIGN.... Cur" & $TroopDarkName[$i] & ":" & Eval($TroopDarkName[$i] & "Comp"), $COLOR_PURPLE)
				If $iTScheck = 1 And $iMatchMode = $TS And Eval("Cur" & $TroopDarkName[$i]) * -1 >= Eval($TroopDarkName[$i] & "Comp") * 2.0 Then ; 200% way too many
					SetLog("Way Too many " & $TroopDarkName[$i] & ", Dont Train.")
					Assign(("Cur" & $TroopDarkName[$i]), 0)
					$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i] ; When army full, add WayTooMany to $anotherTroops to prevent Arch/Barb/Gobl/Minion filling
				Else
					If $iTScheck = 1 And $iMatchMode = $TS And Eval("Cur" & $TroopDarkName[$i]) * -1 > Eval($TroopDarkName[$i] & "Comp") * 1.10 Then ; 110% too many
						SetLog("Too many " & $TroopDarkName[$i] & ", train last.")
						Assign(("Cur" & $TroopDarkName[$i]), 0)
						Assign(("tooMany" & $TroopDarkName[$i]), 1)
						$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i] ; When army full, add TooMany to $anotherTroops to prevent Arch/Barb/Gobl/Minion filling
					ElseIf $iTScheck = 1 And $iMatchMode = $TS And (Eval("Cur" & $TroopDarkName[$i]) * -1 < Eval($TroopDarkName[$i] & "Comp") * .90) Then ; 90% too few
						SetLog("Too few " & $TroopDarkName[$i] & ", train first.")
						Assign(("Cur" & $TroopDarkName[$i]), 0)
						Assign(("tooFew" & $TroopDarkName[$i]), 1)
						$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i] ; When army full, add Too few to $anotherTroops to prevent Arch/Barb/Gobl/Minion filling
					Else
						; Troops only to donate not to use in attack , are necessary to remove that space troop from the armycamp capacity
						If IsTroopToDonateOnly(Eval("e" & $TroopDarkName[$i])) Then
							Assign(("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) + Eval($TroopDarkName[$i] & "Comp"))
							$anotherTroops += (Eval("Cur" & $TroopDarkName[$i]) + Eval($TroopDarkName[$i] & "Comp")) * $TroopDarkHeight[$i]
						Else
							Assign(("Cur" & $TroopDarkName[$i]), Eval($TroopDarkName[$i] & "Comp"))
							$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i]
						EndIf
					EndIf
					; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected to deploy in attack )
					If Eval("Cur" & $TroopDarkName[$i]) < 0 Then
						$anotherTroops += (Eval("Cur" & $TroopDarkName[$i]) * -1) * $TroopDarkHeight[$i]
					EndIf
					If $debugsetlogTrain = 1 And Number(Eval($TroopDarkName[$i] & "Comp")) <> 0 Then SetLog("-- AnotherTroops dark to train:" & $anotherTroops & " + " & Eval($TroopDarkName[$i] & "Comp") & "*" & $TroopDarkHeight[$i], $COLOR_PURPLE)
				EndIf
			EndIf
			If $RunState = False Then Return
		Next

		If $anotherTroops > 0 Then
			If $debugsetlogTrain = 1 Then SetLog(" » H.Space occupied after assign Normal|Dark Troops :" & $anotherTroops & "/" & $TotalCamp, $COLOR_PURPLE)
		EndIf

		If $debugsetlogTrain = 1 Then SetLog("----- End $fullarmy = True And $iMatchMode = $TS -----", $COLOR_PURPLE)

		;  The $Cur+TroopName will be the diference bewtween -($Cur+TroopName) returned from ChechArmycamp() and what was selected by user GUI
		;  $Cur+TroopName = Trained - needed  (-20+25 = 5)
		;  $anotherTroops = quantity unit troops x $TroopHeight
		;
		; Second scenario : Is First Start Or came from a TH snipes and is not a Full Army , Will first Delete the queued troops and Get your existent army.
	ElseIf ($ArmyComp = 0 And $icmbTroopComp <> 8) Or $FirstStart Then

		SetLog(" » Let's make a new Army before attack!", $COLOR_GREEN)
		If $debugsetlogTrain = 1 Then SetLog(" » Your Army will be :", $COLOR_GREEN)

		$anotherTroops = 0

		For $i = 0 To UBound($TroopName) - 1
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			If Eval($TroopName[$i] & "Comp") > 0 Then
				Assign(("Cur" & $TroopName[$i]), Eval("Cur" & $TroopName[$i]) + Eval($TroopName[$i] & "Comp"))
				If $debugsetlogTrain = 1 And Number($anotherTroops + Eval($TroopName[$i] & "Comp")) <> 0 Then SetLog("-- AnotherTroops to train:" & $anotherTroops & " + " & Eval($TroopName[$i] & "Comp") & "*" & $TroopHeight[$i], $COLOR_PURPLE)
				$anotherTroops += Eval($TroopName[$i] & "Comp") * $TroopHeight[$i] ; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected on $TroopComp )
				If Eval("Cur" & $TroopName[$i]) < 0 Then ; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected on $TroopComp )
					$anotherTroops += (Eval("Cur" & $TroopName[$i]) * -1) * $TroopHeight[$i]
				EndIf
				If $debugsetlogTrain = 1 Then SetLog(" » " & Eval("Cur" & $TroopName[$i]) & " " & NameOfTroop(Eval("e" & $TroopName[$i])))
			EndIf
			If $RunState = False Then Return
		Next

		For $i = 0 To UBound($TroopDarkName) - 1
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			If $icmbDarkTroopComp = 1 And Eval($TroopDarkName[$i] & "Comp") > 0 Then
				Assign(("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) + Eval($TroopDarkName[$i] & "Comp"))
				If $debugsetlogTrain = 1 And Number($anotherTroops + Eval($TroopDarkName[$i] & "Comp")) <> 0 Then SetLog("-- AnotherTroops dark to train:" & $anotherTroops & " + " & Eval($TroopDarkName[$i] & "Comp") & "*" & $TroopDarkHeight[$i], $COLOR_PURPLE)
				$anotherTroops += Eval($TroopDarkName[$i] & "Comp") * $TroopDarkHeight[$i]
				If Eval("Cur" & $TroopDarkName[$i]) < 0 Then ; this is necessary to remove from $TotalCamp the existent Troops in the Camp ( not selected on $TroopComp )
					$anotherTroops += (Eval("Cur" & $TroopDarkName[$i]) * -1) * $TroopDarkHeight[$i]
				EndIf
				If $debugsetlogTrain = 1 Then SetLog(" » " & Eval("Cur" & $TroopDarkName[$i]) & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i])))
			EndIf
			If $RunState = False Then Return
		Next

		If $debugsetlogTrain = 1 Then SetLog(" » $AnotherTroops TOTAL to train:" & $anotherTroops, $COLOR_PURPLE)

	EndIf

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
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		EndIf
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		If Eval("Cur" & $TroopDarkName[$i]) > 0 Then
			$TotalTroopsTOtrain += Eval("Cur" & $TroopDarkName[$i]) * $TroopDarkHeight[$i]
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		EndIf
	Next

	; Next code will check the total troops to make and the total camp , if is necessary will remove some Arch|Barbs|Goblins to match Existent troops + To train = Total camp space ...
	; Some times on queue we have at 3 more barbs or archers , this happens because the % on Arch|Barbs|Goblins

	If $IsFullArmywithHeroesAndSpells = True Or $FirstStart = True Then SetLog(" » Total Barrack Space to be Train: " & $TotalTroopsTOtrain)
	If $FirstStart = True Then SetLog(" » Existent Army: " & $CurCamp & " To train : " & $TotalTroopsTOtrain & " | [T]: " & $CurCamp + $TotalTroopsTOtrain)
	If $IsFullArmywithHeroesAndSpells = True Then SetLog(" » Full Army: " & $CurCamp & " To Queue Troops : " & $TotalTroopsTOtrain & " | [T]: " & $CurCamp + $TotalTroopsTOtrain)

	If $FirstStart = True And Not $fullarmy Then
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
	EndIf

	If $IsFullArmywithHeroesAndSpells = True Or ($fullarmy And $FirstStart) Then
		If $TotalTroopsTOtrain > $TotalCamp Then
			Local $ExceedTroops = ($TotalTroopsTOtrain) - $TotalCamp
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

	Local $DtroopsToMake[7][5] = [ _
			["Lava", 900, 30, 0, 90], _
			["Gole", 900, 30, 0, 70], _
			["Witc", 600, 12, 0, 80], _
			["Bowl", 300, 6, 0, 100], _
			["Valk", 300, 8, 0, 60], _
			["Hogs", 120, 5, 0, 50], _
			["Mini", 45, 2, 0, 40]]

	; Fill the $TroopsToMake[$x][3] with the quantity to make with the existent $Cur[troopName] Global variable
	; NameOfTroop() Returns the string value of the troopname in singular or plural form | NameOfTroop.au3
	For $i = 0 To UBound($TroopName) - 1 ;  Normal troops
		If Eval("Cur" & $TroopName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 11
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
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
	For $i = 0 To UBound($TroopDarkName) - 1 ; Dark troops
		If Eval("Cur" & $TroopDarkName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 6
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
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


	; Fill the $TroopsToMake[$x][3] with the Donated Troops quantity to make | $Don[troopName] Global variable
	; NameOfTroop() Returns the string value of the troopname in singular or plural form | NameOfTroop.au3
	For $i = 0 To UBound($TroopName) - 1 ;  Normal troops
		If Eval("Don" & $TroopName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 11
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
				If $TroopsToMake[$x][0] = $TroopName[$i] Then
					If $debugsetlogTrain = 1 Then Setlog("$TroopsToMake[$x][0] : " & $TroopsToMake[$x][0] & " | $TroopName[$i]: " & $TroopName[$i])
					$TroopsToMake[$x][3] += Eval("Don" & $TroopName[$i])
					If $TroopsToMake[$x][3] > 1 Then $plural = 1
					Setlog(" »» Preparing to Train " & $TroopsToMake[$x][3] & " Donated " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), $plural))
					ExitLoop
				EndIf
				If $RunState = False Then Return
			Next
		EndIf
	Next
	For $i = 0 To UBound($TroopDarkName) - 1 ;  Dark Troops
		If Eval("Don" & $TroopDarkName[$i]) > 0 Then
			Local $plural = 0
			For $x = 0 To 6
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
				If $DtroopsToMake[$x][0] = $TroopDarkName[$i] Then
					If $debugsetlogTrain = 1 Then Setlog("$TroopsToMake[$x][0] : " & $DtroopsToMake[$x][0] & " | $TroopName[$i]: " & $TroopDarkName[$i])
					$DtroopsToMake[$x][3] += Eval("Don" & $TroopDarkName[$i])
					If $DtroopsToMake[$x][3] > 1 Then $plural = 1
					Setlog(" »» Preparing to Train " & $DtroopsToMake[$x][3] & " Donated Unit(s) of " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), $plural))
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
		$BarrackTotalStatus[$i][0] = 0 ; training time in seconds
		$BarrackTotalStatus[$i][1] = 0 ; house spacing | Unit Queue Length will have a limit just in case of Boost barracks ***
		$BarrackTotalStatus[$i][2] = $InitBoostTime[$i][0] ; Boosted Barrack? 0 = Force OCR , 1 = TimerInit() | with true training time will divide by 4
		$BarrackTotalStatus[$i][4] = $BarrackCapacity[$i] ; Maximum Unit Queue Length | Barrack level | 75 is a Barrack Lv10 | with pekka
		If $BarrackCapacity[$i] = 0 Then $BarrackTotalStatus[$i][4] = 75 ; In case of any error Reading The Unit Queue Length
		If $RunState = False Then Return
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
		If $RunState = False Then Return
	Next

	; Let store the last Remain Time of each Barrack | possible to use to make Donated Troops balanced
	If $fullarmy Or $FirstStart Then
		For $i = 0 To ($numBarracksAvailable - 1)
			$BarrackTimeRemain[$i] = 0
		Next
	Else
		For $i = 0 To ($numBarracksAvailable - 1)
			$BarrackTotalStatus[$i][0] = $BarrackTimeRemain[$i]
		Next
	EndIf

	If $fullarmy Or $FirstStart Then
		For $i = 0 To ($numDarkBarracksAvailable - 1)
			$DarkBarrackTimeRemain[$i] = 0
		Next
	Else
		For $i = 0 To ($numDarkBarracksAvailable - 1)
			$BarrackDarkTotalStatus[$i][0] = $DarkBarrackTimeRemain[$i]
		Next
	EndIf

	; Variable to assign each troop quantity on each barrack | max Barracks available
	; Local $PekkEBarrack0 , $PekkEBarrack1 , $PekkEBarrack2 , $PekkEBarrack3
	; Making a loop to assign the 0 and forcing the variable declaration on local scope

	For $i = 0 To UBound($TroopsToMake) - 1
		If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		For $x = 0 To ($numBarracksAvailable - 1)
			Assign($TroopsToMake[$i][0] & "EBarrack" & $x, 0, $ASSIGN_FORCELOCAL)
			If $debugsetlogTrain = 1 Then Setlog(" » Declared Local scope: " & $TroopsToMake[$i][0] & "EBarrack" & $x & " = 0")
			If @error Then _logErrorDateDiff(@error)
			If Not IsDeclared($TroopsToMake[$i][0] & "EBarrack" & $x) Then
				Setlog(" » Error creating in local scope the variable: " & Eval($TroopsToMake[$i][0] & "EBarrack" & $x), $COLOR_RED)
			EndIf
			If $RunState = False Then Return
		Next
	Next

	For $i = 0 To UBound($DtroopsToMake) - 1
		If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
		For $x = 0 To ($numDarkBarracksAvailable - 1)
			Assign($DtroopsToMake[$i][0] & "EBarrack" & $x, 0, $ASSIGN_FORCELOCAL)
			If $debugsetlogTrain = 1 Then Setlog(" » Declared Local scope: " & $DtroopsToMake[$i][0] & "EBarrack" & $x & " = 0")
			If @error Then _logErrorDateDiff(@error)
			If Not IsDeclared($DtroopsToMake[$i][0] & "EBarrack" & $x) Then
				Setlog(" » Error creating in local scope the variable: " & Eval($DtroopsToMake[$i][0] & "EBarrack" & $x), $COLOR_RED)
			EndIf
			If $RunState = False Then Return
		Next
	Next


	Local $BarrackNotAvailableForTheTroop[$numBarracksAvailable]

	For $x = 0 To ($numBarracksAvailable - 1)
		$BarrackNotAvailableForTheTroop[$x] = 0
	Next

	; If is necessary make a troop but is not available in all barracks will proceed with a sort on the $TroopsToMake
	; In descending order Value ($TroopsToMake[$i][4])

	For $i = 0 To UBound($TroopsToMake) - 1
		If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
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
		If $RunState = False Then Return
	Next

	; ###################################################################################################################################################
	; ############################################################ Barracks Troops distribution #########################################################
	; ################################################################ Main Core - balanced #############################################################
	; ###################################################################################################################################################

	; Main Loop on each troop to train, assigning the quantity on each barrack available , balanced train time.
	; Use each loop to assign troop on barrack with less time = _ArrayMinIndex($BarrackTotalTime, 1, -1, -1 , 0))
	; Success:	the 'index' of the minimum value in the array[$i][0]. Barrack Number with less time assigned.
	; Failure:	-1 and sets the @error flag to non-zero.

	Local $TimeStored[$numBarracksAvailable] ; This will store the correct time on boosted Barrcaks after filled
	For $i = 0 To ($numBarracksAvailable - 1)
		$TimeStored[$i] = 0
	Next

	Local $z = 0, $AreAllFull = 0
	Local $TotalCapacityOfBarracks = 0
	Local $m = 0

	For $i = 0 To UBound($TroopsToMake) - 1 ; From pekka to barbarians | OR  Miner to Barbarian if was Sorted before

		If $TroopsToMake[$i][3] > 0 Then ; if is necessary to train

			$plural = 0
			If $TroopsToMake[$i][3] > 1 Then $plural = 1

			$m = 0
			$TotalCapacityOfBarracks = 0

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
				If $RunState = False Then Return
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
					SetLog("Queue Spacing is Full!! on Barrack nº :" & $BarrackToTrain + 1, $COLOR_ORANGE) ; ** flag for boosted barrack !!
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

				If $AssignedQuantity > $QuantityToMake Then ExitLoop
				If $z = 240 Then ExitLoop (2)
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			Until $AssignedQuantity = $QuantityToMake

			For $x = 0 To UBound($BarrackTotalStatus) - 1
				Local $plural = 0
				If Eval($TroopsToMake[$i][0] & "EBarrack" & $x) > 1 Then $plural = 1
				If $debugsetlogTrain = 1 Then Setlog( NameOfTroop(Eval("e" & $TroopsToMake[$i][0]), $plural) & " On Barrack " & $x + 1 & " |Q: " & Eval($TroopsToMake[$i][0] & "EBarrack" & $x) & "| Barrack Space used : " & $BarrackTotalStatus[$x][1] & "|" & $BarrackTotalStatus[$x][4])
			Next
		EndIf
		If $RunState = False Then Return
	Next

	; Lets store the last Remain Train Time in a Global Variable to use if is necessary to make Donated Troops

	For $i = 0 To ($numBarracksAvailable - 1)
		If $TimeStored[$i] > 0 Then $BarrackTotalStatus[$i][0] = $TimeStored[$i]
		$BarrackTimeRemain[$i] = $BarrackTotalStatus[$i][0]
	Next

	; Main Loop on each troop to train, assigning the quantity on each Dark barrack available , balanced train time.
	; Use each loop to assign troop on barrack with less time = _ArrayMinIndex($BarrackTotalTime, 1, -1, -1 , 0))
	; Success:	the 'index' of the minimum value in the array[$i][0]. Barrack Number with less time assigned.
	; Failure:	-1 and sets the @error flag to non-zero.


	Local $BarrackNotAvailableForTheDarkTroop[$numDarkBarracksAvailable]

	For $x = 0 To ($numDarkBarracksAvailable - 1)
		$BarrackNotAvailableForTheDarkTroop[$x] = 0
	Next

	; If is necessary make a troop but is not available in all barracks will proceed with a sort on the $DtroopsToMake
	; In descending order Value ($DtroopsToMake[$i][4])

	For $i = 0 To UBound($DtroopsToMake) - 1
		For $x = 0 To ($numDarkBarracksAvailable - 1)
			If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			If $DtroopsToMake[$i][3] > 0 And $DtroopsToMake[$i][4] > $DarkBarrackCapacity[$x] Then
				Setlog(" » " & NameOfTroop(Eval("e" & $DtroopsToMake[$i][0]), $plural) & " are not available on Dark Barrack nº " & $x + 1, $COLOR_RED)
				$LetsSortDB = True
			EndIf
		Next
		If $LetsSortDB = True Then
			_ArraySort($DtroopsToMake, 1, 0, 0, 4)
			If @error Then _logErrorDateDiff(@error)
			ExitLoop
		EndIf
		If $RunState = False Then Return
	Next

	ReDim $TimeStored[$numDarkBarracksAvailable] ; This will store the correct time on boosted Barrcaks after filled
	For $i = 0 To ($numDarkBarracksAvailable - 1)
		$TimeStored[$i] = 0
	Next

	$z = 0
	$AreAllFull = 0

	For $i = 0 To UBound($DtroopsToMake) - 1 ; From Lava Hound to Minion

		If $DtroopsToMake[$i][3] > 0 Then ; if is necessary to train
			$plural = 0
			If $DtroopsToMake[$i][3] > 1 Then $plural = 1

			$m = 0
			$TotalCapacityOfBarracks = 0

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
				If $RunState = False Then Return
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
					SetLog("Queue Spacing is Full!! on Barrack nº :" & $BarrackToTrain + 1, $COLOR_ORANGE) ; *** Need More Work | ** flag for boosted barrack !!
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
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
			Until $AssignedQuantity = $QuantityToMake

			For $x = 0 To UBound($BarrackDarkTotalStatus) - 1
				Local $plural = 0
				If Eval($DtroopsToMake[$i][0] & "EBarrack" & $x) > 1 Then $plural = 1
				If $debugsetlogTrain = 1 Then Setlog( NameOfTroop(Eval("e" & $DtroopsToMake[$i][0]), $plural) & " On Dark B. " & $x + 1 & " |Q: " & Eval($DtroopsToMake[$i][0] & "EBarrack" & $x) & "| Barrack Space used : " & $BarrackDarkTotalStatus[$x][1] & "|" & $BarrackDarkTotalStatus[$x][4])
			Next
		EndIf
		If $RunState = False Then Return
	Next

	; Lets store the last Remain Train Time in a Global Variable to use if is necessary to make Donated Troops

	For $i = 0 To ($numDarkBarracksAvailable - 1)
		If $TimeStored[$i] > 0 Then $BarrackDarkTotalStatus[$i][0] = $TimeStored[$i]
		$DarkBarrackTimeRemain[$i] = $BarrackDarkTotalStatus[$i][0]
	Next

	If $debugsetlogTrain = 1 Then SetLog("--------- END COMPUTE TROOPS TO MAKE ---------", $COLOR_PURPLE)

	; #############################################################################################################################################
	; ###################################################  4th Stage : Train IT Troops on each barrack ############################################
	; #############################################################################################################################################


	; First Normal Barrack available | $brrNum = 0
	$brrNum = 0

	; ############################################################################################################################################
	; ############################################################## Train Barrack MODE ##########################################################
	; ############################################################################################################################################
	If $icmbTroopComp = 8 Then

		; ProMac : Untouched code
		If $debugsetlogTrain = 1 Then
			Setlog("", $COLOR_PURPLE)
			SetLog("---------TRAIN BARRACK MODE------", $COLOR_PURPLE)
		EndIf

		While isBarrack()

			$brrNum += 1

			If $FirstStart Then
				If _Sleep($iDelayTrain2) Then Return
				$icount = 0
				If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
					While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
						ClickDrag(550, 240, 170, 240, 1000)
						$icount += 1
						If _Sleep($iDelayTrain2) Then Return
						If $icount = 7 Then ExitLoop
					WEnd
				EndIf
				If $iChkDontRemove = 0 Then
					$icount = 0
					While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
						If Not (IsTrainPage()) Then Return
						Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0273") ; Remove Troops in training
						$icount += 1
						If $icount = 100 Then ExitLoop
					WEnd
					If $debugsetlogTrain = 1 And $icount = 100 Then SetLog(" » Train warning 'don't disappears green arrow' ", $COLOR_RED)
				EndIf
			EndIf

			If _Sleep($iDelayTrain4) Then Return
			If Not (IsTrainPage()) Then Return ; exit from train if no train page

			Switch $barrackTroop[$brrNum - 1]
				Case 0
					TrainClick(166, 320 + $midOffsetY, 85, $isldTrainITDelay, $FullBarb, $GemBarb, "#0274", $TrainBarbRND) ; Barbarian
				Case 1
					TrainClick(245, 320 + $midOffsetY, 85, $isldTrainITDelay, $FullArch, $GemArch, "#0275", $TrainArchRND) ; Archer
				Case 2
					TrainClick(370, 320 + $midOffsetY, 17, $isldTrainITDelay, $FullGiant, $GemGiant, "#0276", $TrainGiantRND) ; Giant
				Case 3
					TrainClick(482, 320 + $midOffsetY, 85, $isldTrainITDelay, $FullGobl, $GemGobl, "#0277", $TrainGoblRND) ; Goblin
				Case 4
					TrainClick(557, 320 + $midOffsetY, 42, $isldTrainITDelay, $FullWall, $GemWall, "#0278", $TrainWallRND) ; Wall Breaker
				Case 5
					TrainClick(682, 320 + $midOffsetY, 17, $isldTrainITDelay, $FullBall, $GemBall, "#0279", $TrainBallRND) ; Balloon
				Case 6
					TrainClick(173, 425 + $midOffsetY, 21, $isldTrainITDelay, $FullWiza, $GemWiza, "#0280", $TrainWizaRND) ; Wizard
				Case 7
					TrainClick(263, 425 + $midOffsetY, 6, $isldTrainITDelay, $FullHeal, $GemHeal, "#0281", $TrainHealRND) ; Healer
				Case 8
					TrainClick(383, 425 + $midOffsetY, 4, $isldTrainITDelay, $FullDrag, $GemDrag, "#0282", $TrainDragRND) ; Dragon
				Case 9
					TrainClick(474, 425 + $midOffsetY, 3, $isldTrainITDelay, $FullPekk, $GemPekk, "#0283", $TrainPekkRND) ; Pekka
				Case 10
					TrainClick(572, 425 + $midOffsetY, 8, $isldTrainITDelay, $FullBabyD, $GemBabyD, "#0342", $TrainBabyDRND) ; Baby Dragon
				Case 11
					TrainClick(675, 425 + $midOffsetY, 17, $isldTrainITDelay, $FullMine, $GemMine, "#0343", $TrainMineRND) ; Miner
			EndSwitch

			If $OutOfElixir = 1 Then
				Setlog(" » Not enough Elixir to train troops!", $COLOR_RED)
				Setlog(" » Switching to Halt Attack, Stay Online Mode...", $COLOR_RED)
				$ichkBotStop = 1 ; set halt attack variable
				$icmbBotCond = 18 ; set stay online
				If CheckFullBarrack() Then $Restart = True ;If the army camp is full, use it to refill storages
				Return ; We are out of Elixir stop training.
			EndIf

			If _Sleep($iDelayTrain2) Then Return
			If Not (IsTrainPage()) Then Return
			If $brrNum >= $numBarracksAvaiables Then ExitLoop ; make sure no more infiniti loop
			_TrainMoveBtn(+1) ;click Next button
			If _Sleep($iDelayTrain3) Then Return
			If $RunState = False Then Return
		WEnd

	Else
		; ############################################################################################################################################
		; ############################################################### Train Custom MODE ##########################################################
		; ############################################################################################################################################

		If $debugsetlogTrain = 1 Then SetLog("---------TRAIN NEW CUSTOM MODE-----------", $COLOR_PURPLE)

		If $IsFullArmywithHeroesAndSpells = True Then SetLog("Queue troops before attacking.")

		While isBarrack() And $isNormalBuild
			Local $Result = ""
			Local $TroopCapacityAfterTraining = ""
			Local $TotalTime = ""
			$brrNum += 1
			$BarrackToTrain = $brrNum - 1
			For $i = 0 To UBound($TroopName) - 1
				Assign(("troopFirst" & $TroopName[$i]), 0)
				Assign(("troopSecond" & $TroopName[$i]), 0)
			Next
			If $debugsetlogTrain = 1 Then SetLog("====== Checking available Barrack: " & $brrNum & " ======", $COLOR_PURPLE)
			If $fullarmy Or $FirstStart Then
				;CLICK REMOVE TROOPS
				If _Sleep($iDelayTrain2) Then Return
				$icount = 0
				If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
					While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
						;_PostMessage_ClickDrag(550, 240, 170, 240, "left", 1000)
						ClickDrag(550, 240, 170, 240, 1000)
						$icount += 1
						If _Sleep($iDelayTrain4) Then Return
						If $icount = 7 Then ExitLoop
					WEnd
				EndIf
				If $iChkDontRemove = 0 Then
					$icount = 0
					While Not _ColorCheck(_GetPixelColor(593, 200 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
						If Not (IsTrainPage()) Then Return ;exit if no train page
						Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0284") ; Remove Troops in training
						$icount += 1
						If $RunState = False Then Return
						If $icount = 100 Then ExitLoop
					WEnd
					If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 'not disappears » green arrow'", $COLOR_PURPLE)
				EndIf
			EndIf

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
					If _Sleep($iDelayTrain1) Then Return
					$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
					If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog("[B" & $brrNum & "] » ASSIGN $TroopFirst" & $TroopName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
					Assign(("troopFirst" & $TroopName[$i]), $tmpNumber)

					; Just in case of OCR's fail
					If Eval("troopFirst" & $TroopName[$i]) = 0 And Eval($TroopName[$i] & "EBarrack" & $BarrackToTrain) > 0 Then
						If _Sleep($iDelayTrain1) Then Return
						If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog("[B" & $brrNum & "] » ASSIGN $TroopFirst" & $TroopName[$i] & ": " & $tmpNumber, $COLOR_PURPLE)
						Assign(("troopFirst" & $TroopName[$i]), $tmpNumber)
					EndIf
				EndIf
				If $RunState = False Then Return
			Next

			;Too few troops, train first
			For $i = 0 To UBound($TroopName) - 1
				If Eval("tooFew" & $TroopName[$i]) = 1 Then
					If Not (IsTrainPage()) Then Return ;exit from train
					If $RunState = False Then Return ; Bot stops
					If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

					; loop on all $TroopsToMake to macth the troops name and TrainIT
					For $x = 0 To UBound($TroopsToMake) - 1
						If $TroopsToMake[$x][0] = $TroopName[$i] And Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
							TrainIt(Eval("e" & $TroopsToMake[$x][0]), Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
							$BarrackStatus[$BarrackToTrain] = True
							If $debugsetlogTrain = 1 Then SetLog("[NB" & $BarrackToTrain + 1 & "] » tooFew|TrainIt Click " & Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), 1), $COLOR_GREEN)
						EndIf
					Next
				EndIf
			Next

			For $i = 0 To UBound($TroopName) - 1
				; Only runs loops on Existing GUI Custom Troops with positive $Cur
				; $Cur|TroopName will be updated forward in the line 670 with $troopSecond|TroopName , removing the quantity troops made in the current barrack
				If Eval("Cur" & $TroopName[$i]) > 0 And Eval("tooFew" & $TroopName[$i]) = 0 And Eval("tooMany" & $TroopName[$i]) = 0 Then

					If Not (IsTrainPage()) Then Return ;exit from train
					If $RunState = False Then Return ; Bot stops
					If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

					; loop on all $TroopsToMake to macth the troops name and TrainIT
					For $x = 0 To UBound($TroopsToMake) - 1
						If $TroopsToMake[$x][0] = $TroopName[$i] And Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
							TrainIt(Eval("e" & $TroopsToMake[$x][0]), Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
							$BarrackStatus[$BarrackToTrain] = True
							If $debugsetlogTrain = 1 Then SetLog("[NB" & $BarrackToTrain + 1 & "] » TrainIt Click " & Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), 1), $COLOR_GREEN)
						EndIf
					Next
				EndIf
			Next

			;Too Many troops, train Last
			For $i = 0 To UBound($TroopName) - 1 ; put troops at end of queue if there are too many
				If Eval("tooMany" & $TroopName[$i]) = 1 Then
					If Not (IsTrainPage()) Then Return ;exit from train
					If $RunState = False Then Return ; Bot stops
					If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

					; loop on all $TroopsToMake to macth the troops name and TrainIT
					For $x = 0 To UBound($TroopsToMake) - 1
						If $TroopsToMake[$x][0] = $TroopName[$i] And Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
							TrainIt(Eval("e" & $TroopsToMake[$x][0]), Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
							$BarrackStatus[$BarrackToTrain] = True
							If $debugsetlogTrain = 1 Then SetLog("[NB" & $BarrackToTrain + 1 & "] » tooMany|TrainIt Click " & Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), 1), $COLOR_GREEN)
						EndIf
					Next
				EndIf
			Next

			; Just a Setlog with each Barrack remain train times
			If $IsFullArmywithHeroesAndSpells = True Or $FirstStart = True Then Setlog("Barrack nº " & $brrNum & " with remain train of " & Sec2Time($BarrackTotalStatus[$BarrackToTrain][0]), $COLOR_GREEN)

			$QuantNormalTroopsInQueue[$BarrackToTrain] = 0
			If _Sleep($iDelayTrain2) Then Return

			For $i = 0 To UBound($TroopName) - 1
				$tmpNumber = 0
				If Eval($TroopName[$i] & "Comp") <> "0" Then
					$heightTroop = 294 + $midOffsetY
					$positionTroop = $TroopNamePosition[$i]
					If $TroopNamePosition[$i] > 5 Then
						$heightTroop = 396 + $midOffsetY
						$positionTroop = $TroopNamePosition[$i] - 6
					EndIf
					If _Sleep($iDelayTrain1) Then Return
					$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
					If $debugsetlogTrain = 1 And $tmpNumber <> 0 Then SetLog(("[B" & $brrNum & "] » ASSIGN $troopSecond" & $TroopName[$i] & ": " & $tmpNumber), $COLOR_PURPLE)
					Assign(("troopSecond" & $TroopName[$i]), $tmpNumber)

					; Just in case of OCR fail
					If $tmpNumber = 0 And Eval("troopFirst" & $TroopName[$i]) <> 0 And Eval($TroopName[$i] & "EBarrack" & $BarrackToTrain) > 0 Then
						Local $g = 0
						While $tmpNumber = 0
							If _Sleep($iDelayTrain2) Then Return ; just a delay | ocr | 500ms
							$tmpNumber = Number(getBarracksTroopQuantity(126 + 102 * $positionTroop, $heightTroop))
							Assign(("troopSecond" & $TroopName[$i]), $tmpNumber)
							$g += 1
							If $g = 60 Then ExitLoop
							If $RunState = False Then Return
						WEnd
						If $g >= 1 Then SetLog(("[B" & $brrNum & "] » ASSIGN $troopSecond" & $TroopName[$i] & " FAIL | attempts: " & $g), $COLOR_RED)
					EndIf
					$QuantNormalTroopsInQueue[$BarrackToTrain] += $tmpNumber
					Local $QuantyMade = Eval("troopSecond" & $TroopName[$i]) - Eval("troopFirst" & $TroopName[$i])
					$plural = 0
					If $QuantyMade > 1 Then $plural = 1
					If $QuantyMade > 0 Then SetLog("[NB" & $BarrackToTrain + 1 & "] » Trained " & $QuantyMade & " " & NameOfTroop(Eval("e" & $TroopName[$i]), $plural), $COLOR_GREEN)
				EndIf
				If $RunState = False Then Return
			Next

			; Here will be remove from $Cur'TroopName' the trained troops
			; Possible issues : if the troopfirst was 9 but in one second was trained| finished from queue , will be 8 and you add 1 , will not removed from the $Cur
			; How can we resolve that ? of course 99% of the times the barrack will be empty when procides the tropfirst! but
			For $i = 0 To UBound($TroopName) - 1
				If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
				If Eval("troopSecond" & $TroopName[$i]) > Eval("troopFirst" & $TroopName[$i]) And Eval($TroopName[$i] & "Comp") <> "0" Then
					$ArmyComp += (Eval("troopSecond" & $TroopName[$i]) - Eval("troopFirst" & $TroopName[$i])) * $TroopHeight[$i]
					If $debugsetlogTrain = 1 Then SetLog((" » $Cur" & $TroopName[$i]) & " = " & Eval("Cur" & $TroopName[$i]) & " - (" & Eval("troopSecond" & $TroopName[$i]) & " - " & Eval("troopFirst" & $TroopName[$i]) & ")", $COLOR_PURPLE)
					Assign(("Cur" & $TroopName[$i]), Eval("Cur" & $TroopName[$i]) - (Eval("troopSecond" & $TroopName[$i]) - Eval("troopFirst" & $TroopName[$i])))
					If Eval("Cur" & $TroopName[$i]) <= 0 Then Setlog(" » The " & NameOfTroop(Eval("e" & $TroopName[$i]), 1) & " are all done!", $COLOR_BLUE)
				EndIf
				If $RunState = False Then Return
			Next

			If $IsFullArmywithHeroesAndSpells = True Or $FirstStart Then
				If $RunState = False Then Return
				If Not (IsTrainPage()) Then Return ;exit from train
				Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity

				$TroopCapacityAfterTraining = getBarrackArmy(520, 275)
				$TotalTime = getBarracksTotalTime(632, 202)

				If IsArray($TroopCapacityAfterTraining) And $TroopCapacityAfterTraining[0] <> "" Then
					$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
					$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
				Else
					$BarrackStatusTrain[0] = 0
					$BarrackStatusTrain[1] = 0
				EndIf

				$BarrackStatusTrain[2] = $BarrackCapacity[$BarrackToTrain]

				If IsArray($TotalTime) And $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
					$BarrackStatusTrain[3] = $TotalTime[0]
					If $InitBoostTime[$BarrackToTrain][1] > 0 Then
						$BarrackTimeRemain[$BarrackToTrain] = Ceiling($TotalTime[1] / 4)
					Else
						$BarrackTimeRemain[$BarrackToTrain] = Ceiling($TotalTime[1])
					EndIf
				Else
					$BarrackStatusTrain[3] = 0
					$BarrackTimeRemain[$BarrackToTrain] = 0
				EndIf

				If $InitBoostTime[$BarrackToTrain][1] > 0 Then
					SetLog(" »» NB[" & $BarrackToTrain + 1 & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantNormalTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3] & " [B]", $COLOR_BLUE)
				Else
					SetLog(" » NB[" & $BarrackToTrain + 1 & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantNormalTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3], $COLOR_BLUE)
				EndIf
				If _Sleep($iDelayTrain2) Then Return
			EndIf

			If $brrNum >= $numBarracksAvaiables Then
				; Just in case of OCR fail on troopSecond :
				If $BarrackStatusTrain[0] = $BarrackStatusTrain[1] Or _ ; In case of Regular Train loop example : 200/200
						$BarrackStatusTrain[0] * 2 = $BarrackStatusTrain[1] Then ; in case of train before Attack , example : 400/200
					For $i = 0 To UBound($TroopName) - 1
						If $debugsetlogTrain = 1 Then SetLog("Reset the $Cur" & $TroopName[$i], $COLOR_PURPLE)
						Assign("Cur" & $TroopName[$i], 0)
					Next
					For $i = 0 To UBound($TroopDarkName) - 1
						If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
						Assign("Cur" & $TroopDarkName[$i], 0)
						Assign("Don" & $TroopDarkName[$i], 0)
					Next
				EndIf
			EndIf

			; The Important stage | will make the donated troops , check if exist some errors on train troops | When is not full Army and Not First Start

			If $icmbTroopComp <> 8 And $IsFullArmywithHeroesAndSpells = False And $FirstStart = False Then

				; Train the Donated Troops :
				For $i = 0 To UBound($TroopName) - 1
					; Only runs loops with positive $DonTroopName
					If Eval("Don" & $TroopName[$i]) > 0 Then
						If Not (IsTrainPage()) Then Return ;exit from train
						If $RunState = False Then Return ; Bot stopped
						; loop on all $TroopsToMake to macth the troops name and TrainIT
						For $x = 0 To UBound($TroopsToMake) - 1
							If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
							If $TroopsToMake[$x][0] = $TroopName[$i] And Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
								TrainIt(Eval("e" & $TroopsToMake[$x][0]), Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
								$QuantNormalTroopsInQueue[$BarrackToTrain] += Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain)
								$BarrackStatus[$BarrackToTrain] = True
								SetLog("[NB" & $BarrackToTrain + 1 & "] » Trained " & Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $TroopsToMake[$x][0]), 1), $COLOR_GREEN)
								Assign("Don" & $TroopName[$i], Eval("Don" & $TroopName[$i]) - Eval($TroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain))
							EndIf
						Next
					EndIf
				Next

				; Checks if there is Troops being trained in this barrack
				; if exist green arrow

				If $QuantNormalTroopsInQueue[$BarrackToTrain] <> 0 Or _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xa8d070, 6), 20) = True Or _
						_ColorCheck(_GetPixelColor(649, 243 + $midOffsetY, True), Hex(0x60ad20, 6), 20) = True Then
					$BarrackStatus[$BarrackToTrain] = True ; Troops are being trained in this barrack
					If $debugsetlogTrain = 1 Then
						Local $BarrackStatusColor = _GetPixelColor(599, 202 + $midOffsetY, True)
						Local $BarrackStatusColor2 = _GetPixelColor(649, 243 + $midOffsetY, True)
						If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|Arrow(" & 599 & "," & 202 + $midOffsetY & "): " & $BarrackStatusColor, $COLOR_PURPLE)
						If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|GEM(" & 649 & "," & 243 + $midOffsetY & "): " & $BarrackStatusColor, $COLOR_PURPLE)
					EndIf
				Else
					$BarrackStatus[$BarrackToTrain] = False ; No troop is being trained in this barrack
					Local $BarrackStatusColor = _GetPixelColor(599, 202 + $midOffsetY, True)
					Local $BarrackStatusColor2 = _GetPixelColor(649, 243 + $midOffsetY, True)
					If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|Arrow(" & 599 & "," & 202 + $midOffsetY & "): " & $BarrackStatusColor, $COLOR_PURPLE)
					If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|GEM(" & 649 & "," & 243 + $midOffsetY & "): " & $BarrackStatusColor, $COLOR_PURPLE)
					SetLog("[NB" & $brrNum & "] » Troops is working? " & $BarrackStatus[$BarrackToTrain], $COLOR_PURPLE)
				EndIf

				; Checks if the barrack is full ( stopped )
				If CheckFullBarrack() Then
					$BarrackFull[$brrNum - 1] = True ; Barrack is full
					SetLog("[NB" & $brrNum & "] » Queue troops and stopped! ", $COLOR_PURPLE)
				Else
					$BarrackFull[$brrNum - 1] = False ; Barrack isn't full
				EndIf

;~ 				; ################################################################################################################################


				If $InitBoostTime[$brrNum - 1][1] > 0 And $BarrackStatus[$brrNum - 1] = False And $fullarmy = False Then ; Barracks boosted BUT Empty!
					If _Sleep($iDelayTrain4) Then Return

					; ($checkTrainPage = True, $showlog = False, $CNormalBarrack = True, $CDarkBarrack = False)
					If $RunState = False Then Return
					If Not (IsTrainPage()) Then Return ;exit from train
					$Result = CheckBarrackStatus(True, False, True, False)

					Local $z = 0, $m = 0, $n = 0, $l = 0, $j = 0
					For $i = 0 To ($numBarracksAvaiables - 1)
						If $InitBoostTime[$i][1] > 0 And $Result[$i] = 1 Then $z += 1 ; Working And boosted
						If $InitBoostTime[$i][1] > 0 And $Result[$i] = 1 And $BarrackTimeRemain[$i] < 75 Then $m += 1 ; boosted but Total Time < 75's
						If $InitBoostTime[$i][1] > 0 And $Result[$i] = 0 Then $l += 1 ; boosted and Empty
						If $InitBoostTime[$i][1] <= 0 And $Result[$i] = 0 Then $n += 1 ; Not Boosted and empty
						If $InitBoostTime[$i][1] <= 0 And $Result[$i] = 1 And $BarrackTimeRemain[$i] > 120 Then $j += 1 ; Not Boosted and working Total Time > 120's
					Next

					; Only proceeds with this routine IF ALL Boosted Barracks are empty and ONE Barrack unboosted working
					; $z = 0 ALL Boosted barrcaks are empty $j > 0 Exist a Unboosted Barrack working
					; OR The total of Barrack unboosted are > Empty Boosted Barracks
					If ($z = 0 And $j > 0) Or ($j > $z) Then
						Setlog(" » NB Boosted'n'Empty: " & $l & "| Unboosted'n'Empty: " & $n & "| Unboosted'n'Working :" & $j)
						Setlog(" »» Let's Recalculate Troops!")
						TrainNormalTroops() ; Will Recalculate All Normal troops and distribute from the Barracks again | Only Normal barracks
					EndIf
				ElseIf $BarrackStatus[$brrNum - 1] = False And $fullarmy = False And _
						$BarrackCapacity[$brrNum - 1] = _ArrayMin($BarrackCapacity, 1) And _
						_ArrayMin($BarrackCapacity, 1) + 10 <= _ArrayMax($BarrackCapacity, 1) And _
						$LetsSortNB = False And _ArrayMax($QuantNormalTroopsInQueue, 1) > 1 Then

					For $i = 0 To ($numBarracksAvaiables - 1)
						If $QuantNormalTroopsInQueue[$i] > 1 Then Setlog("Quant queued troops on Barrack " & $i + 1 & " is " & $QuantNormalTroopsInQueue[$i], $COLOR_RED)
					Next

					; ($checkTrainPage = True, $showlog = False, $CNormalBarrack = True, $CDarkBarrack = False)
					$Result = CheckBarrackStatus(True, False, True, False)

					Local $m = 0, $l = 0, $j = 0
					For $i = 0 To ($numBarracksAvaiables - 1)
						If $Result[$i] = 1 And $BarrackTimeRemain[$i] <= 180 Then $m += 1
						If $Result[$i] = 0 Then $l += 1
						If $Result[$i] = 1 And $BarrackTimeRemain[$i] > 180 Then $j += 1
					Next

					If $j >= $l + $m Then
						Setlog(" » NB Empty Barracks: " & $l & "| Almost Empty: " & $m & "| Working :" & $j)
						Setlog(" »» Let's Recalculate Troops!")
						TrainNormalTroops() ; Will Recalculate All Normal troops and distribute from the Barracks again | Only Normal barracks
					EndIf
				EndIf


;~ 				;#################################################################################################################################

				; If The remaining capacity is lower than the Housing Space of training troop and its not full army or first start then delete the training troop
				; and train remain camp capacity with archer OR
				; If no troops are being trained in all barracks and its not full army or first start then train remain camp capacity with archer
				If ($BarrackFull[0] = True Or $BarrackStatus[0] = False) And _
						($BarrackFull[1] = True Or $BarrackStatus[1] = False) And _
						($BarrackFull[2] = True Or $BarrackStatus[2] = False) And _
						($BarrackFull[3] = True Or $BarrackStatus[3] = False) And $fullarmy = False Then

					; Ok all Barracks are empty or remaining capacity is lower than the Housing Space , BUT will we need Dark Troops? let check that!!
					If (Not $isDarkBuild) Or $icmbDarkTroopComp = 3 Or _ 	 						 ; Dark Barrcaks are not in use
							(($BarrackDarkStatus[0] = False Or $BarrackDarkFull[0] = True) And _ 	 ; Dark Barrack 1 is being used and is empty | not training any Dark troop
							($BarrackDarkStatus[1] = False Or $BarrackDarkFull[1] = True)) Then ; Dark Barrack 2 is being used and is empty | not training any Dark troop

						If $BarrackFull[0] = True Or $BarrackFull[1] = True Or $BarrackFull[2] = True Or $BarrackFull[3] = True Then
							GoesToFirstBarrack()
							If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
							If $debugsetlogTrain = 1 Then Setlog(" » Deleting Queue Troops")
							If $iChkDontRemove = 0 Then DeleteQueueTroops()
							GoesToArmyOverViewWindow()
							If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
							If IsTrainPage() Then GetArmyCapacity()
							If $fullarmy = False Then
								; JUST in case of any error of last queued troops on Barracks are Higher than remaning Army camp space
								Local $LocaRemainSpaceToMake = $TotalCamp - $CurCamp
								Assign("CurArch", $LocaRemainSpaceToMake)
								$fullarmy = False
								If $LocaRemainSpaceToMake > 0 Then Setlog("[NB" & $brrNum & "] | last queued troops on Barrcaks are Higher than remaning Space!")
								ExitLoop
							EndIf
							$fullarmy = False
							GoesToNorMalBarrack($brrNum - 1)
						Else
							If ($BarrackDarkStatus[0] = False And $BarrackDarkStatus[1] = False) Then
								GoesToArmyOverViewWindow()
								If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
								If IsTrainPage() Then GetArmyCapacity()
								If $fullarmy = False Then
									; JUST in case of Empty barracks and is not Full Army yet
									Local $LocaRemainSpaceToMake = $TotalCamp - $CurCamp
									; In case of some error on Making troops before attack
									If $LocaRemainSpaceToMake < $TotalCamp / 2 Then
										Assign("CurArch", $LocaRemainSpaceToMake)
										If $LocaRemainSpaceToMake > 0 Then Setlog("[NB" & $brrNum & "] | Empty barracks and is not Full Army yet!")
										ExitLoop
									Else
										TrainNormalTroops() ; Will Recalculate All Normal troops and distribute from the Barracks again | Only Normal barracks
										If $isDarkBuild Then TrainDarkTroops()
									EndIf
								EndIf
								$fullarmy = False
								GoesToNorMalBarrack($brrNum - 1)
							EndIf
						EndIf
					EndIf

				EndIf

				If $RunState = False Then Return
				If Not (IsTrainPage()) Then Return ;exit from train
				Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity

				$TroopCapacityAfterTraining = getBarrackArmy(520, 275)
				$TotalTime = getBarracksTotalTime(632, 202)

				If IsArray($TroopCapacityAfterTraining) And $TroopCapacityAfterTraining[0] <> "" Then
					$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
					$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
				Else
					$BarrackStatusTrain[0] = 0
					$BarrackStatusTrain[1] = 0
				EndIf

				$BarrackStatusTrain[2] = $BarrackCapacity[$BarrackToTrain]

				If IsArray($TotalTime) And $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
					$BarrackStatusTrain[3] = $TotalTime[0]
					If $InitBoostTime[$BarrackToTrain][1] > 0 Then
						$BarrackTimeRemain[$BarrackToTrain] = Ceiling($TotalTime[1] / 4)
					Else
						$BarrackTimeRemain[$BarrackToTrain] = Ceiling($TotalTime[1])
					EndIf
				Else
					$BarrackStatusTrain[3] = 0
					$BarrackTimeRemain[$BarrackToTrain] = 0
				EndIf

				If $InitBoostTime[$BarrackToTrain][1] > 0 Then
					SetLog(" »» NB[" & $BarrackToTrain + 1 & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantNormalTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3] & " [B]", $COLOR_BLUE)
				Else
					SetLog(" » NB[" & $BarrackToTrain + 1 & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantNormalTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3], $COLOR_BLUE)
				EndIf
				If _Sleep($iDelayTrain2) Then Return

				; Just in case of some OCR fail , Or Train Click
				If $brrNum >= $numBarracksAvaiables Then
					; Just in case of OCR fail on troopSecond :
					If $BarrackStatusTrain[0] = $BarrackStatusTrain[1] Or _ ; In case of Regular Train loop example : 200/200
							$BarrackStatusTrain[0] * 2 = $BarrackStatusTrain[1] Then ; in case of train before Attack , example : 400/200
						For $i = 0 To UBound($TroopName) - 1
							If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopName[$i], $COLOR_PURPLE)
							Assign("Cur" & $TroopName[$i], 0)
							Assign("Don" & $TroopName[$i], 0)
						Next
						For $i = 0 To UBound($TroopDarkName) - 1
							If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
							Assign("Cur" & $TroopDarkName[$i], 0)
							Assign("Don" & $TroopDarkName[$i], 0)
						Next
					EndIf
				EndIf

			EndIf
			; Goes to another barrack proceding with the barracks loop
			If Not (IsTrainPage()) Then Return
			If $brrNum >= $numBarracksAvaiables Then ExitLoop ; make sure no more infiniti loop
			_TrainMoveBtn(+1) ;click Next button
			If _Sleep($iDelayTrain2) Then Return
			checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page
		WEnd
	EndIf

	; ############################################################################################################################################
	; ############################################################ Train Dark Barrack MODE #######################################################
	; ############################################################################################################################################

	If $isDarkBuild Or $icmbDarkTroopComp = 0 Then
		Local $iBarrHere = 0
		$brrDarkNum = 0
		If $icmbDarkTroopComp = 0 Then
			If $debugsetlogTrain = 1 Then
				Setlog("", $COLOR_PURPLE)
				SetLog("---------TRAIN DARK BARRACK MODE------------------------", $COLOR_PURPLE)
			EndIf
			If _Sleep($iDelayTrain2) Then Return
			;USE BARRACK
			While isDarkBarrack() = False
				If Not (IsTrainPage()) Then Return
				_TrainMoveBtn(+1) ;click Next button
				$iBarrHere += 1
				If _Sleep($iDelayTrain3) Then Return
				If (isDarkBarrack() Or $iBarrHere = 8) Then ExitLoop
			WEnd
			While isDarkBarrack()
				$brrDarkNum += 1
				_CaptureRegion()
				If $FirstStart Then
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
					If $iChkDontRemove = 0 Then
						$icount = 0
						While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
							If Not (IsTrainPage()) Then Return
							Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0273") ; Remove Troops in training
							$icount += 1
							If $icount = 100 Then ExitLoop
							If $RunState = False Then Return
						WEnd
						If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 6", $COLOR_PURPLE)
					EndIf
				EndIf
				If _Sleep($iDelayTrain2) Then ExitLoop
				If Not (IsTrainPage()) Then Return ; exit from train if no train page
				Switch $darkbarrackTroop[$brrDarkNum - 1]
					Case 0
						TrainClick(220, 320 + $midOffsetY, 50, $isldTrainITDelay, $FullMini, $GemMini, "#0274", $TrainMiniRND) ; Minion
					Case 1
						TrainClick(331, 320 + $midOffsetY, 20, $isldTrainITDelay, $FullHogs, $GemHogs, "#0275", $TrainHogsRND) ; Hog Rider
					Case 2
						TrainClick(432, 320 + $midOffsetY, 12, $isldTrainITDelay, $FullValk, $GemValk, "#0276", $TrainValkRND) ; Valkyrie
					Case 3
						TrainClick(546, 320 + $midOffsetY, 3, $isldTrainITDelay, $FullGole, $GemGole, "#0277", $TrainGoleRND) ; Golem
					Case 4
						TrainClick(647, 320 + $midOffsetY, 8, $isldTrainITDelay, $FullWitc, $GemWitc, "#0278", $TrainWitcRND) ; Witch
					Case 5
						TrainClick(220, 425 + $midOffsetY, 3, $isldTrainITDelay, $FullBall, $GemBall, "#0279", $TrainLavaRND) ; Lava Hound
					Case 6
						TrainClick(331, 425 + $midOffsetY, 16, $isldTrainITDelay, $FullBowl, $GemBowl, "#0341", $TrainBowlRND) ; Bowler
				EndSwitch

				If $OutOfElixir = 1 Then
					Setlog("Not enough Dark Elixir to train troops!", $COLOR_RED)
					Setlog("Switching to Halt Attack, Stay Online Mode...", $COLOR_RED)
					$ichkBotStop = 1 ; set halt attack variable
					$icmbBotCond = 18 ; set stay online
					If CheckFullBarrack() Then $Restart = True ;If the army camp is full, use it to refill storages
					Return ; We are out of Elixir stop training.
				EndIf

				If Not (IsTrainPage()) Then Return
				If $brrDarkNum >= $numDarkBarracksAvaiables Then ExitLoop
				_TrainMoveBtn(+1) ;click Next button
				If _Sleep($iDelayTrain2) Then Return
			WEnd
		Else

			; ############################################################################################################################################
			; ############################################################ Train Custom Dark Troops ######################################################
			; ############################################################################################################################################

			While isDarkBarrack() = False
				If Not (IsTrainPage()) Then Return
				_TrainMoveBtn(+1) ;click Next button
				$iBarrHere += 1
				If _Sleep($iDelayTrain2) Then Return
				If (isDarkBarrack() Or $iBarrHere = 8) Then ExitLoop
			WEnd
			While isDarkBarrack()
				Local $Result = ""
				Local $TroopCapacityAfterTraining = ""
				Local $TotalTime = ""
				$brrDarkNum += 1
				Local $BarrackToTrain = $brrDarkNum - 1
				For $i = 0 To UBound($TroopDarkName) - 1
					Assign(("troopFirst" & $TroopDarkName[$i]), 0)
					Assign(("troopSecond" & $TroopDarkName[$i]), 0)
				Next
				If $debugsetlogTrain = 1 Then SetLog("====== Checking available Dark Barrack: " & $brrDarkNum & " ======", $COLOR_PURPLE)
				If $fullarmy Or $FirstStart Then ; Delete Troops That is being trained
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
					If $iChkDontRemove = 0 Then
						$icount = 0
						While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
							If Not (IsTrainPage()) Then Return ;exit if no train page
							Click(568, 177 + $midOffsetY, $isldTrainITDelay, 0, "#0287") ; Remove Troops in training
							$icount += 1
							If $icount = 100 Then ExitLoop
							If $RunState = False Then Return
						WEnd
						If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 9", $COLOR_PURPLE)
					EndIf
				EndIf

				;If _Sleep($iDelayTrain4) Then Return

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

				;Too few troops, train first
				For $i = 0 To UBound($TroopDarkName) - 1
					Local $plural = 0
					If Eval("tooFew" & $TroopDarkName[$i]) = 1 And Eval("Cur" & $TroopDarkName[$i]) > 0 Then
						If Not (IsTrainPage()) Then Return ;exit from train
						If $RunState = False Then Return ; Bot stops
						If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

						; loop on all $DtroopsToMake to macth the troops name and TrainIT
						For $x = 0 To UBound($DtroopsToMake) - 1
							If $DtroopsToMake[$x][0] = $TroopDarkName[$i] And Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
								TrainIt(Eval("e" & $DtroopsToMake[$x][0]), Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
								$BarrackDarkStatus[$BarrackToTrain] = True
								If Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 1 Then $plural = 1
								If $debugsetlogTrain = 1 Then SetLog("[DB" & $BarrackToTrain + 1 & "] » tooFew|TrainIt Click " & Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), $plural), $COLOR_GREEN)
							EndIf
						Next
					EndIf
				Next

				For $i = 0 To UBound($TroopDarkName) - 1
					Local $plural = 0
					; Only runs loops on Existing GUI Custom Troops with positive $Cur
					; $Cur|TroopName will be updated forward in the line 670 with $troopSecond|TroopName , removing the quantity troops made in the current barrack
					If Eval("Cur" & $TroopDarkName[$i]) > 0 And Eval("tooFew" & $TroopDarkName[$i]) = 0 And Eval("tooMany" & $TroopDarkName[$i]) = 0 Then

						If Not (IsTrainPage()) Then Return ;exit from train
						If $RunState = False Then Return ; Bot stops
						If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

						; loop on all $TroopsToMake to macth the troops name and TrainIT
						For $x = 0 To UBound($DtroopsToMake) - 1
							If $DtroopsToMake[$x][0] = $TroopDarkName[$i] And Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
								TrainIt(Eval("e" & $DtroopsToMake[$x][0]), Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
								$BarrackDarkStatus[$BarrackToTrain] = True
								If Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 1 Then $plural = 1
								If $debugsetlogTrain = 1 Then SetLog("[DB" & $BarrackToTrain + 1 & "] » TrainIt Click " & Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), $plural), $COLOR_GREEN)
							EndIf
						Next
					EndIf
				Next

				;Too Many troops, train Last
				For $i = 0 To UBound($TroopDarkName) - 1 ; put troops at end of queue if there are too many
					If Eval("tooMany" & $TroopDarkName[$i]) = 1 Then
						If Not (IsTrainPage()) Then Return ;exit from train
						If $RunState = False Then Return ; Bot stops
						If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action

						; loop on all $TroopsToMake to macth the troops name and TrainIT
						For $x = 0 To UBound($DtroopsToMake) - 1
							If $DtroopsToMake[$x][0] = $TroopDarkName[$i] And Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
								TrainIt(Eval("e" & $DtroopsToMake[$x][0]), Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
								$BarrackDarkStatus[$BarrackToTrain] = True
								If $debugsetlogTrain = 1 Then SetLog("[DB" & $BarrackToTrain + 1 & "] » tooMany|TrainIt Click " & Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), 1), $COLOR_GREEN)
							EndIf
						Next
					EndIf
				Next

				; Just a Setlog with each Barrack remain train times
				If $IsFullArmywithHeroesAndSpells = True Or $FirstStart = True Then Setlog("Dark Barrack nº " & $BarrackToTrain + 1 & " with remain train of " & Sec2Time($BarrackDarkTotalStatus[$BarrackToTrain][0]), $COLOR_GREEN)

				If _Sleep($iDelayTrain4) Then Return

				$QuantDarkTroopsInQueue[$BarrackToTrain] = 0
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

						; Just in case of OCR fail
						If $tmpNumber = 0 And Eval("troopFirst" & $TroopDarkName[$i]) <> 0 And Eval($TroopDarkName[$i] & "EBarrack" & $BarrackToTrain) > 0 Then
							Local $g = 0
							While $tmpNumber = 0
								If _Sleep($iDelayTrain2) Then Return ; just a delay | ocr | 500ms
								$tmpNumber = Number(getBarracksTroopQuantity(174 + 107 * $positionTroop, $heightTroop))
								Assign(("troopSecond" & $TroopDarkName[$i]), $tmpNumber)
								$g += 1
								If $g = 60 Then ExitLoop
								If $RunState = False Then Return
							WEnd
							If $g >= 1 Then SetLog(("[DB" & $brrDarkNum & "] » ASSIGN $troopSecond" & $TroopDarkName[$i] & " FAIL | attempts: " & $g), $COLOR_RED)
						EndIf
						$QuantDarkTroopsInQueue[$BarrackToTrain] += $tmpNumber
						Local $QuantyMade = Eval("troopSecond" & $TroopDarkName[$i]) - Eval("troopFirst" & $TroopDarkName[$i])
						If $QuantyMade > 0 Then SetLog("[NB" & $BarrackToTrain + 1 & "] » Trained " & $QuantyMade & " " & NameOfTroop(Eval("e" & $TroopDarkName[$i]), 1), $COLOR_GREEN)
					EndIf
					If $RunState = False Then Return
				Next

				For $i = 0 To UBound($TroopDarkName) - 1
					If Eval("troopSecond" & $TroopDarkName[$i]) > Eval("troopFirst" & $TroopDarkName[$i]) And Eval($TroopDarkName[$i] & "Comp") <> "0" Then
						If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
						$ArmyComp += (Eval("troopSecond" & $TroopDarkName[$i]) - Eval("troopFirst" & $TroopDarkName[$i])) * $TroopDarkHeight[$i]
						If $debugsetlogTrain = 1 Then SetLog(" » ASSIGN after $troopSecond - $Cur" & $TroopDarkName[$i] & " = " & Eval("Cur" & $TroopDarkName[$i]) & " - (" & Eval("troopSecond" & $TroopDarkName[$i]) & " - " & Eval("troopFirst" & $TroopDarkName[$i]) & ")", $COLOR_PURPLE)
						Assign(("Cur" & $TroopDarkName[$i]), Eval("Cur" & $TroopDarkName[$i]) - (Eval("troopSecond" & $TroopDarkName[$i]) - Eval("troopFirst" & $TroopDarkName[$i])))
						If Eval("Cur" & $TroopDarkName[$i]) <= 0 Then Setlog(" » The " & NameOfTroop(Eval("e" & $TroopDarkName[$i]), 1) & " are all done!", $COLOR_BLUE)
					EndIf
				Next

				If $IsFullArmywithHeroesAndSpells = True Or $FirstStart Then

					Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity

					$TroopCapacityAfterTraining = getBarrackArmy(520, 275)
					$TotalTime = getBarracksTotalTime(632, 202)

					If IsArray($TroopCapacityAfterTraining) And $TroopCapacityAfterTraining[0] <> "" Then
						$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
						$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
					Else
						$BarrackStatusTrain[0] = 0
						$BarrackStatusTrain[1] = 0
					EndIf

					$BarrackStatusTrain[2] = $DarkBarrackCapacity[$BarrackToTrain]

					If IsArray($TotalTime) And $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
						$BarrackStatusTrain[3] = $TotalTime[0]
						If $InitBoostTimeDark[$BarrackToTrain][1] > 0 Then
							$DarkBarrackTimeRemain[$BarrackToTrain] = $TotalTime[1] / 4
						Else
							$DarkBarrackTimeRemain[$BarrackToTrain] = $TotalTime[1]
						EndIf
					Else
						$BarrackStatusTrain[3] = 0
						$DarkBarrackTimeRemain[$BarrackToTrain] = 0
					EndIf

					If $InitBoostTimeDark[$BarrackToTrain][1] > 0 Then
						SetLog(" »» DB[" & $brrDarkNum & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantDarkTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3] & " [B]", $COLOR_BLUE)
					Else
						SetLog(" » DB[" & $brrDarkNum & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantDarkTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3], $COLOR_BLUE)
					EndIf
					If _Sleep($iDelayTrain2) Then Return
				EndIf

				; Just in case of some OCR fail , Or Train Click
				If $brrDarkNum >= $numDarkBarracksAvaiables Then
					; Just in case of OCR fail on troopSecond :
					If $BarrackStatusTrain[0] = $BarrackStatusTrain[1] Or _ ; In case of Regular Train loop example : 200/200
							$BarrackStatusTrain[0] * 2 = $BarrackStatusTrain[1] Then ; in case of train before Attack , example : 400/200
						For $i = 0 To UBound($TroopName) - 1
							If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopName[$i], $COLOR_PURPLE)
							Assign("Cur" & $TroopName[$i], 0)
							Assign("Don" & $TroopName[$i], 0)
						Next
						For $i = 0 To UBound($TroopDarkName) - 1
							If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
							Assign("Cur" & $TroopDarkName[$i], 0)
							Assign("Don" & $TroopDarkName[$i], 0)
						Next
					EndIf
				EndIf

				; The Important stage | will make the donated troops , check if exist some errors on train troops | When is not full Army and Not First Start

				If $icmbTroopComp <> 8 And $IsFullArmywithHeroesAndSpells = False And $FirstStart = False Then

					; Train the Donated Dark Troops :

					For $i = 0 To UBound($TroopDarkName) - 1
						; Only runs loops with positive $DonTroopName
						If Eval("Don" & $TroopDarkName[$i]) > 0 Then
							If Not (IsTrainPage()) Then Return ;exit from train
							If $RunState = False Then Return ; Bot stopped
							; loop on all $TroopsToMake to macth the troops name and TrainIT
							For $x = 0 To UBound($DtroopsToMake) - 1
								If $DtroopsToMake[$x][0] = $TroopDarkName[$i] And Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) > 0 Then
									If _Sleep($iDelayTrain6) Then Return ; '20' just to Pause action
									TrainIt(Eval("e" & $DtroopsToMake[$x][0]), Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain), $isldTrainITDelay)
									$QuantDarkTroopsInQueue[$BarrackToTrain] += Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain)
									$BarrackDarkStatus[$BarrackToTrain] = True
									SetLog("[DB" & $BarrackToTrain + 1 & "] » Trained " & Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain) & " " & NameOfTroop(Eval("e" & $DtroopsToMake[$x][0]), 1), $COLOR_GREEN)
									Assign("Don" & $TroopDarkName[$i], Eval("Don" & $TroopDarkName[$i]) - Eval($DtroopsToMake[$x][0] & "EBarrack" & $BarrackToTrain))
								EndIf
							Next
						EndIf
					Next

					; Checks if there is Troops being trained in this barrack
					; if exist green arrow

					If $QuantDarkTroopsInQueue[$BarrackToTrain] <> 0 Or _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xa8d070, 6), 20) = True Or _
							_ColorCheck(_GetPixelColor(649, 243 + $midOffsetY, True), Hex(0x60ad20, 6), 20) = True Then
						$BarrackDarkStatus[$BarrackToTrain] = True ; Troops are being trained in this barrack
						If $debugsetlogTrain = 1 Then
							Local $BarrackDarkStatusColor = _GetPixelColor(599, 202 + $midOffsetY, True)
							Local $BarrackDarkStatusColor2 = _GetPixelColor(649, 243 + $midOffsetY, True)
							If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|Arrow(" & 599 & "," & 202 + $midOffsetY & "): " & $BarrackDarkStatusColor, $COLOR_PURPLE)
							If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|GEM(" & 649 & "," & 243 + $midOffsetY & "): " & $BarrackDarkStatusColor2, $COLOR_PURPLE)
						EndIf
					Else
						$BarrackDarkStatus[$BarrackToTrain] = False ; No troop is being trained in this barrack
						Local $BarrackDarkStatusColor = _GetPixelColor(599, 202 + $midOffsetY, True)
						Local $BarrackDarkStatusColor2 = _GetPixelColor(649, 243 + $midOffsetY, True)
						If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|Arrow(" & 599 & "," & 202 + $midOffsetY & "): " & $BarrackDarkStatusColor, $COLOR_PURPLE)
						If $debugsetlogTrain = 1 Then Setlog(" BarrackStatusColor|GEM(" & 649 & "," & 243 + $midOffsetY & "): " & $BarrackDarkStatusColor2, $COLOR_PURPLE)
						SetLog("[NB" & $brrNum & "] » Troops is working? " & $BarrackStatus[$BarrackToTrain], $COLOR_PURPLE)
					EndIf

					; Checks if the Dark barrack is full (stopped)
					If CheckFullBarrack() Then
						$BarrackDarkFull[$BarrackToTrain] = True ; Dark barrack is full
						SetLog("[DB" & $brrDarkNum & "] » Queue troops and stopped!", $COLOR_PURPLE)
					Else
						$BarrackDarkFull[$BarrackToTrain] = False ; Dark barrack isn't full
					EndIf

					If $InitBoostTimeDark[$BarrackToTrain][1] > 0 And $BarrackDarkStatus[$BarrackToTrain] = False And $fullarmy = False And _ArrayMax($QuantDarkTroopsInQueue, 1) > 1 Then
						If _Sleep($iDelayTrain4) Then Return
						; ($checkTrainPage = True, $showlog = False, $CNormalBarrack = False, $CDarkBarrack = True)
						$Result = CheckBarrackStatus(True, False, False, True)
						$TrainNormalTroopsInprogress = BitAND($BarrackStatus[0], $BarrackStatus[1], $BarrackStatus[1], $BarrackStatus[1])

						Local $z = 0, $m = 0, $n = 0, $l = 0
						For $i = 0 To ($numDarkBarracksAvaiables - 1)
							If $InitBoostTimeDark[$i][1] > 0 And $Result[$i] = 1 Then $z += 1 ; WORKING And BOOSTED
							If $InitBoostTimeDark[$i][1] > 0 And $Result[$i] = 1 And $DarkBarrackTimeRemain[$i] < 60 Then $m += 1 ; boosted but Total Time < 60's
							If $InitBoostTimeDark[$i][1] > 0 And $Result[$i] = 0 Then $l += 1 ; BOOSTED and EMTPY
							If $InitBoostTimeDark[$i][1] <= 0 And $Result[$i] = 1 Then $n += 1 ; Not Boosted and WORKING
						Next

						; Only proceeds with this routine IF ALL Boosted Barracks are empty and ONE Barrack unboosted working
						If $n = 1 And $l = 1 Then
							Setlog(" » DB Boosted'n'Empty: " & $l & "| Dark'n'Working: " & $n & "| Boosted'n'Allmost :" & $m)
							Setlog(" »» Let's Recalculate Troops!")
							TrainDarkTroops() ; Will Recalculate All 'Dark troops' and distribute from the Dark Barracks again | Only Dark barracks
						EndIf

					EndIf

					; If The remaining capacity is lower than the Housing Space of training dark troop and its not full army or first start then delete the training troop
					; and train remain camp capacity with minions OR
					; If no troops are being trained in all barracks and its not full army or first start then train remain camp capacity with minions

					If (($BarrackDarkFull[0] = True Or $BarrackDarkStatus[0] = False) And _
							($BarrackDarkFull[1] = True Or $BarrackDarkStatus[1] = False)) And $fullarmy = False Then

						If $BarrackDarkFull[0] = True Or $BarrackDarkFull[1] = True Then
							GoesToFirstBarrack()
							If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
							If $debugsetlogTrain = 1 Then Setlog(" » Deleting Queue Troops to fill the remain space!")
							If $iChkDontRemove = 0 Then DeleteQueueTroops()
							If $iChkDontRemove = 0 Then DeleteQueueDarkTroops()
							GoesToArmyOverViewWindow()
							If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
							If IsTrainPage() Then GetArmyCapacity()

							; JUST in case of any error of last queued troops on Barracks are Higher than remaning Army camp space
							Local $LocaRemainSpaceToMake = $TotalCamp - $CurCamp
							For $i = 0 To UBound($TroopDarkName) - 1 Step -1
								If Eval($TroopDarkName[$i] & "comp") <> "0" Then
									For $x = 0 To $LocaRemainSpaceToMake
										If $TroopDarkHeight[$i] <= $LocaRemainSpaceToMake Then
											Assign("Cur" & $TroopDarkName[$i], 1)
											$LocaRemainSpaceToMake -= $TroopDarkHeight[$i]
											If $LocaRemainSpaceToMake = 0 Then ExitLoop (2)
										Else
											ExitLoop
										EndIf
									Next
								EndIf
							Next
							If $LocaRemainSpaceToMake > 0 Then Assign("CurArch", $LocaRemainSpaceToMake)
							$fullarmy = False
							GoesToDarkBarrack($brrDarkNum - 1)

						ElseIf $isNormalBuild = False And $BarrackDarkStatus[0] = False And $BarrackDarkStatus[1] = False Then
							GoesToArmyOverViewWindow()
							If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
							If IsTrainPage() Then GetArmyCapacity()

							; JUST in case of Empty barracks and is not Full Army yet
							Setlog(" » Empty Dark barracks and is not Full Army yet!")
							Local $LocaRemainSpaceToMake = $TotalCamp - $CurCamp
							For $i = 0 To UBound($TroopDarkName) - 1 Step -1
								If Eval($TroopDarkName[$i] & "comp") <> "0" Then
									For $x = 0 To $LocaRemainSpaceToMake
										If $TroopDarkHeight[$i] <= $LocaRemainSpaceToMake Then
											Assign("Cur" & $TroopDarkName[$i], 1)
											$LocaRemainSpaceToMake -= $TroopDarkHeight[$i]
											If $LocaRemainSpaceToMake = 0 Then ExitLoop (2)
										Else
											ExitLoop
										EndIf
									Next
								EndIf
							Next
							If $LocaRemainSpaceToMake > 0 Then Assign("CurArch", $LocaRemainSpaceToMake)
							$fullarmy = False
							GoesToDarkBarrack($brrDarkNum - 1)
						EndIf
					EndIf


					Local $BarrackStatusTrain[4] ; [0] is Troops Capacity after training , [1] Total Army capacity , [3] Total Time , [4] Barrack capacity

					$TroopCapacityAfterTraining = getBarrackArmy(520, 275)
					$TotalTime = getBarracksTotalTime(632, 202)

					If IsArray($TroopCapacityAfterTraining) And $TroopCapacityAfterTraining[0] <> "" Then
						$BarrackStatusTrain[0] = $TroopCapacityAfterTraining[0]
						$BarrackStatusTrain[1] = $TroopCapacityAfterTraining[1]
					Else
						$BarrackStatusTrain[0] = 0
						$BarrackStatusTrain[1] = 0
					EndIf

					$BarrackStatusTrain[2] = $DarkBarrackCapacity[$BarrackToTrain]

					If IsArray($TotalTime) And $TotalTime[0] <> "" And $TotalTime[0] <> -1 Then
						$BarrackStatusTrain[3] = $TotalTime[0]
						If $InitBoostTimeDark[$BarrackToTrain][1] > 0 Then
							$DarkBarrackTimeRemain[$BarrackToTrain] = $TotalTime[1] / 4
						Else
							$DarkBarrackTimeRemain[$BarrackToTrain] = $TotalTime[1]
						EndIf
					Else
						$BarrackStatusTrain[3] = 0
						$DarkBarrackTimeRemain[$BarrackToTrain] = 0
					EndIf

					If $InitBoostTimeDark[$BarrackToTrain][1] > 0 Then
						SetLog(" »» DB[" & $brrDarkNum & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantDarkTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3] & " [B]", $COLOR_BLUE)
					Else
						SetLog(" » DB[" & $brrDarkNum & "] Max Cap: " & $BarrackStatusTrain[2] & " | " & $BarrackStatusTrain[0] & "/" & $BarrackStatusTrain[1] & " | Q: " & $QuantDarkTroopsInQueue[$BarrackToTrain] & " | Total Time: " & $BarrackStatusTrain[3], $COLOR_BLUE)
					EndIf
					If _Sleep($iDelayTrain2) Then Return

					; Just in case of some OCR fail , Or Train Click
					If $brrDarkNum >= $numDarkBarracksAvaiables Then
						; Just in case of OCR fail on troopSecond :
						If $BarrackStatusTrain[0] = $BarrackStatusTrain[1] Or _ ; In case of Regular Train loop example : 200/200
								$BarrackStatusTrain[0] * 2 = $BarrackStatusTrain[1] Then ; in case of train before Attack , example : 400/200
							For $i = 0 To UBound($TroopName) - 1
								If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopName[$i], $COLOR_PURPLE)
								Assign("Cur" & $TroopName[$i], 0)
								Assign("Don" & $TroopName[$i], 0)
							Next
							For $i = 0 To UBound($TroopDarkName) - 1
								If $debugsetlogTrain = 1 Then SetLog("Reset the $Don|$Cur" & $TroopDarkName[$i], $COLOR_PURPLE)
								Assign("Cur" & $TroopDarkName[$i], 0)
								Assign("Don" & $TroopDarkName[$i], 0)
							Next
						EndIf
					EndIf

				EndIf
				If Not (IsTrainPage()) Then Return
				$icount = 0
				If $brrDarkNum >= $numDarkBarracksAvaiables Then ExitLoop ; make sure no more infiniti loop
				_TrainMoveBtn(+1) ;click Next button
				If _Sleep($iDelayTrain2) Then Return
			WEnd

		EndIf
	EndIf

	If $debugsetlogTrain = 1 Then SetLog("---============== END TRAIN =============---", $COLOR_PURPLE)

	; ############################################################################################################################################
	; ##############################################################  Train SPELLS ###############################################################
	; ############################################################################################################################################

	If _Sleep($iDelayTrain4) Then Return

	If $IsFullArmywithHeroesAndSpells = False And $iTotalCountSpell > 0 Then
		SetLog(" »» Let's Obtain count of spells available:", $COLOR_GREEN)
		If IsTrainPage() Then GoesToArmyOverViewWindow()
		If _Sleep($iDelayTrain3) Then Return
		If IsTrainPage() = True Then getArmySpellCount() ; This will Check The Current Spells
		If _Sleep($iDelayTrain4) Then Return
		If $Trainavailable[7] = 1 Then
			If _Sleep($iDelayTrain2) Then Return
			Click($btnpos[7][0], $btnpos[7][1], 1, $iDelayTrain5) ; Click on tab and go to Spells Factory
		Else
			If $Trainavailable[8] = 1 Then
				If _Sleep($iDelayTrain2) Then Return
				Click($btnpos[8][0], $btnpos[8][1], 1, $iDelayTrain5) ; Click on tab and go to Dark Spells Factory
			EndIf
		EndIf
		If _Sleep($iDelayTrain3) Then Return
		BrewSpells() ; Create Spells

	Else
		BrewSpells() ; Create Spells
	EndIf


	If _Sleep($iDelayTrain4) Then Return
	ClickP($aAway, 2, $iDelayTrain5, "#0504") ; Click away twice with 250ms delay
	$FirstStart = False

	; ############################################################################################################################################
	; ############################################################ Update Cost Values ############################################################
	; ############################################################################################################################################

	;;;;;; Protect Army cost stats from being missed up by DC and other errors ;;;;;;;
	If _Sleep($iDelayTrain4) Then Return
	VillageReport(True, True)

	$tempCounter = 0
	While ($iElixirCurrent = "" Or ($iDarkCurrent = "" And $iDarkStart <> "")) And $tempCounter < 30
		$tempCounter += 1
		If _Sleep($iDelayTrain1) Then Return
		VillageReport(True, True)
	WEnd

	If $tempElixir <> "" And $iElixirCurrent <> "" Then
		$tempElixirSpent = ($tempElixir - $iElixirCurrent)
		$iTrainCostElixir += $tempElixirSpent
		$iElixirTotal -= $tempElixirSpent
	EndIf

	If $tempDElixir <> "" And $iDarkCurrent <> "" Then
		$tempDElixirSpent = ($tempDElixir - $iDarkCurrent)
		$iTrainCostDElixir += $tempDElixirSpent
		$iDarkTotal -= $tempDElixirSpent
	EndIf

	UpdateStats()

	checkAttackDisable($iTaBChkIdle) ; Check for Take-A-Break after opening train page

EndFunc   ;==>Train

Func Sec2Time($nr_sec) ; Convert seconds to Time format HH:MM:SS
	$sec2time_hour = Int($nr_sec / 3600)
	$sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
	$sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
	Return StringFormat("%02d:%02d:%02d", $sec2time_hour, $sec2time_min, $sec2time_sec)
EndFunc   ;==>Sec2Time

Func GoesToFirstBarrack() ; Go To the First Normal Barrack Available
	; GO TO First NORMAL BARRACK
	; Find First barrack $i
	Local $Firstbarrack = 0, $i = 1
	While $Firstbarrack = 0 And $i <= 4
		If $Trainavailable[$i] = 1 Then $Firstbarrack = $i
		$i += 1
	WEnd

	If $Firstbarrack = 0 Then
		Setlog("No barrack avaiable, cannot start train")
		Return ;exit from train
	Else
		If $debugsetlogTrain = 1 Then Setlog("First BARRACK = " & $Firstbarrack, $COLOR_PURPLE)
		;GO TO ArmyOver View Window
		Click($btnpos[0][0], $btnpos[0][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
		Local $j = 0
		While Not _ColorCheck(_GetPixelColor($btnpos[0][0], $btnpos[0][1], True), Hex(0xE8E8E0, 6), 20)
			If $debugsetlogTrain = 1 Then Setlog("OverView TabColor=" & _GetPixelColor($btnpos[0][0], $btnpos[0][1], True), $COLOR_PURPLE)
			If _Sleep($iDelayTrain1) Then Return ; wait for Train Window to be ready.
			$j += 1
			If $j > 15 Then ExitLoop
		WEnd
		If $j > 15 Then
			SetLog("Training Overview Window didn't open", $COLOR_RED)
			Return
		EndIf
		;GO TO First BARRACK
		If Not (IsTrainPage()) Then Return ;exit if no train page
		Click($btnpos[$Firstbarrack][0], $btnpos[$Firstbarrack][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
		Local $j = 0
		While Not _ColorCheck(_GetPixelColor($btnpos[$Firstbarrack][0], $btnpos[$Firstbarrack][1], True), Hex(0xE8E8E0, 6), 20)
			If $debugsetlogTrain = 1 Then Setlog("First Barrack TabColor=" & _GetPixelColor($btnpos[$Firstbarrack][0], $btnpos[$Firstbarrack][1], True), $COLOR_PURPLE)
			If _Sleep($iDelayTrain1) Then Return
			$j += 1
			If $j > 15 Then ExitLoop
		WEnd
		If $j > 15 Then
			SetLog("some error occurred, cannot open barrack", $COLOR_RED)
		EndIf
	EndIf


EndFunc   ;==>GoesToFirstBarrack

Func GoesToFirstDarkBarrack() ; Go To the First Dark Barrack Available

	If IsTrainPage() Then
		; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
		If $Trainavailable[5] = 1 Then
			Click($btnpos[5][0], $btnpos[5][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
			If _Sleep(1000) Then Return
		Else
			Click($btnpos[6][0], $btnpos[6][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
			If _Sleep(1000) Then Return
		EndIf
	Else
		Setlog(" ERROR YOU ARE NOT IN TRAIN PAGE!!!", $COLOR_RED)
	EndIf

EndFunc   ;==>GoesToFirstDarkBarrack

Func DeleteQueueTroops($getBarrackCapacity = True) ; Delete Queue Troops on Normal Barracks

	If $IsDontRemove = 0 Then SetLog(" »» Deleting Queued Troops!!", $COLOR_PURPLE)
	$brrNum = 0
	While isBarrack()
		;Setlog("While1")
		$brrNum += 1
		$BarrackStatus[$brrNum - 1] = False
		If $debugsetlogTrain = 1 Then SetLog("====== Checking available Barrack: " & $brrNum & " ======", $COLOR_PURPLE)

		;CLICK REMOVE TROOPS
		If _Sleep($iDelayTrain2) Then Return
		$icount = 0
		If _ColorCheck(_GetPixelColor(187, 212, True), Hex(0xD30005, 6), 10) Then ; check if the existe more then 6 slots troops on train bar
			While Not _ColorCheck(_GetPixelColor(573, 212, True), Hex(0xD80001, 6), 10) ; while until appears the Red icon to delete troops
				;Setlog("While 2")
				;_PostMessage_ClickDrag(550, 240, 170, 240, "left", 1000)
				ClickDrag(550, 240, 170, 240, 1000)
				$icount += 1
				If _Sleep($iDelayTrain2) Then Return
				If $icount = 7 Then ExitLoop
			WEnd
		EndIf
		$icount = 0

		If _Sleep($iDelayTrain2) Then Return

		If $getBarrackCapacity = True Then
			$BarrackCapacity[$brrNum - 1] = getBarrackCapacity(218, 177)
			SetLog(" » Barrack nº " & $brrNum & " Max Capacity is: " & $BarrackCapacity[$brrNum - 1], $COLOR_GREEN)
		EndIf

		If $IsDontRemove = 0 Then
			While Not _ColorCheck(_GetPixelColor(593, 200 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
				;Setlog("While 3")
				If Not (IsTrainPage()) Then Return ;exit if no train page
				Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0284") ; Remove Troops in training
				$icount += 1
				If $RunState = False Then Return
				If $icount = 20 Then ExitLoop
			WEnd
			If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 7", $COLOR_PURPLE)
		EndIf

		If Not (IsTrainPage()) Then Return
		If $brrNum >= $numBarracksAvaiables Then Return ; make sure no more infiniti loop
		_TrainMoveBtn(+1) ;click Next button
		If _Sleep($iDelayTrain2) Then Return
	WEnd

EndFunc   ;==>DeleteQueueTroops

Func DeleteQueueDarkTroops($getBarrackCapacity = True) ; Delete Queue Troops on Dark Barracks

	If $numDarkBarracks = 0 Then Return

	If $IsDontRemove = 0 Then SetLog(" »» Deleting Queued Dark Troops!!", $COLOR_PURPLE)

	Local $iBarrHere = 0
	$brrDarkNum = 0

	While isDarkBarrack() = False
		If Not (IsTrainPage()) Then Return
		_TrainMoveBtn(+1) ;click Next button
		$iBarrHere += 1
		If _Sleep($iDelayTrain3) Then Return
		If (isDarkBarrack() Or $iBarrHere = 8) Then ExitLoop
	WEnd
	While isDarkBarrack()
		$brrDarkNum += 1
		$BarrackDarkStatus[$brrDarkNum - 1] = False
		If $debugsetlogTrain = 1 Then SetLog("====== Checking available Dark Barrack: " & $brrDarkNum & " ======", $COLOR_PURPLE)
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
		EndIf
		$icount = 0

		If $getBarrackCapacity = True Then
			$DarkBarrackCapacity[$brrDarkNum - 1] = getBarrackCapacity(218, 177)
			SetLog(" » Dark Barrack nº " & $brrDarkNum & " Max Capacity is: " & $DarkBarrackCapacity[$brrDarkNum - 1], $COLOR_GREEN)
		EndIf

		If $IsDontRemove = 0 Then
			While Not _ColorCheck(_GetPixelColor(599, 202 + $midOffsetY, True), Hex(0xD0D0C0, 6), 20) ; while not disappears  green arrow
				If Not (IsTrainPage()) Then Return ;exit if no train page
				Click(568, 177 + $midOffsetY, 10, $isldTrainITDelay, "#0287") ; Remove Troops in training
				$icount += 1
				If $icount = 100 Then ExitLoop
				If $RunState = False Then Return
			WEnd
			If $debugsetlogTrain = 1 And $icount = 100 Then SetLog("Train warning 9", $COLOR_PURPLE)
		EndIf

		$icount = 0
		If $brrDarkNum >= $numDarkBarracksAvaiables Then Return ; make sure no more infiniti loop
		_TrainMoveBtn(+1) ;click Next button
		If _Sleep($iDelayTrain2) Then Return
	WEnd

EndFunc   ;==>DeleteQueueDarkTroops

Func getBarrackCapacity($x_start, $y_start) ; Get Barrack Capacity on each Barrack window

	Local $Result = ""
	Local $aGetBarrackSize = 0
	Local $aGetBarrackCapacity = 0
	Local $BarrackCapByLevel[15] = [20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 75, 80, 85, 90, 100]

	For $waiting = 0 To 10
		If getReceivedTroops(162, 200) = False Then
			$Result = getOcrAndCapture("coc-BCapacity", $x_start, $y_start, 60, 17, True)

			If IsString($Result) <> "" And IsString($Result) <> " " Then
				$aGetBarrackSize = StringSplit($Result, "#")
				If $aGetBarrackSize[0] >= 2 Then
					$aGetBarrackCapacity = Number($aGetBarrackSize[2])
				Else
					SetLog("Error Reading the Barrack Capacity", $COLOR_RED)
					$aGetBarrackCapacity = 0
				EndIf
			Else
				If $waiting = 10 Then SetLog("Error Reading the Barrack Capacity", $COLOR_RED)
				$aGetBarrackCapacity = 0
			EndIf
			If _Sleep(500) Then Return
		Else
			If $waiting = 1 Then Setlog("You have received castle troops! Wait 5's...")
			If _Sleep($iDelayTrain8) Then Return
		EndIf
		For $c = 0 To 14
			If $aGetBarrackCapacity = $BarrackCapByLevel[$c] Then ExitLoop (2)
		Next
	Next

	Return $aGetBarrackCapacity

EndFunc   ;==>getBarrackCapacity

Func CheckBarrackBoost($checkTrainPage = True, $showlog = False, $CNormalBarrack = True, $CDarkBarrack = False) ; Check with Pixel Color what barrack was boosted

	If $checkTrainPage = True Then
		If IsTrainPage(False) = False Then openArmyOverview()
		If _Sleep(1000) Then Return
	EndIf

	;                    0  1  2  3  4  1  2  1  1
	; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
	Local $ResultNumBarrackAvailable[$numBarracksAvaiables]
	Local $ResultNumDarkBarrackAvailable[$numDarkBarracksAvaiables]

	Local $ReturnNormal[4]
	$ReturnNormal[0] = IIf(_ColorCheck(_GetPixelColor(250, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #1 Boost Status: " & IIf($InitBoostTime[0][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[1] = IIf(_ColorCheck(_GetPixelColor(310, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #2 Boost Status: " & IIf($InitBoostTime[1][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[2] = IIf(_ColorCheck(_GetPixelColor(370, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #3 Boost Status: " & IIf($InitBoostTime[2][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[3] = IIf(_ColorCheck(_GetPixelColor(430, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #4 Boost Status: " & IIf($InitBoostTime[3][0] = 1, "True", "False"), $COLOR_GREEN)

	$x = 0
	For $i = 0 To 3
		If $Trainavailable[$i + 1] = 1 Then
			$ResultNumBarrackAvailable[$x] = $ReturnNormal[$i]
			$x += 1
		EndIf
	Next

	Local $ReturnDark[2]
	$ReturnDark[0] = IIf(_ColorCheck(_GetPixelColor(516, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("DARK Barrack #1 Boost Status: " & IIf($InitBoostTimeDark[0][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnDark[1] = IIf(_ColorCheck(_GetPixelColor(576, 535 + $midOffsetY, True), Hex(0x75B411, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("DARK Barrack #2 Boost Status: " & IIf($InitBoostTimeDark[1][0] = 1, "True", "False"), $COLOR_GREEN)

	$x = 0
	For $i = 0 To 1
		If $Trainavailable[$i + 5] = 1 Then
			$ResultNumDarkBarrackAvailable[$x] = $ReturnDark[$i]
			$x += 1
		EndIf
	Next

	If $CNormalBarrack = True And $CDarkBarrack = False Then Return $ResultNumBarrackAvailable
	If $CNormalBarrack = False And $CDarkBarrack = True Then Return $ResultNumDarkBarrackAvailable
	If $CNormalBarrack = True And $CDarkBarrack = True Then Return -1 ; don't check both

EndFunc   ;==>CheckBarrackBoost

Func IIf($Condition, $IfTrue, $IfFalse) ; Func used on CheckBarrackBoost()
	If $Condition = True Then
		Return $IfTrue
	Else
		Return $IfFalse
	EndIf
EndFunc   ;==>IIf

Func GoesToArmyOverViewWindow() ; Go To Army OverView Window

	;GO TO ArmyOver View Window
	Click($btnpos[0][0], $btnpos[0][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to last barrack
	Local $j = 0
	While Not _ColorCheck(_GetPixelColor($btnpos[0][0], $btnpos[0][1], True), Hex(0xE8E8E0, 6), 20)
		If $debugsetlogTrain = 1 Then Setlog("OverView TabColor=" & _GetPixelColor($btnpos[0][0], $btnpos[0][1], True), $COLOR_PURPLE)
		If _Sleep($iDelayTrain1) Then Return ; wait for Train Window to be ready.
		$j += 1
		If $j > 15 Then ExitLoop
	WEnd
	If $j > 15 Then
		SetLog("Training Overview Window didn't open", $COLOR_RED)
		Return
	EndIf


EndFunc   ;==>GoesToArmyOverViewWindow

Func getBarrackArmy($x_start, $y_start) ; Get Troops Capacity after train on each Barrack window

	Local $Result = ""
	Local $aGetBarrackSize
	Local $aGetBarrackCapacity[2] = [0, 0]

	If _Sleep(150) Then Return

	For $waiting = 0 To 10
		$Result = getOcrAndCapture("coc-ArmyBarrack", $x_start, $y_start, 65, 10, True)
		If $debugsetlogTrain = 1 Then Setlog($Result)

		If IsString($Result) <> "" And IsString($Result) <> " " Then
			$aGetBarrackSize = StringSplit($Result, "#")
			If $aGetBarrackSize[0] >= 2 Then
				$aGetBarrackCapacity[0] = Number($aGetBarrackSize[1])
				$aGetBarrackCapacity[1] = Number($aGetBarrackSize[2])
				If $debugsetlogTrain = 1 Then Setlog("$waiting getBarrackArmy: " & $waiting)
				ExitLoop
			Else
				If $waiting = 10 Then SetLog("Error Reading the Barrack Capacity", $COLOR_RED)
				$aGetBarrackCapacity[0] = 0
				$aGetBarrackCapacity[1] = 0
			EndIf
		Else
			If $waiting = 10 Then SetLog("Error Reading the Barrack Capacity!", $COLOR_RED)
			$aGetBarrackCapacity[0] = 0
			$aGetBarrackCapacity[1] = 0
		EndIf
		If _Sleep(500) Then Return
	Next

	Return $aGetBarrackCapacity

EndFunc   ;==>getBarrackArmy

Func getBarracksTotalTime($x_start, $y_start) ; Get Total Time on each Barrack Window

	Local $Result = ""
	Local $aGetTime
	Local $aGetTotalTime[2] = ["", 0] ; [0] will be the string to use in a setlog | [1] will be total time in seconds

	If _Sleep($iDelayTrain1) Then Return
	For $waiting = 0 To 10

		If getReceivedTroops(162, 200) = False Then
			$Result = getOcrAndCapture("coc-totaltime", $x_start, $y_start, 76, 18, True)
			If $debugsetlogTrain = 1 Then Setlog("coc-totaltime: " & $Result)

			If IsString($Result) <> "" And IsString($Result) <> " " Then
				If StringInStr($Result, "h") Then ; If exist Hours or only M
					$aGetTime = StringSplit($Result, "h", $STR_NOCOUNT)
					If IsArray($aGetTime) And StringInStr($aGetTime[1], "m") Then
						$aGetTotalTime[0] = $Result
						$aGetTime[1] = StringTrimLeft($aGetTime[1], 1) ; remove the 'm'
						$aGetTotalTime[1] = Ceiling((Number($aGetTime[0]) * 60) * 60 + Ceiling(Number($aGetTime[1]) * 60))
						If $debugsetlogTrain = 1 Then Setlog("$waiting getBarracksTotalTime: " & $waiting)
						ExitLoop
					Else
						If $waiting = 10 Then SetLog("Error Reading the Barrack Total time!", $COLOR_RED)
						$aGetTotalTime[0] = -1
						$aGetTotalTime[1] = 0
						If _Sleep($iDelayTrain3) Then Return
						ContinueLoop
					EndIf
				ElseIf StringInStr($Result, "m") Then ; If exist Minutes or only Seconds
					$aGetTime = StringSplit($Result, "m", $STR_NOCOUNT)
					If IsArray($aGetTime) Then
						$aGetTotalTime[0] = $Result & "s"
						$aGetTotalTime[1] = Ceiling(($aGetTime[0] * 60) + $aGetTime[1])
						If $debugsetlogTrain = 1 Then Setlog("$waiting getBarracksTotalTime: " & $waiting)
						ExitLoop
					Else
						If $waiting = 10 Then SetLog("Error Reading the Barrack Total time!", $COLOR_RED)
						$aGetTotalTime[0] = -1
						$aGetTotalTime[1] = 0
						If _Sleep($iDelayTrain3) Then Return
						ContinueLoop
					EndIf
				Else
					If Number($Result) < 60 Then
						If $Result = "00" Then $Result = 0
						$aGetTotalTime[0] = $Result & "s"
						$aGetTotalTime[1] = Number($Result) ; Only returned the seconds not minutes
						If $debugsetlogTrain = 1 Then Setlog("$waiting getBarracksTotalTime: " & $waiting)
						ExitLoop
					EndIf
				EndIf
			Else
				$aGetTotalTime[0] = ""
				$aGetTotalTime[1] = 0
				If $debugsetlogTrain = 1 Then Setlog("$waiting getBarracksTotalTime: " & $waiting)
			EndIf
		Else
			If $waiting = 1 Then Setlog("You have received castle troops! Wait 5's...")
			If _Sleep($iDelayTrain8) Then Return
		EndIf
		If _Sleep($iDelayTrain3) Then Return
	Next

	Return $aGetTotalTime

EndFunc   ;==>getBarracksTotalTime

Func getBarracksRemaingBoostTime($x_start, $y_start) ;  -> Gets Remaning Boost Time from the Button
	Local $Result = ""
	Local $aGetTime
	Local $aGetTotalTime[2] = ["", 0] ; [0] will be the string to use in a setlog | [1] will be total time in seconds

	$Result = getOcrAndCapture("coc-totalBoostTime", $x_start, $y_start, 58, 15, True)

	If IsString($Result) <> "" Then
		If StringInStr($Result, "m") Then ; If exist Minutes or only Seconds
			$aGetTime = StringSplit($Result, "m", $STR_NOCOUNT)
			If IsArray($aGetTime) Then
				$aGetTotalTime[0] = $Result
				$aGetTotalTime[1] = Ceiling(($aGetTime[0] * 60) + $aGetTime[1])
			Else
				SetLog("Error Reading the Remaing Boost Time!", $COLOR_RED)
				$aGetTotalTime[0] = -1
				$aGetTotalTime[1] = 0
			EndIf

		Else
			$aGetTotalTime[0] = $Result
			$aGetTotalTime[1] = Number($Result) ; Only returned the seconds not minutes
		EndIf
	Else
		SetLog("No Remaning Boost Time, for sure was Boosted?", $COLOR_RED)
		$aGetTotalTime[0] = ""
		$aGetTotalTime[1] = 0
	EndIf

	Return $aGetTotalTime

EndFunc   ;==>getBarracksRemaingBoostTime

Func VerifyRemainBoostTime($BRNum) ; Check with OCR the remain Boost Time on Selected Normal Barrack

	If IsTrainPage() Then ClickP($aAway, 2, 0)
	If _Sleep($iDelayTrain2) Then Return

	SelectBarrack($BRNum) ; $BRNum is 1 to 4 ( $BRNum - 1 will be the $brrNum )
	If _Sleep(700) Then Return
	If IsBoosted() = True Then
		Local $Result = getBarracksRemaingBoostTime($BoostedButtonX - 30, $BoostedButtonY + 21)
		SetLog(" » Barrack nº " & $BRNum & "| Remaining Time : " & $Result[0] & "s")
		$InitBoostTime[$BRNum - 1][0] = 0 ; I WILL FORCE NEXT LOOP TO SEARCH AGAIN THE TIME | OCR vs TimerInit
		$InitBoostTime[$BRNum - 1][1] = $Result[1] ; result in seconds
	Else
		$InitBoostTime[$BRNum - 1][0] = 0
		$InitBoostTime[$BRNum - 1][1] = 0
		Setlog(" » Barrack nº " & $BRNum & " was not Boosted.")
	EndIf
	ClickP($aAway, 2, 0)
EndFunc   ;==>VerifyRemainBoostTime

Func VerifyRemainDarkBoostTime($BRNum) ; Check with OCR the remain Boost Time on Selected Dark Barrack
	If IsTrainPage() Then ClickP($aAway, 2, 0)
	If _Sleep($iDelayTrain2) Then Return

	SelectDarkBarrack($BRNum) ; $BRNum is 1 to 2 ( $BRNum - 1 will be the $brrDarkNum )
	If _Sleep(700) Then Return
	If IsBoosted() = True Then
		Local $Result = getBarracksRemaingBoostTime($BoostedButtonX - 30, $BoostedButtonY + 21)
		SetLog(" » Dark Barrack nº " & $BRNum & "| Remaining Time : " & $Result[0] & "s")
		$InitBoostTimeDark[$BRNum - 1][0] = 0 ; I WILL FORCE NEXT LOOP TO SEARCH AGAIN THE TIME | OCR vs TimerInit
		$InitBoostTimeDark[$BRNum - 1][1] = $Result[1] ; result in seconds
	Else
		$InitBoostTimeDark[$BRNum - 1][0] = 0
		$InitBoostTimeDark[$BRNum - 1][1] = 0
		Setlog(" » Dark Barrack nº " & $BRNum & " was not Boosted.")
	EndIf
	ClickP($aAway, 2, 0)

EndFunc   ;==>VerifyRemainDarkBoostTime

Func CheckBarrackStatus($checkTrainPage = True, $showlog = False, $CNormalBarrack = True, $CDarkBarrack = False) ; Check with Pixel Color The Barrack Status ( working or not )

	If $checkTrainPage = True Then
		If IsTrainPage(False) = False Then openArmyOverview()
		If _Sleep(1000) Then Return
	EndIf

	; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
	Local $ResultNumBarrackAvailable[$numBarracksAvaiables]
	Local $ResultNumDarkBarrackAvailable[$numDarkBarracksAvaiables]

	Local $ReturnNormal[4]
	$ReturnNormal[0] = IIf(_ColorCheck(_GetPixelColor(267, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #1 Working Status: " & IIf($InitBoostTime[0][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[1] = IIf(_ColorCheck(_GetPixelColor(328, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #2 Working Status: " & IIf($InitBoostTime[1][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[2] = IIf(_ColorCheck(_GetPixelColor(388, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #3 Working Status: " & IIf($InitBoostTime[2][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnNormal[3] = IIf(_ColorCheck(_GetPixelColor(449, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("Barrack #4 Working Status: " & IIf($InitBoostTime[3][0] = 1, "True", "False"), $COLOR_GREEN)

	$x = 0
	For $i = 0 To 3
		If $Trainavailable[$i + 1] = 1 Then
			$ResultNumBarrackAvailable[$x] = $ReturnNormal[$i]
			$x += 1
		EndIf
	Next

	Local $ReturnDark[2]
	$ReturnDark[0] = IIf(_ColorCheck(_GetPixelColor(534, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("DARK Barrack #1 Working Status: " & IIf($InitBoostTimeDark[0][0] = 1, "True", "False"), $COLOR_GREEN)
	$ReturnDark[1] = IIf(_ColorCheck(_GetPixelColor(595, 529 + $midOffsetY, True), Hex(0xFFFFFF, 6), 15) = True, 1, 0)
	If $showlog = True Then SetLog("DARK Barrack #2 Working Status: " & IIf($InitBoostTimeDark[1][0] = 1, "True", "False"), $COLOR_GREEN)

	$x = 0
	For $i = 0 To 1
		If $Trainavailable[$i + 5] = 1 Then
			$ResultNumDarkBarrackAvailable[$x] = $ReturnDark[$i]
			$x += 1
		EndIf
	Next

	If $CNormalBarrack = True And $CDarkBarrack = False Then Return $ResultNumBarrackAvailable
	If $CNormalBarrack = False And $CDarkBarrack = True Then Return $ResultNumDarkBarrackAvailable
	If $CNormalBarrack = True And $CDarkBarrack = True Then Return -1 ; don't check both

EndFunc   ;==>CheckBarrackStatus

Func RunFirstAndDeleteQueuedTroops() ; Delete Queued troops on First Run , to prevent any unnecessary troop after the first donateCC routine

	Local $IsDontRemove = 0
	openArmyOverview()

	If WaitforPixel(762, 328 + $midOffsetY, 763, 329 + $midOffsetY, Hex(0xF18439, 6), 10, 10) Then
		If $debugsetlogTrain = 1 Then SetLog("Wait for ArmyOverView Window", $COLOR_PURPLE)
		If IsTrainPage() Then BarracksStatus(True)
	EndIf

	; Redim the Global Variable to existent num Barracks Available , Reset and fill it in DeleteQueueTroops()
	ReDim $BarrackCapacity[$numBarracksAvaiables]
	ReDim $BarrackTimeRemain[$numBarracksAvaiables]
	ReDim $InitBoostTime[$numBarracksAvaiables][2]
	For $i = 0 To $numBarracksAvaiables - 1
		$BarrackCapacity[$i] = 0
		$BarrackTimeRemain[$i] = 0
		$InitBoostTime[$i][0] = 0
		$InitBoostTime[$i][1] = 0
	Next

	; Redim the Global Variable to existent num Dark Barracks Available , Reset and fill it in DeleteQueueTroops()
	ReDim $DarkBarrackCapacity[$numDarkBarracksAvaiables]
	ReDim $DarkBarrackTimeRemain[$numDarkBarracksAvaiables]
	ReDim $InitBoostTimeDark[$numDarkBarracksAvaiables][2]
	For $i = 0 To $numDarkBarracksAvaiables - 1
		$DarkBarrackCapacity[$i] = 0
		$DarkBarrackTimeRemain[$i] = 0
		$InitBoostTimeDark[$i][0] = 0
		$InitBoostTimeDark[$i][1] = 0
	Next

	; Lets delete the previous queued troops
	GoesToFirstBarrack()
	If _Sleep($iDelayTrain3) Then Return ; ---> can be made with WaitforPixel()
	DeleteQueueTroops(True)
	DeleteQueueDarkTroops(True)
	If $iChkDontRemove = 1 Then
		Setlog("Activate Don't Remove Barrack!", $COLOR_RED)
		$IsDontRemove = 1
	Else
		$IsDontRemove = 0
	EndIf
	ClickP($aAway, 1, 0, "#0268") ;Click Away to clear open windows in case user interupted

EndFunc   ;==>RunFirstAndDeleteQueuedTroops

Func getReceivedTroops($x_start, $y_start) ; Check if 'you received Castle Troops from' , will proceed with a Sleep until the message disappear
	Local $Result = ""

	$Result = getOcrAndCapture("coc-DonTroops", $x_start, $y_start, 120, 27, True) ; X = 162  Y = 200

	If IsString($Result) <> "" Or IsString($Result) <> " " Then
		If StringInStr($Result, "you") Then ; If exist Minutes or only Seconds
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf

EndFunc   ;==>getReceivedTroops

Func DebugTrainSystem($string)

	If $debugsetlogTrain = 1 Then
		If $hLogFileTrain = "" Then
			Local $txt = ""
			For $i = 0 To UBound($Trainavailable) - 1
				$txt &= $Trainavailable[$i] & " "
			Next
			Local $Date = @MDAY & "." & @MON & "." & @YEAR
			Local $Time = @HOUR & "." & @MIN & "." & @SEC
			$hLogFileTrain = FileOpen($dirLogs & $Date & "_" & $Time & "_" & "DebugTrainSystem.log", $FO_APPEND)
			$string &= @CRLF
			$string &= "++++++++++++++++++++++++++++++++++++++++++++++++++++" & @CRLF
			$string &= "++++++++++++++++++++++++++++++++++++++++++++++++++++" & @CRLF
			$string &= "BotTitle: " & $sBotTitle & @CRLF
			$string &= "Android: " & $Android & @CRLF
			$string &= "Android Version: " & $AndroidVersion & @CRLF
			$string &= "Android ADB screencap command enabled: " & $AndroidAdbScreencap & @CRLF
			$string &= "TH Level: " & $iTownHallLevel & @CRLF
			$string &= "Total Camp: " & $TotalCamp & @CRLF
			$string &= "Train Available = " & $txt & @CRLF
			$string &= "++++++++++++++++++++++++++++++++++++++++++++++++++++" & @CRLF
			$string &= "++++++++++++++++++++++++++++++++++++++++++++++++++++" & @CRLF
		EndIf
		_FileWriteLog($hLogFileTrain, $string)
	EndIf

EndFunc   ;==>DebugTrainSystem

Func GoesToNorMalBarrack($NUM) ; Go To the $NUM Normal Barrack Available

	If IsTrainPage() Then
		Local $z = 0
		; $Trainavailable = [1, 1, 1, 0, 0, 0, 0, 0, 0]
		For $i = 1 To 4
			If $Trainavailable[$i] = 1 And $NUM = $z Then
				Click($btnpos[$i][0], $btnpos[$i][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to the $i barrack
				If _Sleep(1000) Then Return
				ExitLoop
			EndIf
			If $Trainavailable[$i] = 1 Then $z += 1
		Next
	Else
		Setlog(" ERROR YOU ARE NOT IN TRAIN PAGE!!!", $COLOR_RED)
	EndIf

EndFunc   ;==>GoesToNorMalBarrack

Func GoesToDarkBarrack($NUM) ; Go To the $NUM Dark Barrack Available

	If IsTrainPage() Then
		Local $z = 0
		; $Trainavailable = [1, 0, 1, 1, 1, 1, 0, 0, 0]
		For $i = 5 To 6
			If $Trainavailable[$i] = 1 And $NUM = $z Then
				Click($btnpos[$i][0], $btnpos[$i][1], 1, $iDelayTrain5, "#0336") ; Click on tab and go to the $i barrack
				If _Sleep(1000) Then Return
				ExitLoop
			EndIf
			If $Trainavailable[1 + $i] = 1 Then $z += 1
		Next
	Else
		Setlog(" ERROR YOU ARE NOT IN TRAIN PAGE!!!", $COLOR_RED)
	EndIf

EndFunc   ;==>GoesToDarkBarrack
