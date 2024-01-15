#NoEnv
#NoTrayIcon
SetBatchLines, -1
#SingleInstance force

#Include %A_ScriptDir%\node_modules
#Include biga.ahk\export.ahk
#Include json.ahk\export.ahk
#Include wrappers.ahk\export.ahk
#Include neutron.ahk\export.ahk

; other dependancies
; fileInstall dependencies
fileInstall, gui\index.html, gui\index.html
fileInstall, gui\bootstrap.min.css, gui\bootstrap.min.css
fileInstall, gui\bootstrap.min.js, gui\bootstrap.min.js
fileInstall, gui\jquery.min.js, gui\jquery.min.js



; settings
settings_location := A_ScriptDir "\settings.json"
; read settings file if exists
settingsContent := fileRead(settings_location)
; create new settings file if none found
if (biga.size(settingsContent) < 10) {
	settingsObj := {}
	settingsObj.saveDirParent := A_ScriptDir "\data"
	settingsObj.exportFilePath := A_ScriptDir "\export.txt"
	settingsStr := JSON.stringify(settingsObj)
	fileAppend(settingsStr, settings_location)
} else {
	; write settings to settings object
	settingsObj := JSON.parse(settingsContent)
	; ensure settings has saveDirParent and exportFilePath
	if (!biga.isString(settingsObj.saveDirParent)) {
		msgbox, % "saveDirParent is missing from settings. The application will quit"
		exitApp 
	}
	if (!biga.isString(settingsObj.exportFilePath)) {
		msgbox, % "exportFilePath is missing from settings. The application will quit"
		exitApp 
	}
}


; variables
global A := new biga()



; Create a new NeutronWindow and navigate to our HTML page
neutron := new NeutronWindow()
neutron.Load("gui\index.html")
; Use the Gui method to set a custom label prefix for GUI events.
neutron.Gui("+LabelNeutron")
neutron.Show("w1200 h900")


; send settings to gui
neutron.doc.getElementById("saveDir").innerText := settingsObj.saveDirParent
neutron.doc.getElementById("exportPath").innerText := settingsObj.exportFilePath



;; === Main ===
; set the main gui to today's date and keep updating every 1 min
sb_updateDate()
setTimer, sb_updateDate, % 60 * 1000



return



; ------------------
; Timers
; ------------------

sb_updateDate()
{
	global

	currentDate := A_YYYY "." A_MM "." A_DD
	if (currentDate != neutron.doc.getElementById("mainDate").innerText) {
		neutron.doc.getElementById("mainDate").innerText := A_YYYY "." A_MM "." A_DD
		; attempt save
		sb_saveCurrent()
		neutron.qs("#mainText").innerText := ""
	}

	; read file if no text currently
	currentText := neutron.qs("#mainText").innerText
	if (biga.size(currentText) < 4) {
		sb_openFile(currentDate)
	}
}



; ------------------
; Gui Buttons
; ------------------

sb_saveParent(neutron, event) {
	global
	
	event.preventDefault()

	userInput := neutron.GetFormData(event.target).saveDir
	settingsObj.saveDirParent := userInput
	sb_saveSettings()
}

sb_saveExport(neutron, event) {
	global

	event.preventDefault()

	userInput := neutron.GetFormData(event.target).exportPath
	settingsObj.exportFilePath := userInput
	sb_saveSettings()
}

sb_saveSettings() {
	global

	settingsStr := JSON.stringify(settingsObj)
	fileDelete(settings_location)
	fileAppend(settingsStr, settings_location)
}

sb_saveCurrent(neutron:="", event:="")
{
	global

	currentDate := neutron.qs("#mainDate").innerText
	currentText := neutron.qs("#mainText").innerText

	; create the dir
	dateArr := strSplit(currentDate, ".")
	FileCreateDir(settingsObj.saveDirParent "\" dateArr[1])
	; create the file
	if (biga.size(currentText) > 4) {
		filePath_save := settingsObj.saveDirParent "\" dateArr[1] "\" currentDate ".txt"
		fileDelete(filePath_save)
		l_file := fileOpen(filePath_save, "rw", "UTF-8")
		l_file.write(currentText)
		l_file.close()
	}
}

sb_openFile(para_date)
{
	global

	; understand the path
	currentDate := neutron.qs("#mainDate").innerText
	dateArr := strSplit(currentDate, ".")
	filePath_selected := settingsObj.saveDirParent "\" dateArr[1] "\" currentDate ".txt"

	; open the file and get contents
	l_file := fileRead(filePath_selected)

	; assign contents to the GUI
	neutron.qs("#mainText").innerText := l_file
}

sb_openBTN(para_date)
{
	global

	; Get the new date user wants to work on
	userInput_title := InputBox(this_projectName, "Enter the log's title`na date is recomended in YYYY.MM.DD format")
	if (userInput_title == "" || ErrorLevel == 1) {
		return
	}
	; turn off timer that auto-tries new date
	setTimer, sb_updateDate, Off
	dateArr := strSplit(userInput_title, ".")
	if (biga.size(dateArr[1]) == 4) {
		filePath_selected := settingsObj.saveDirParent "\" dateArr[1] "\" userInput_title ".txt"
	} else {
		filePath_selected := settingsObj.saveDirParent "\" biga.trim(userInput_title) ".txt"
	}
	; understand the path
	neutron.qs("#mainDate").innerText := userInput_title	

	; open the file and get contents
	l_file := fileRead(filePath_selected)

	; assign contents to the GUI
	neutron.qs("#mainText").innerText := l_file
}

sb_exportBTN(neutron, event)
{
	global

	event.preventDefault()

	fileDelete(settingsObj.exportFilePath)
	l_path := settingsObj.saveDirParent "\*.txt"
	loop, files, % l_path, R
	{
		msgbox, % A_LoopFilePath
		l_contents := fileRead(A_LoopFilePath)
		l_date := strSplit(A_LoopFileName, ".txt")[1]
		fileAppend("## " l_date "`n" l_contents "`n`n", settingsObj.exportFilePath)
	}
}

NeutronClose:
exitApp
return


; ------------------
; functions
; ------------------

fn_chunkTable(param_data)
{
	; would be nice if this lined them verticle, currently horizontal
	l_data := biga.chunk(param_data, 5)
	return l_data
}
