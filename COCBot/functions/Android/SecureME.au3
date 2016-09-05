; #FUNCTION# ====================================================================================================================
; Name ..........: Secure ME
; Description ...: Secure MyBOT and Prevent CoC to be Able To Detect It By Folders/Files Created By MyBOT
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........: MR.ViPER
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
DeleteOtherFoldersInSharedFolder()

Func RemoveFolderFromInUseList()
	Local $folder = StringReplace($AndroidPicturesHostFolder, "\", "")
	If IsFolderInUse($folder) = True Then
		Local $inUseList = ""
		Local $inUsePath = $HKLM & "\SOFTWARE\MyBOT"
		$inUseList = RegRead($inUsePath, "inUse")
		$inUseList = StringReplace($inUseList, $folder & "|", "")
		;---- Update inUse Registery
		RegWrite($inUsePath, "inUse", "REG_SZ", $inUseList)
	EndIf
EndFunc   ;==>RemoveFolderFromInUseList

Func AddFolderToInUseList()
	Local $folder = StringReplace($AndroidPicturesHostFolder, "\", "")
	If IsFolderInUse($folder) = False Then
		Local $inUseList = ""
		;Local $inUsePath = @ScriptDir & "\inUse.txt"
		Local $inUsePath = $HKLM & "\SOFTWARE\MyBOT"
		$inUseList = RegRead($inUsePath, "inUse")
		$inUseList = StringReplace($inUseList, $folder & "|", "")
		$inUseList &= $folder & "|"
		;---- Update inUse Registery
		RegWrite($inUsePath, "inUse", "REG_SZ", $inUseList)
	EndIf
EndFunc   ;==>AddFolderToInUseList

Func IsFolderInUse($folderName = "lol")
	Local $inUsePath = $HKLM & "\SOFTWARE\MyBOT"
	Local $inUseList = ""
	$inUseList = RegRead($inUsePath, "inUse")
	;---- Split Data To Get Each Folder Name
	$inUseList = StringSplit($inUseList, "|", 2)
	For $i = 0 To UBound($inUseList) - 1
		If $inUseList[$i] = $folderName Then Return True
	Next
	Return False
	Return False
EndFunc   ;==>IsFolderInUse

Func PrepareAADBSSCMD($cmd)
	Local $fPath = ""
	If StringRegExp($cmd, "(?<=sh "")([\s\S]+)(?="")", 0) = True Then
		$newcmd = StringReplace($cmd, $AndroidPicturesPath, $AndroidPicturesHostPath)
		$newcmd = StringReplace($newcmd, $AndroidPicturesHostPath & StringReplace($AndroidPicturesHostFolder, "\", "") & "/", $AndroidPicturesHostPath & $AndroidPicturesHostFolder)
		$fPath = StringRegExp($newcmd, "(?<=sh "")([\s\S]+)(?="")", 1)[0]
		$decStatus = DecFile($fPath)
		If $decStatus Then DecSubScripts(FileRead($fPath))
		If $decStatus Then Return True
		If $decStatus = False Then Return False
	EndIf
EndFunc   ;==>PrepareAADBSSCMD

Func AfterAADBSSCMD($cmd)
	Local $fPath = ""
	If StringRegExp($cmd, "(?<=sh "")([\s\S]+)(?="")", 0) = True Then
		$newcmd = StringReplace($cmd, $AndroidPicturesPath, $AndroidPicturesHostPath)
		$newcmd = StringReplace($newcmd, $AndroidPicturesHostPath & StringReplace($AndroidPicturesHostFolder, "\", "") & "/", $AndroidPicturesHostPath & $AndroidPicturesHostFolder)
		$fPath = StringRegExp($newcmd, "(?<=sh "")([\s\S]+)(?="")", 1)[0]
		EncSubScripts(FileRead($fPath))
		$encStatus = EncFile($fPath)
	EndIf
EndFunc   ;==>AfterAADBSSCMD

Func DeleteOtherFoldersInSharedFolder()
	$allFolders = _FileListToArray($AndroidPicturesHostPath, "*", 2, False)
	;_ArrayDisplay($allFolders)
	For $i = 1 To UBound($allFolders) - 1
		If IsFolderInUse($allFolders[$i]) = False Then
			DirRemove($AndroidPicturesHostPath & $allFolders[$i], 1)
		EndIf
	Next
EndFunc   ;==>DeleteOtherFoldersInSharedFolder

Func DeletePicturesHostFolder($isClosingBot = True)
	DirRemove($AndroidPicturesHostPath & $AndroidPicturesHostFolder, 1)
	$allFolders = _FileListToArray($AndroidPicturesHostPath, "*", 2, False)
	;_ArrayDisplay($allFolders)
	For $i = 1 To UBound($allFolders) - 1
		If IsFolderInUse($allFolders[$i]) = False Then
			DirRemove($AndroidPicturesHostPath & $allFolders[$i], 1)
		EndIf
	Next
	If $isClosingBot = True Then RemoveFolderFromInUseList()
EndFunc   ;==>DeletePicturesHostFolder

Func DeleteOfficialFolder()
	If FileExists($AndroidPicturesHostPath & "mybot.run\") Then DirRemove($AndroidPicturesHostPath & "mybot.run\", 1)
EndFunc   ;==>DeleteOfficialFolder

Func DecSubScripts($content)
	If StringRegExp($content, "(?<=if\=)([\s\S]+?)(?=\ )") Then
		$arrFiles = StringRegExp($content, "(?<=if\=)([\s\S]+?)(?=\ )", 3)
		For $i = 0 To UBound($arrFiles) - 1
			$file = $arrFiles[$i]
			$file = StringReplace($file, "$SCRIPTPATH/", $AndroidPicturesHostPath & $AndroidPicturesHostFolder)
			$dStatus = DecFile($file)
		Next
	EndIf
EndFunc   ;==>DecSubScripts

Func EncSubScripts($content)
	;Return
	If StringRegExp($content, "(?<=if\=)([\s\S]+?)(?=\ )") Then
		$arrFiles = StringRegExp($content, "(?<=if\=)([\s\S]+?)(?=\ )", 3)
		For $i = 0 To UBound($arrFiles) - 1
			$file = $arrFiles[$i]
			$file = StringReplace($file, "$SCRIPTPATH/", $AndroidPicturesHostPath & $AndroidPicturesHostFolder)
			EncFile($file)
		Next
	EndIf
EndFunc   ;==>EncSubScripts

Func DecFile($file)
	If FileExists($file) Then
		$Read = FileOpen($file, 0)
		$data = FileRead($Read)
		FileClose($Read)
		;msgbox(0,"$data","file: " & $file & @CRLF & $data)
		$decryptedData = _Crypt_DecryptData($data, $pwToDecrypt, $CALG_AES_256)
		If @error Then
			If @error = 20 Then Return False
		Else
			$New = FileOpen($file, 2)
			FileWrite($New, BinaryToString($decryptedData))
			FileClose($New)
			Return True
		EndIf
	Else
		SetLog("File Doesn't Exist: " & $file, $COLOR_RED)
	EndIf
	Return False
EndFunc   ;==>DecFile

Func EncFile($file)
	;Return
	If FileExists($file) Then
		$Read = FileOpen($file, 0)
		$data = FileRead($Read)
		FileClose($Read)
		$encryptedData = _Crypt_EncryptData($data, $pwToDecrypt, $CALG_AES_256)
		If @error Then
			If @error = 20 Then Return False
		Else
			$New = FileOpen($file, 2)
			FileWrite($New, $encryptedData)
			FileClose($New)
			Return True
		EndIf
	Else
		SetLog("File Doesn't Exist: " & $file, $COLOR_RED)
	EndIf
	Return False
EndFunc   ;==>EncFile

Func FilterFile($scriptFile)
	$tmpscriptFile = StringReplace($scriptFile, "ZoomOut", $zoomOutReplace)
	$tmpscriptFile = StringReplace($tmpscriptFile, "OverWaters", $overwatersReplace)
	$tmpscriptFile = StringReplace($tmpscriptFile, ".script", $scriptExt)
	$tmpscriptFile = StringReplace($tmpscriptFile, ".sh", $shExt)
	$tmpscriptFile = StringReplace($tmpscriptFile, "shell.init", $shellScriptInitFileName)
	$tmpscriptFile = StringReplace($tmpscriptFile, "BlueStacks2", $replaceofBluestacks2name)
	$tmpscriptFile = StringReplace($tmpscriptFile, "BlueStacks", $replaceofBluestacksname)
	$tmpscriptFile = StringReplace($tmpscriptFile, "Droid4X", $replaceOfDroid4xName)
	Return $tmpscriptFile
EndFunc   ;==>FilterFile

Func CreateSecureMEVars($showLog = False)
	$rgbaExt = GenerateRandom("", True)
	$shExt = GenerateRandom("", True)
	$clickExt = GenerateRandom("", True)
	$scriptExt = GenerateRandom("", True)
	$geteventExt = GenerateRandom("", True)
	$moveawayExt = GenerateRandom("", True)
	;--- File Names
	$replaceOfBotTitle = GenerateRandom("", False, Random(4, 10, 1))
	$shellScriptInitFileName = GenerateRandom("", False, Random(4, 8, 1))
	$clickDragFileName = GenerateRandom("", False, Random(4, 8, 1))

	$replaceofBluestacks2name = GenerateRandom("", False, Random(4, 8, 1))
	$replaceofBluestacksname = GenerateRandom("", False, Random(4, 8, 1))
	$replaceOfDroid4xName = GenerateRandom("", False, Random(4, 8, 1))
	;--- Scripts
	$overwatersReplace = GenerateRandom("", False, Random(4, 8, 1))
	$zoomOutReplace = GenerateRandom("", False, Random(4, 8, 1))
	;--- Folders
	$replaceOfMyBotFolder = GenerateRandom("", False, Random(4, 8, 1))
	;--- Decrypt Password
	$pwToDecrypt = GenerateRandom("", False, Random(8, 15, 1), True, True)

	If $showLog = True Then
		MsgBox(0, "", ".rgba Replaced Ext.: " & $rgbaExt)
		MsgBox(0, "", ".sh Replaced Ext.: " & $shExt)
		MsgBox(0, "", ".click Replaced Ext.: " & $clickExt)
		MsgBox(0, "", ".script Replaced Ext.: " & $scriptExt)
		MsgBox(0, "", ".getevent Replaced Ext.: " & $geteventExt)
		MsgBox(0, "", ".moveaway Replaced Ext.: " & $moveawayExt)
		;--- File Names
		MsgBox(0, "", "Bot Title Replaced Name: " & $replaceOfBotTitle)
		MsgBox(0, "", "Shell Script Init Replaced Name: " & $shellScriptInitFileName)
		MsgBox(0, "", "Click Drag Replaced Name: " & $clickDragFileName)
		;--- Folders
		MsgBox(0, "", "mybot.run Host Folder Replaced Name: " & $replaceOfMyBotFolder)
	EndIf
EndFunc   ;==>CreateSecureMEVars

Func GenerateRandom($anString = "", $anExt = False, $len = 3, $letter = True, $num = False, $caseSens = True)
	If $anExt = True Then Return GetRandomExt()
	Select
		Case $anString = ""
			$pwd = ""
			Dim $aSpace[3]
			$digits = $len
			For $i = 1 To $digits
				If $letter = True And $num = False Then
					If $caseSens = True Then $aSpace[0] = Chr(Random(65, 90, 1)) ;A-Z
					$aSpace[1] = Chr(Random(97, 122, 1)) ;a-z
					$pwd &= $aSpace[Random(0, UBound($aSpace) - 1, 1)]
				ElseIf $letter And $num Then
					If $caseSens = True Then $aSpace[0] = Chr(Random(65, 90, 1)) ;A-Z
					$aSpace[1] = Chr(Random(97, 122, 1)) ;a-z
					$aSpace[2] = Chr(Random(48, 57, 1)) ;0-9
					$pwd &= $aSpace[Random(0, UBound($aSpace) - 1, 1)]
				ElseIf $num And $letter = False Then
					$aSpace[0] = Chr(Random(48, 57, 1)) ;0-9
					$pwd &= $aSpace[0]
				EndIf
			Next
			Return $pwd
		Case Else
			Return $anString
	EndSelect
EndFunc   ;==>GenerateRandom

Func GetRandomExt()
	$extListFile = @ScriptDir & "\extensions.txt"
	If FileExists($extListFile) Then
		Return FileReadLine($extListFile, Random(1, _FileCountLines($extListFile), 1))
	Else
		Return -1
	EndIf
EndFunc   ;==>GetRandomExt
