; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot
; Description ...: This file contens the Sequence that runs all MBR Bot
; Author ........:  (2014)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#RequireAdmin
#AutoIt3Wrapper_UseX64=7n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo /rsln
;#AutoIt3Wrapper_Change2CUI=y
;#pragma compile(Console, true)
#pragma compile(Icon, "Images\MyBot.ico")
#pragma compile(FileDescription, Clash of Clans Bot - A Free Clash of Clans bot - https://mybot.run)
#pragma compile(ProductName, My Bot)
#pragma compile(ProductVersion, 6.2.2)
#pragma compile(FileVersion, 6.2.2)
#pragma compile(LegalCopyright, © https://mybot.run)
#pragma compile(Out, MyBot.run.exe)  ; Required

#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Process.au3>

;~ Boost launch time by increasing process priority (will be restored again when finished launching)
Local $iBotProcessPriority = _ProcessGetPriority(@AutoItPID)
ProcessSetPriority(@AutoItPID, $PROCESS_ABOVENORMAL)

Global $iBotLaunchTime = 0
Local $hBotLaunchTime = TimerInit()

Global $sGitHubModOwner = "TheRevenor"
Global $sGitHubModRepo = "MyBot-v6.2.2-MyMod"
Global $sGitHubModLatestReleaseTag = "v2.0.6"
Global $sModSupportUrl = "https://mybot.run/forums/index.php?/topic/22790-v621-mod-therevenor-03-09-2016"

$sBotVersion = "v6.2.2" ;~ Don't add more here, but below. Version can't be longer than vX.y.z because it it also use on Checkversion()
$sBotTitle = "My Bot " & $sBotVersion & " MOD TheRevenor " & $sGitHubModLatestReleaseTag & "_A " ;~ Don't use any non file name supported characters like \ / : * ? " < > |
$sModversion = $sGitHubModLatestReleaseTag

#include "COCBot\functions\Config\DelayTimes.au3"
#include "COCBot\MBR Global Variables.au3"
_GDIPlus_Startup()
#include "COCBot\GUI\MBR GUI Design Splash.au3"
#include "COCBot\functions\Config\ScreenCoordinates.au3"
#include "COCBot\functions\Other\ExtMsgBox.au3"
#include "COCBot\functions\Mod\Chatbot\Chatbot.au3"

Opt("GUIResizeMode", $GUI_DOCKALL) ; Default resize mode for dock android support
Opt("GUIEventOptions", 1) ; Handle minimize and restore for dock android support
Opt("GUICloseOnESC", 0); Don't send the $GUI_EVENT_CLOSE message when ESC is pressed.
Opt("WinTitleMatchMode", 3) ; Window Title exact match mode

If Not FileExists(@ScriptDir & "\License.txt") Then
	$license = InetGet("http://www.gnu.org/licenses/gpl-3.0.txt", @ScriptDir & "\License.txt")
EndIf

;multilanguage
#include "COCBot\functions\Other\Multilanguage.au3"
DetectLanguage()
Local $sMsg

$sMsg = GetTranslated(500, 1, "Don't Run/Compile the Script as (x64)! Try to Run/Compile the Script as (x86) to get the bot to work.\r\n" & _
							  "If this message still appears, try to re-install AutoIt.")
If @AutoItX64 = 1 Then
	If IsHWnd($hSplash) Then GUIDelete($hSplash) ; Delete the splash screen since we don't need it anymore
	MsgBox(0, "", $sMsg)
	_GDIPlus_Shutdown()
	Exit
EndIf

#include "COCBot\functions\Other\MBRFunc.au3"
; check for VC2010, .NET software and MyBot Files and Folders
If CheckPrerequisites() Then
	MBRFunc(True) ; start MBRFunctions dll
EndIf

#include "COCBot\functions\Android\Android.au3"
#include "COCBot\functions\Android\SecureME.au3"

; Update Bot title
$sBotTitle = $sBotTitle & "(" & ($AndroidInstance <> "" ? $AndroidInstance : $Android) & ")" ; Do not change this. If you do, multiple instances will not work.

UpdateSplashTitle($sBotTitle & GetTranslated(500, 20, ", Profile: %s", $sCurrProfile))

If $bBotLaunchOption_Restart = True Then
   If WinGetHandle($sBotTitle) Then SplashStep(GetTranslated(500, 36, "Closing previous bot..."))
   If CloseRunningBot($sBotTitle) = True Then
	  ; wait for Mutexes to get disposed
	  Sleep(3000)
   EndIf
Else
	SplashStep("")
EndIF

Local $cmdLineHelp = GetTranslated(500, 2, "By using the commandline (or a shortcut) you can start multiple Bots:\r\n" & _
					 "     MyBot.run.exe [ProfileName] [EmulatorName] [InstanceName]\r\n\r\n" & _
					 "With the first command line parameter, specify the Profilename (you can create profiles on the Misc tab, if a " & _
					 "profilename contains a {space}, then enclose the profilename in double quotes). " & _
					 "With the second, specify the name of the Emulator and with the third, an Android Instance (not for BlueStacks). \r\n" & _
					 "Supported Emulators are MEmu, Droid4X, Nox, BlueStacks2 and BlueStacks.\r\n\r\n" & _
					 "Examples:\r\n" & _
					 "     MyBot.run.exe MyVillage BlueStacks2\r\n" & _
					 "     MyBot.run.exe ""My Second Village"" MEmu MEmu_1")

