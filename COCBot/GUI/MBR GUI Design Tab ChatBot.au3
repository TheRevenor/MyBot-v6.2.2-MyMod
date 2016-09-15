; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Tab Chat Bot
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: 
; Modified ......: TheRevenor (2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
$hGUI_ChatBot = GUICreate("", $_GUI_MAIN_WIDTH - 28, $_GUI_MAIN_HEIGHT - 255 - 28, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $hGUI_MOD)
GUISetBkColor($COLOR_WHITE, $hGUI_ChatBot)

GUISwitch($hGUI_ChatBot)

$chatIni = $sProfilePath & "\" & $sCurrProfile & "\chat.ini"
ChatbotReadSettings()

Local $x = 20, $y = 20

GUICtrlCreateGroup("Global Chat", $x - 20, $y - 20, 218, 366)
$y -= 5
$chkGlobalChat = GUICtrlCreateCheckbox("Advertise in global", $x - 9, $y)
_GUICtrlSetTip($chkGlobalChat, "Use global chat to send messages")
GUICtrlSetState($chkGlobalChat, $ChatbotChatGlobal)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 18
$chkGlobalScramble = GUICtrlCreateCheckbox("Scramble global chats", $x - 9, $y)
_GUICtrlSetTip($chkGlobalScramble, "Scramble the message pieces defined in the textboxes below to be in a random order")
GUICtrlSetState($chkGlobalScramble, $ChatbotScrambleGlobal)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 18
$chkSwitchLang = GUICtrlCreateCheckbox("Switch languages", $x - 9, $y)
_GUICtrlSetTip($chkSwitchLang, "Switch languages after spamming for a new global chatroom")
GUICtrlSetState($chkSwitchLang, $ChatbotSwitchLang)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
;$y += 22
;$ChatbotChatDelayLabel = GUICtrlCreateLabel("Chat Delay", $x - 9, $y)
;GUICtrlSetTip($ChatbotChatDelayLabel, "Delay chat between number of bot cycles")
;$chkchatdelay = GUICtrlCreateInput("0", $x + 50, $y - 1, 35, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
;GUICtrlSetLimit(-1, 2)
$y += 25
$editGlobalMessages1 = GUICtrlCreateEdit(_ArrayToString($GlobalMessages1, @CRLF), $x - 9, $y, 200, 66)
_GUICtrlSetTip($editGlobalMessages1, "Take one item randomly from this list (one per line) and add it to create a message to send to global")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")
$y += 71
$editGlobalMessages2 = GUICtrlCreateEdit(_ArrayToString($GlobalMessages2, @CRLF), $x - 9, $y, 200, 66)
_GUICtrlSetTip($editGlobalMessages2, "Take one item randomly from this list (one per line) and add it to create a message to send to global")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")
$y += 71
$editGlobalMessages3 = GUICtrlCreateEdit(_ArrayToString($GlobalMessages3, @CRLF), $x - 9, $y, 200, 66)
_GUICtrlSetTip($editGlobalMessages3, "Take one item randomly from this list (one per line) and add it to create a message to send to global")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")
$y += 71
$editGlobalMessages4 = GUICtrlCreateEdit(_ArrayToString($GlobalMessages4, @CRLF), $x - 9, $y, 200, 66)
_GUICtrlSetTip($editGlobalMessages4, "Take one item randomly from this list (one per line) and add it to create a message to send to global")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")
$y += 71
GUICtrlCreateGroup("", -99, -99, 1, 1)

Local $x = 241, $y = 20

GUICtrlCreateGroup("Clan Chat", $x - 20, $y - 20, 218, 366)
$chkClanChat = GUICtrlCreateCheckbox("Chat in clan chat", $x - 9, $y)
_GUICtrlSetTip($chkClanChat, "Use clan chat to send messages")
GUICtrlSetState($chkClanChat, $ChatbotChatClan)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 25
$chkUseResponses = GUICtrlCreateCheckbox("Use custom responses", $x - 9, $y)
_GUICtrlSetTip($chkUseResponses, "Use the keywords and responses defined below")
GUICtrlSetState($chkUseResponses, $ChatbotClanUseResponses)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 25
$chkUseGeneric = GUICtrlCreateCheckbox("Use generic chats", $x - 9, $y)
_GUICtrlSetTip($chkUseGeneric, "Use generic chats if reading the latest chat failed or there are no new chats")
GUICtrlSetState($chkUseGeneric, $ChatbotClanAlwaysMsg)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 25
$chkChatPushbullet = GUICtrlCreateCheckbox("Use PushBullet or Telegram for chat", $x - 9, $y)
_GUICtrlSetTip($chkChatPushbullet, "Send and recieve chats via pushbullet or telegram. Use BOT <myvillage> GETCHATS <INTERVAL|NOW|STOP> to get the latest clan chat as an image, and BOT <myvillage> SENDCHAT <chat message> to send a chat to your clan")
GUICtrlSetState($chkChatPushbullet, $ChatbotUsePushbullet)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
$y += 25
$chkPbSendNewChats = GUICtrlCreateCheckbox("Notify me new clan chat", $x - 9, $y)
_GUICtrlSetTip($chkPbSendNewChats, "Will send an image of your clan chat via pushbullet & telegram when a new chat is detected. Not guaranteed to be 100% accurate.")
GUICtrlSetState($chkPbSendNewChats, $ChatbotPbSendNew)
GUICtrlSetOnEvent(-1, "ChatGuiCheckboxUpdate")
GUICtrlSetState(-1, $GUI_CHECKED)
$y += 29
$ChatbotChatDelayLabel = GUICtrlCreateLabel("Chat Delay", $x - 9, $y)
_GUICtrlSetTip($ChatbotChatDelayLabel, "Delay chat between number of bot cycles")
$chkchatdelay = GUICtrlCreateInput("0", $x + 50, $y - 1, 35, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
GUICtrlSetLimit(-1, 2)
   
$y += 25
$editResponses = GUICtrlCreateEdit(_ArrayToString($ClanResponses, ":", -1, -1, @CRLF), $x - 9, $y, 200, 96)
_GUICtrlSetTip($editResponses, "Look for the specified keywords in clan messages and respond with the responses. One item per line, in the format keyword:response")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")
$y += 101
$editGeneric = GUICtrlCreateEdit(_ArrayToString($ClanMessages, @CRLF), $x - 9, $y, 200, 80)
_GUICtrlSetTip($editGeneric, "Generic messages to send, one per line")
GUICtrlSetOnEvent(-1, "ChatGuiEditUpdate")

GUICtrlCreateGroup("", -99, -99, 1, 1)
   
ChatGuicheckboxUpdateAT()

Global $LastControlToHideMOD = GUICtrlCreateDummy()
Global $iPrevState[$LastControlToHideMOD + 1]