$hMutex_BotTitle = _Singleton($sBotTitle, 1)
Local $sAndroidInfo = GetTranslated(500, 3, "%s", $Android)
Local $sAndroidInfo2 = GetTranslated(500, 4, "%s (instance %s)", $Android, $AndroidInstance)
If $AndroidInstance <> "" Then
	$sAndroidInfo = $sAndroidInfo2
EndIf

$sMsg = GetTranslated(500, 5, "My Bot for %s is already running.\r\n\r\n", $sAndroidInfo)
If $hMutex_BotTitle = 0 Then
	RemoveFolderFromInUseList()
	DeletePicturesHostFolder()
	If IsHWnd($hSplash) Then GUIDelete($hSplash) ; Delete the splash screen since we don't need it anymore
	MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $sBotTitle, $sMsg & $cmdLineHelp)
	_GDIPlus_Shutdown()
	Exit
EndIf

$hMutex_Profile = _Singleton(StringReplace($sProfilePath & "\" & $sCurrProfile, "\", "-"), 1)
$sMsg = GetTranslated(500, 6, "My Bot with Profile %s is already running in %s.\r\n\r\n", $sCurrProfile, $sProfilePath & "\" & $sCurrProfile)
If $hMutex_Profile = 0 Then
	_WinAPI_CloseHandle($hMutex_BotTitle)
	If IsHWnd($hSplash) Then GUIDelete($hSplash) ; Delete the splash screen since we don't need it anymore
	MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $sBotTitle, $sMsg & $cmdLineHelp)
	_GDIPlus_Shutdown()
	Exit
EndIf

$hMutex_MyBot = _Singleton("MyBot.run", 1)
$OnlyInstance = $hMutex_MyBot <> 0 ; And False
SetDebugLog("My Bot is " & ($OnlyInstance ? "" : "not ") & "the only running instance")

#include "COCBot\MBR Global Variables Troops.au3"
#include "COCBot\MBR GUI Design.au3"
#include "COCBot\MBR GUI Control.au3"
#include "COCBot\MBR Functions.au3"

;DirCreate($sTemplates)
DirCreate($sPreset)
DirCreate($sProfilePath & "\" & $sCurrProfile)
DirCreate($dirLogs)
DirCreate($dirLoots)
DirCreate($dirTemp)
DirCreate($dirTempDebug)
;Migrate old bot without profile support to current one
FileMove(@ScriptDir & "\*.ini", $sProfilePath & "\" & $sCurrProfile, $FC_OVERWRITE + $FC_CREATEPATH)
DirCopy(@ScriptDir & "\Logs", $sProfilePath & "\" & $sCurrProfile & "\Logs", $FC_OVERWRITE + $FC_CREATEPATH)
DirCopy(@ScriptDir & "\Loots", $sProfilePath & "\" & $sCurrProfile & "\Loots", $FC_OVERWRITE + $FC_CREATEPATH)
DirCopy(@ScriptDir & "\Temp", $sProfilePath & "\" & $sCurrProfile & "\Temp", $FC_OVERWRITE + $FC_CREATEPATH)
DirRemove(@ScriptDir & "\Logs", 1)
DirRemove(@ScriptDir & "\Loots", 1)
DirRemove(@ScriptDir & "\Temp", 1)

;Setup profile if doesn't exist yet
If FileExists($config) = 0 Then
	createProfile(True)
EndIf

If $ichkDeleteLogs = 1 Then DeleteFiles($dirLogs, "*.*", $iDeleteLogsDays, 0)
If $ichkDeleteLoots = 1 Then DeleteFiles($dirLoots, "*.*", $iDeleteLootsDays, 0)
If $ichkDeleteTemp = 1 Then DeleteFiles($dirTemp, "*.*", $iDeleteTempDays, 0)
If $ichkDeleteTemp = 1 Then DeleteFiles($dirTempDebug, "*.*", $iDeleteTempDays, 0)

$sMsg = GetTranslated(500, 7, "Found running %s %s" , $Android, $AndroidVersion)
If $FoundRunningAndroid Then
	SetLog($sMsg, $COLOR_GREEN)
EndIf
If $FoundInstalledAndroid Then
	SetLog("Found installed " & $Android & " " & $AndroidVersion, $COLOR_GREEN)
EndIf
SetLog(GetTranslated(500, 8, "Android Emulator Configuration: %s", $sAndroidInfo), $COLOR_GREEN)


; Add Telegram extension by CDudz
$lastmessage = GetLastMsg()
If $FirstRun = 1 Then
	$lastremote = $lastuid
	Getchatid(GetTranslated(620, 92, "select your remote")) ; receive Telegram chat id and send keyboard
EndIf
;AdlibRegister("PushBulletRemoteControl", $PBRemoteControlInterval)
;AdlibRegister("PushBulletDeleteOldPushes", $PBDeleteOldPushesInterval)

CheckDisplay() ; verify display size and DPI (Dots Per Inch) setting

LoadTHImage() ; Load TH images
LoadElixirImage() ; Load Elixir images
LoadElixirImage75Percent(); Load Elixir images full at 75%
LoadElixirImage50Percent(); Load Elixir images full at 50%
LoadAmountOfResourcesImages()

;~ InitializeVariables();initialize variables used in extra windows
CheckVersion() ; check latest version on mybot.run site
SetComboTroopComp()

;~ Remember time in Milliseconds bot launched
$iBotLaunchTime = TimerDiff($hBotLaunchTime)
SetDebugLog("MyBot.run launch time " & Round($iBotLaunchTime) & " ms.")

$sMsg = GetTranslated(500, 9, "Android Shield not available for %s", @OSVersion)
If $AndroidShieldEnabled = False Then
	SetLog($sMsg, $COLOR_ORANGE)
EndIf

;~ Restore process priority
ProcessSetPriority(@AutoItPID, $iBotProcessPriority)

;AutoStart Bot if request
AutoStart()
While 1
	_Sleep($iDelaySleep, True, False)

	Switch $BotAction
		Case $eBotStart
			BotStart()
			If $BotAction = $eBotStart Then $BotAction = $eBotNoAction
		Case $eBotStop
			BotStop()
			If $BotAction = $eBotStop Then $BotAction = $eBotNoAction
		Case $eBotSearchMode
			BotSearchMode()
			If $BotAction = $eBotSearchMode Then $BotAction = $eBotNoAction
		Case $eBotClose
			BotClose()
	EndSwitch
WEnd

Func runBot() ;Bot that runs everything in order
	$TotalTrainedTroops = 0
	Local $Quickattack = False
	Local $iWaitTime
	While 1
		$Restart = False
		$fullArmy = False
		$CommandStop = -1
		If _Sleep($iDelayRunBot1) Then Return
		checkMainScreen()
		If $Restart = True Then ContinueLoop
		chkShieldStatus()
		If $Restart = True Then ContinueLoop

		If $quicklyfirststart = true Then
			$quicklyfirststart = False
		Else
			$Quickattack = QuickAttack()
		EndIf

	    If checkAndroidTimeLag() = True Then ContinueLoop
		If $Is_ClientSyncError = False And $Is_SearchLimit = False and ($Quickattack = False ) Then
	    	If BotCommand() Then btnStop()
				If _Sleep($iDelayRunBot2) Then Return
			checkMainScreen(False)
				If $Restart = True Then ContinueLoop
			If $ichkMultyFarming = 1 Or $ichkSwitchDonate = 1 Then DetectAccount()
			If $RequestScreenshot = 1 Then PushMsgToPushBullet("RequestScreenshot")
			If $RequestBuilderInfo = 1 Then PushMsgToPushBullet("BuilderInfo")
			If $RequestShieldInfo = 1 Then PushMsgToPushBullet("ShieldInfo")
				If _Sleep($iDelayRunBot3) Then Return
			VillageReport()
			ProfileSwitch() ; Added for Switch profile
			If $OutOfGold = 1 And (Number($iGoldCurrent) >= Number($itxtRestartGold)) Then ; check if enough gold to begin searching again
				$OutOfGold = 0 ; reset out of gold flag
				Setlog("Switching back to normal after no gold to search ...", $COLOR_RED)
				$ichkBotStop = 0 ; reset halt attack variable
				$icmbBotCond = _GUICtrlComboBox_GetCurSel($cmbBotCond) ; Restore User GUI halt condition after modification for out of gold
				$bTrainEnabled = True
				$bDonationEnabled = True
				ContinueLoop ; Restart bot loop to reset $CommandStop
			EndIf
			If $OutOfElixir = 1 And (Number($iElixirCurrent) >= Number($itxtRestartElixir)) And (Number($iDarkCurrent) >= Number($itxtRestartDark)) Then ; check if enough elixir to begin searching again
				$OutOfElixir = 0 ; reset out of gold flag
				Setlog("Switching back to normal setting after no elixir to train ...", $COLOR_RED)
				$ichkBotStop = 0 ; reset halt attack variable
				$icmbBotCond = _GUICtrlComboBox_GetCurSel($cmbBotCond) ; Restore User GUI halt condition after modification for out of elixir
				$bTrainEnabled = True
				$bDonationEnabled = True
				ContinueLoop ; Restart bot loop to reset $CommandStop
			EndIf
				If _Sleep($iDelayRunBot5) Then Return
			checkMainScreen(False)
				If $Restart = True Then ContinueLoop
			If $FirstStart Then RunFirstAndDeleteQueuedTroops()
			Local $aRndFuncList[3] = ['Collect', 'CheckTombs', 'ReArm']
			While 1
				If $RunState = False Then Return
				If $Restart = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				If UBound($aRndFuncList) > 1 Then
					$Index = Random(0, UBound($aRndFuncList), 1)
					If $Index > UBound($aRndFuncList) - 1 Then $Index = UBound($aRndFuncList) - 1
					_RunFunction($aRndFuncList[$Index])
					_ArrayDelete($aRndFuncList, $Index)
				Else
					_RunFunction($aRndFuncList[0])
					ExitLoop
				EndIf
			    If $Restart = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			WEnd
				If $RunState = False Then Return
				If $Restart = True Then ContinueLoop
			IsWaitingForConnection()
			DonateCC()
			If _Sleep($iDelayRunBot3) Then Return
			If $ichkDeleteTroops = 1 Then DeleteTroopsInArmyOverview()
			If IsSearchAttackEnabled() Then  ; if attack is disabled skip reporting, requesting, donating, training, and boosting
			   Local $aRndFuncList[6] = ['ReplayShare', 'ReportNotify', 'BoostBarracks', 'BoostSpellFactories', 'BoostHeroes', 'RequestCC']
			   While 1
				   If $RunState = False Then Return
				   If $Restart = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				   If UBound($aRndFuncList) > 1 Then
					   $Index = Random(0, UBound($aRndFuncList), 1)
					   If $Index > UBound($aRndFuncList) - 1 Then $Index = UBound($aRndFuncList) - 1
					   _RunFunction($aRndFuncList[$Index])
					   _ArrayDelete($aRndFuncList, $Index)
				   Else
					   _RunFunction($aRndFuncList[0])
					   ExitLoop
				   EndIf
				   If checkAndroidTimeLag() = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			   WEnd
					If $RunState = False Then Return
					If $Restart = True Then ContinueLoop
			   If $iUnbreakableMode >= 1 Then
					If Unbreakable() = True Then ContinueLoop
				EndIf
			EndIf
				If $RunState = False Then Return
			IsWaitingForConnection()
			Train()
			_Sleep($iDelayRunBot3)
				If $Restart = True Then ContinueLoop
			Local $aRndFuncList[3] = ['Laboratory', 'UpgradeHeroes', 'UpgradeBuilding']
			While 1
				If $RunState = False Then Return
				If $Restart = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				If UBound($aRndFuncList) > 1 Then
					$Index = Random(0, UBound($aRndFuncList), 1)
					If $Index > UBound($aRndFuncList) - 1 Then $Index = UBound($aRndFuncList) - 1
					_RunFunction($aRndFuncList[$Index])
					_ArrayDelete($aRndFuncList, $Index)
				Else
					_RunFunction($aRndFuncList[0])
					ExitLoop
				EndIf
				If checkAndroidTimeLag() = True Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			WEnd
				If $RunState = False Then Return
			SmartUpgrade()
			_Sleep($iDelayRunBot3)
				If $Restart = True Then ContinueLoop
			If IsSearchAttackEnabled() Then  ; If attack scheduled has attack disabled now, stop wall upgrades, and attack.
				$iNbrOfWallsUpped = 0
				UpgradeWall()
					If _Sleep($iDelayRunBot3) Then Return
					If $Restart = True Then ContinueLoop
				PushMsgToPushBullet("CheckBuilderIdle")
				Idle()
					;$fullArmy1 = $fullArmy
					If _Sleep($iDelayRunBot3) Then Return
					If $Restart = True Then ContinueLoop
				SaveStatChkTownHall()
				SaveStatChkDeadBase()
				If $CommandStop <> 0 And $CommandStop <> 3 Then
				  AttackMain()
				  If $OutOfGold = 1 Then
					 Setlog("Switching to Halt Attack, Stay Online/Collect mode ...", $COLOR_RED)
					 $ichkBotStop = 1 ; set halt attack variable
					 $icmbBotCond = 18 ; set stay online/collect only mode
					 $FirstStart = True ; reset First time flag to ensure army balancing when returns to training
					 ContinueLoop
				  EndIf
				  If _Sleep($iDelayRunBot1) Then Return
				  If $Restart = True Then ContinueLoop
			   EndIf
			Else
				$iWaitTime = Random($iDelayWaitAttack1, $iDelayWaitAttack2)
			   SetLog("Attacking Not Planned and Skipped, Waiting random " & StringFormat("%0.1f", $iWaitTime / 1000) & " Seconds", $COLOR_RED)
			   If _SleepStatus($iWaitTime) Then Return False
			EndIf
	    Else ;When error occours directly goes to attack
			If $Quickattack Then
				Setlog("Quick Restart... ",$color_blue)
			Else
				If $Is_SearchLimit = True Then
					SetLog("Restarted due search limit", $COLOR_BLUE)
				Else
					SetLog("Restarted after Out of Sync Error: Attack Now", $COLOR_BLUE)
				EndIf
			EndIf
			If _Sleep($iDelayRunBot3) Then Return
			;  OCR read current Village Trophies when OOS restart maybe due PB or else DropTrophy skips one attack cycle after OOS
			$iTrophyCurrent = Number(getTrophyMainScreen($aTrophies[0], $aTrophies[1]))
			If $debugSetlog = 1 Then SetLog("Runbot Trophy Count: " & $iTrophyCurrent, $COLOR_PURPLE)
			AttackMain()
			If $OutOfGold = 1 Then
				Setlog("Switching to Halt Attack, Stay Online/Collect mode ...", $COLOR_RED)
				$ichkBotStop = 1 ; set halt attack variable
				$icmbBotCond = 18 ; set stay online/collect only mode
				$FirstStart = True ; reset First time flag to ensure army balancing when returns to training
				$Is_ClientSyncError = False ; reset fast restart flag to stop OOS mode and start collecting resources
				ContinueLoop
			EndIf
			If _Sleep($iDelayRunBot5) Then Return
			If $Restart = True Then ContinueLoop
		EndIf
		;Multy-Farming ==============================================================================================================
		If $ichkMultyFarming = 1 And $iMultyFarming = 1 Then
			SetLog("Multy-Farming Mode Active...", $COLOR_RED)
			SetLog("Please don't PAUSE/STOP BOT during profile change", $COLOR_RED)
			$canRequestCC = True
			$bDonationEnabled = True
			Sleep(1500)
			RequestCC()
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Sleep(1500)
			$iShouldRearm = True
			$FirstStart = True
			$RunState = True
			$iSwCount = 0
			If $sCurrProfile = "[01] Main" Then
				If IniRead($sProfilePath & "\[02] Second\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Second")
				ElseIf IniRead($sProfilePath & "\[03] Third\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Third")
				ElseIf IniRead($sProfilePath & "\[04] Fourth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Fourth")
				ElseIf IniRead($sProfilePath & "\[05] Fifth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Fifth")
				ElseIf IniRead($sProfilePath & "\[06] Sixth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Sixth")
				Else
					SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
				EndIF

			ElseIf $sCurrProfile = "[02] Second" Then
				If $iAccount = "3" Or $iAccount = "4" Or $iAccount = "5" Or $iAccount = "6" Then
					If IniRead($sProfilePath & "\[03] Third\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Third")
					ElseIf IniRead($sProfilePath & "\[04] Fourth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fourth")
					ElseIf IniRead($sProfilePath & "\[05] Fifth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fifth")
					ElseIf IniRead($sProfilePath & "\[06] Sixth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Sixth")
					ElseIf IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					Else
						SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
					EndIF
				Else
					If IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					EndIF
				EndIf

			ElseIf $sCurrProfile = "[03] Third" Then
				If $iAccount = "4" Or $iAccount = "5" Or $iAccount = "6" Then
					If IniRead($sProfilePath & "\[04] Fourth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fourth")
					ElseIf IniRead($sProfilePath & "\[05] Fifth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fifth")
					ElseIf IniRead($sProfilePath & "\[06] Sixth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Sixth")
					ElseIf IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					ElseIf IniRead($sProfilePath & "\[02] Second\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Second")
					Else
						SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
					EndIf

				ElseIf $iAccount = "3" Then
					If IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					EndIf

				EndIf
			ElseIf $sCurrProfile = "[04] Fourth" Then
				If $iAccount = "5" Or $iAccount = "6" Then
					If IniRead($sProfilePath & "\[05] Fifth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fifth")
					ElseIf IniRead($sProfilePath & "\[06] Sixth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Sixth")
					ElseIf IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					ElseIf IniRead($sProfilePath & "\[02] Second\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Second")
					ElseIf IniRead($sProfilePath & "\[03] Third\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Third")
					Else
						SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
					EndIf
				ElseIf $iAccount = "4" Then
					If IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					EndIf
				EndIf
			ElseIf $sCurrProfile = "[05] Fifth" Then
				If $iAccount = "6" Then
					If IniRead($sProfilePath & "\[06] Sixth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Sixth")
					ElseIf IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					ElseIf IniRead($sProfilePath & "\[02] Second\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Second")
					ElseIf IniRead($sProfilePath & "\[03] Third\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Third")
					ElseIf IniRead($sProfilePath & "\[04] Fourth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fourth")
					Else

						SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
					EndIf

				ElseIf $iAccount = "5" Then
					If IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Main")
					EndIf

				EndIf
			ElseIf $sCurrProfile = "[06] Sixth" Then
				If IniRead($sProfilePath & "\[01] Main\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Main")
				ElseIf IniRead($sProfilePath & "\[02] Second\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Second")
				ElseIf IniRead($sProfilePath & "\[03] Third\config.ini", "Multy", "MultyFarming", "0") = "1" Then
					SwitchAccount("Third")
				ElseIf IniRead($sProfilePath & "\[04] Fourth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fourth")
				ElseIf IniRead($sProfilePath & "\[05] Fifth\config.ini", "Multy", "MultyFarming", "0") = "1" Then
						SwitchAccount("Fifth")
				Else
					SetLog("You don't have other profiles configured for multy-farming. Swithing accounts canceled.", $COLOR_RED)
				EndIf
			EndIf
		EndIf
		;============================================================================================================================;
	WEnd
EndFunc   ;==>_runBot

Func Idle() ;Sequence that runs until Full Army
	Local $TimeIdle = 0 ;In Seconds
	If $debugSetlog = 1 Then SetLog("Func Idle ", $COLOR_PURPLE)

    While $fullArmy = False Or $bFullArmyHero = False Or $bFullArmySpells = False
		checkAndroidTimeLag()

		If $RequestScreenshot = 1 Then PushMsgToPushBullet("RequestScreenshot")
		If $RequestBuilderInfo = 1 Then PushMsgToPushBullet("BuilderInfo")
		If $RequestShieldInfo = 1 Then PushMsgToPushBullet("ShieldInfo")
		If _Sleep($iDelayIdle1) Then Return
		If $CommandStop = -1 Then SetLog("====== Waiting for full army ======", $COLOR_GREEN)
		Local $hTimer = TimerInit()
		Local $iReHere = 0

		While $iReHere < 7
			$iReHere += 1
			DonateCC(True)
			If _Sleep($iDelayIdle2) Then ExitLoop
			;Modify Chat by TheRevenor ===============================================
			If $iReHere = 6 Then
				CheckNewChat()
				Sleep(500)
				ChatbotMessage()
			EndIf
			If $Restart = True Then ExitLoop
		WEnd
		If _Sleep($iDelayIdle1) Then ExitLoop
		checkMainScreen(False) ; required here due to many possible exits
		If ($CommandStop = 3 Or $CommandStop = 0) Then
            getArmyCapacity(True, False)
            CheckOverviewFullArmy(False, False)  ; use true parameter to open train overview window
			getArmyHeroCount(False, False)
			getArmySpellCapacity(False, True) ; use true parameter to close train overview window
			If _Sleep($iDelayIdle1) Then Return
			If $fullArmy = False And $bTrainEnabled = True Then
				SetLog("Army Camp and Barracks are not full, Training Continues...", $COLOR_ORANGE)
				$CommandStop = 0
			EndIf
		EndIf
		ReplayShare($iShareAttackNow)
		If _Sleep($iDelayIdle1) Then Return
		CleanYard()
		If $Restart = True Then ExitLoop
		If $iCollectCounter > $COLLECTATCOUNT Then ; This is prevent from collecting all the time which isn't needed anyway
 			Local $aRndFuncList[2] = ['Collect', 'DonateCC']
			While 1
				If $RunState = False Then Return
				If $Restart = True Then ExitLoop
				If UBound($aRndFuncList) > 1 Then
					$Index = Random(0, UBound($aRndFuncList), 1)
					If $Index > UBound($aRndFuncList) - 1 Then $Index = UBound($aRndFuncList) - 1
					_RunFunction($aRndFuncList[$Index])
					_ArrayDelete($aRndFuncList, $Index)
				Else
					_RunFunction($aRndFuncList[0])
					ExitLoop
				EndIf
			WEnd
			If $RunState = False Then Return
			If $Restart = True Then ExitLoop
			If _Sleep($iDelayIdle1) Or $RunState = False Then ExitLoop
			$iCollectCounter = 0
		EndIf
		$iCollectCounter = $iCollectCounter + 1
		If $CommandStop = -1 Then
			Train()
				If $Restart = True Then ExitLoop
				If _Sleep($iDelayIdle1) Then ExitLoop
				checkMainScreen(False)
		EndIf
        If $debugsetlog = 1 Then Setlog("IDLE| $CommandStop : " & $CommandStop)
		If $debugsetlog = 1 Then Setlog("IDLE| $bTrainEnabled : " & $bTrainEnabled)
		If $debugsetlog = 1 Then Setlog("IDLE| $fullArmy 	: " & $fullArmy)
		If $debugsetlog = 1 Then Setlog("IDLE| $bFullArmySpells : " & $bFullArmySpells)
		If _Sleep($iDelayIdle1) Then Return
		If $CommandStop = 0 And $bTrainEnabled = True Then
            If $fullArmy = False Or $bFullArmySpells = False Then
				Train()
					If $Restart = True Then ExitLoop
					If _Sleep($iDelayIdle1) Then ExitLoop
					checkMainScreen(False)
			EndIf
            If $fullArmy And $bFullArmySpells Then
				SetLog("Army Camp and Barracks are full, stop Training...", $COLOR_ORANGE)
				$CommandStop = 3
			EndIf
		EndIf
		If _Sleep($iDelayIdle1) Then Return
		If $CommandStop = -1 Then
			DropTrophy()
				If $Restart = True Then ExitLoop
				If $fullArmy Then ExitLoop
				If _Sleep($iDelayIdle1) Then ExitLoop
				checkMainScreen(False)
		EndIf
		If _Sleep($iDelayIdle1) Then Return
		If $Restart = True Then ExitLoop
		$TimeIdle += Round(TimerDiff($hTimer) / 1000, 2) ;In Seconds

		If $canRequestCC = True Then RequestCC()

        If $CurCamp >=  $TotalCamp * $iEnableAfterArmyCamps[$DB]/100 and $iEnableSearchCamps[$DB]  = 1 and IsSearchModeActive($DB) Then Exitloop
        If $CurCamp >=  $TotalCamp * $iEnableAfterArmyCamps[$LB]/100 and $iEnableSearchCamps[$LB]  = 1 and IsSearchModeActive($LB) Then Exitloop
        If $CurCamp >=  $TotalCamp * $iEnableAfterArmyCamps[$TS]/100 and $iEnableSearchCamps[$TS]  = 1 and IsSearchModeActive($TS) Then Exitloop

		SetLog("Time Idle: " & StringFormat("%02i", Floor(Floor($TimeIdle / 60) / 60)) & ":" & StringFormat("%02i", Floor(Mod(Floor($TimeIdle / 60), 60))) & ":" & StringFormat("%02i", Floor(Mod($TimeIdle, 60))))

		If $OutOfGold = 1 Or $OutOfElixir = 1 Then Return  ; Halt mode due low resources, only 1 idle loop
		If ($CommandStop = 3 Or $CommandStop = 0) And $bTrainEnabled = False Then ExitLoop ; If training is not enabled, run only 1 idle loop

		If $iChkSnipeWhileTrain = 1 Then SnipeWhileTrain()  ;snipe while train

		If $CommandStop = -1 Then
			SmartWait4Train()  ; Check if closing bot/emulator while training and not in halt mode
			If ($ichkCloseWaitEnable = 1 And $iEnableSpellsWait[$iMatchMode] = 1 Or GUICtrlRead($chkDBKingWait) = $GUI_CHECKED Or GUICtrlRead($chkDBQueenWait) = $GUI_CHECKED Or _
						GUICtrlRead($chkDBWardenWait) = $GUI_CHECKED Or GUICtrlRead($chkABKingWait) = $GUI_CHECKED Or GUICtrlRead($chkABQueenWait) = $GUI_CHECKED Or _
						GUICtrlRead($chkABWardenWait) = $GUI_CHECKED) Then
				If _Sleep(2000) Then return
				GetReadTimeHeroesAndSpell()
				ClickP($aAway, 1, 0, "#0000") ;Click Away
				If _Sleep(1500) Then Return
			EndIf
			If $Restart = True Then ExitLoop ; if smart wait activated, exit to runbot in case user adjusted GUI or left emulator/bot in bad state
		EndIf

	WEnd
EndFunc   ;==>Idle

Func AttackMain() ;Main control for attack functions
	;LoadAmountOfResourcesImages() ; for debug
	If IsSearchAttackEnabled() Then
		If IsSearchModeActive($DB) or IsSearchModeActive($LB) or IsSearchModeActive($TS) Then ; fix no collectors are selected warning error
			If $iChkUseCCBalanced = 1 or $iChkUseCCBalancedCSV = 1 Then ;launch profilereport() only if option balance D/R it's activated
				ProfileReport()
				If _Sleep($iDelayAttackMain1) Then Return
				checkMainScreen(False)
				If $Restart = True Then Return
			EndIf
			If $iChkTrophyRange = 1 and Number($iTrophyCurrent) > Number($iTxtMaxTrophy) Then ;If current trophy above max trophy, try drop first
				DropTrophy()
				$Is_ClientSyncError = False ; reset OOS flag to prevent looping.
				If _Sleep($iDelayAttackMain1) Then Return
				Return ; return to runbot, refill armycamps
			EndIf
			If $debugSetlog = 1 Then
				SetLog(_PadStringCenter(" Hero status check" & BitAND($iHeroAttack[$DB], $iHeroWait[$DB], $iHeroAvailable) & "|" & $iHeroWait[$DB] & "|" & $iHeroAvailable, 54, "="), $COLOR_PURPLE)
				SetLog(_PadStringCenter(" Hero status check" & BitAND($iHeroAttack[$LB], $iHeroWait[$LB], $iHeroAvailable) & "|" & $iHeroWait[$LB] & "|" & $iHeroAvailable, 54, "="), $COLOR_PURPLE)
				;Setlog("BullyMode: " & $OptBullyMode & ", Bully Hero: " & BitAND($iHeroAttack[$iTHBullyAttackMode], $iHeroWait[$iTHBullyAttackMode], $iHeroAvailable) & "|" & $iHeroWait[$iTHBullyAttackMode] & "|" & $iHeroAvailable, $COLOR_PURPLE)
			EndIf
			If $ichkSwitchDonate = 1 Then
				If $iPlannedRequestCCHoursEnable = 0 Then
					$iPlannedRequestCCHoursEnable = 1
					GUICtrlSetState($chkRequestCCHours, $GUI_CHECKED)
					SetLog(" » Force Enable RequestCC Troops", $COLOR_ORANGE)
				EndIf
				RequestCC()
				_Sleep($iDelayRunBot4)
			EndIf
			PrepareSearch()
				If $OutOfGold = 1 Then Return ; Check flag for enough gold to search
				If $Restart = True Then Return
			VillageSearch()
				If $OutOfGold = 1 Then Return ; Check flag for enough gold to search
				If $Restart = True Then Return
			PrepareAttack($iMatchMode)
				If $Restart = True Then Return
			Attack()
				If $Restart = True Then Return
			ReturnHome($TakeLootSnapShot)
				If _Sleep($iDelayAttackMain2) Then Return
				$iMultyFarming = 1
			Return True
		Else
			Setlog("No one of search condition match:", $COLOR_BLUE)
			Setlog("Waiting on troops, heroes and/or spells according to search settings", $COLOR_BLUE)
			GetReadTimeHeroesAndSpell()
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Sleep(1500)
			$iMultyFarming = 0
		EndIf
	Else
		SetLog("Attacking Not Planned, Skipped..", $COLOR_RED)
	EndIf
EndFunc   ;==>AttackMain

Func Attack() ;Selects which algorithm
	SetLog(" ====== Start Attack ====== ", $COLOR_GREEN)
	If  ($iMatchMode = $DB and $iAtkAlgorithm[$DB] = 1) or ($iMatchMode = $LB and  $iAtkAlgorithm[$LB] = 1) Then
		If $debugSetlog = 1 Then Setlog("start scripted attack",$COLOR_RED)
		Algorithm_AttackCSV()
	Elseif $iMatchMode = $DB and  $iAtkAlgorithm[$DB] = 2 Then
		If $debugSetlog = 1 Then Setlog("start milking attack",$COLOR_RED)
		Alogrithm_MilkingAttack()
	Else
		If $debugSetlog = 1 Then Setlog("start standard attack",$COLOR_RED)
		algorithm_AllTroops()
	EndIf
EndFunc   ;==>Attack


Func QuickAttack()
   Local   $quicklymilking = 0
   Local   $quicklythsnipe = 0
   If ($iAtkAlgorithm[$DB] = 2  and IsSearchModeActive($DB) ) or (IsSearchModeActive($TS)) Then
	  getArmyCapacity(true,true)
	  VillageReport()
   EndIf
   $iTrophyCurrent = getTrophyMainScreen($aTrophies[0], $aTrophies[1])
   If ($iChkTrophyRange = 1 and Number($iTrophyCurrent) > Number($iTxtMaxTrophy))  then
	  If $debugSetlog = 1 Then Setlog("No quickly re-attack, need to drop tropies",$COLOR_PURPLE)
	  return False ;need to drop tropies
   EndIf
   If $iAtkAlgorithm[$DB] = 2  and IsSearchModeActive($DB) Then
	  If Int($CurCamp) >=  $TotalCamp * $iEnableAfterArmyCamps[$DB]/100 and $iEnableSearchCamps[$DB]  = 1   Then
		 If $debugSetlog = 1 Then Setlog("Milking: Quickly re-attack " &  Int($CurCamp) & " >= " & $TotalCamp & " * " & $iEnableAfterArmyCamps[$DB] & "/100 " & "= " &   $TotalCamp * $iEnableAfterArmyCamps[$DB]/100 ,$COLOR_PURPLE)
		 return true ;milking attack OK!
	  Else
		 If $debugSetlog = 1 Then Setlog("Milking: No Quickly re-attack:  cur. "  & Int($CurCamp) & "  need " & $TotalCamp * $iEnableAfterArmyCamps[$DB]/100 & " firststart = " &  ($quicklyfirststart)  ,$COLOR_PURPLE)
		 return false ;milking attack no restart.. no enough army
	  EndIf
   EndIf
   If IsSearchModeActive($TS) Then
	  If Int($CurCamp) >=  $TotalCamp * $iEnableAfterArmyCamps[$TS]/100 and $iEnableSearchCamps[$TS]  = 1  Then
		 If $debugSetlog = 1 Then Setlog("THSnipe: Quickly re-attack " &  Int($CurCamp) & " >= " & $TotalCamp & " * " & $iEnableAfterArmyCamps[$TS] & "/100 " & "= " &   $TotalCamp * $iEnableAfterArmyCamps[$TS]/100 ,$COLOR_PURPLE)
		 return True ;ts snipe attack OK!
	  Else
		 If $debugSetlog = 1 Then Setlog("THSnipe: No Quickly re-attack:  cur. "  & Int($CurCamp) & "  need " & $TotalCamp * $iEnableAfterArmyCamps[$TS]/100 & " firststart = " &  ($quicklyfirststart)  ,$COLOR_PURPLE)
		 return False ;ts snipe no restart... no enough army
	  EndIF
   EndIf

EndFunc

Func _RunFunction($action)
	SetDebugLog("_RunFunction: " & $action & " BEGIN")
	Switch $action
		Case "Collect"
			Collect()
			_Sleep($iDelayRunBot1)
		Case "CheckTombs"
			CheckTombs()
			_Sleep($iDelayRunBot3)
		Case "ReArm"
			ReArm()
			_Sleep($iDelayRunBot3)
		Case "ReplayShare"
			ReplayShare($iShareAttackNow)
			_Sleep($iDelayRunBot3)
		Case "ReportNotify"
			ReportNotify()
			_Sleep($iDelayRunBot3)
		Case "DonateCC"
			IsWaitingForConnection()
			DonateCC()
			If _Sleep($iDelayRunBot1) = False Then checkMainScreen(False)
		Case "BoostBarracks"
			BoostBarracks()
			BoostDarkBarracks()
		Case "BoostSpellFactories"
			BoostSpellFactory()
			If _Sleep($iDelayRunBot1) = False Then checkMainScreen(False)
			BoostDarkSpellFactory()
		Case "BoostHeroes"
			BoostKing()
			If _Sleep($iDelayRunBot1) = False Then checkMainScreen(False)
			BoostQueen()
			If _Sleep($iDelayRunBot1) = False Then checkMainScreen(False)
			BoostWarden()
		Case "RequestCC"
			If $ichkSwitchDonate = 0 Then
				RequestCC()
				If _Sleep($iDelayRunBot1) = False Then checkMainScreen(False)
			EndIf
		Case "Laboratory"
			Laboratory()
			If _Sleep($iDelayRunBot3) = False Then checkMainScreen(False)
		Case "UpgradeHeroes"
			UpgradeHeroes()
			_Sleep($iDelayRunBot3)
		Case "UpgradeBuilding"
			UpgradeBuilding()
			_Sleep($iDelayRunBot3)
		Case ""
			SetDebugLog("Function call doesn't support empty string, please review array size", $COLOR_RED)
		Case Else
			SetLog("Unknown function call: " & $action, $COLOR_RED)
	EndSwitch
	SetDebugLog("_RunFunction: " & $action & " END")
EndFunc   ;==>_RunFunction
