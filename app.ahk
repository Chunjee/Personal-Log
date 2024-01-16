#NoEnv
#NoTrayIcon
SetBatchLines, -1
#SingleInstance force

;; dependancies
#Include %A_ScriptDir%\node_modules
#Include biga.ahk\export.ahk
#Include json.ahk\export.ahk
#Include wrappers.ahk\export.ahk
#Include neutron.ahk\export.ahk

; fileInstall dependencies
fileInstall, gui\index.html, gui\index.html
fileInstall, gui\index.js, gui\index.js
fileInstall, gui\bootstrap.min.css, gui\bootstrap.min.css
fileInstall, gui\bootstrap.min.js, gui\bootstrap.min.js
fileInstall, gui\jquery.min.js, gui\jquery.min.js


;; settings
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


;; global variables
global A := new biga()
g_dateRegex := "/^\d{4}\.\d{2}\.\d{2}$/"



;; === Main ===
;; Create NeutronWindow GUI and navigate to main page
neutron := new NeutronWindow()
neutron.Load("gui\index.html")
neutron.Maximize()
; Use the Gui method to set a custom label prefix for GUI events.
neutron.Gui("+LabelNeutron")
neutron.Show()

; send settings strings to GUI
neutron.doc.getElementById("saveDir").innerText := settingsObj.saveDirParent
neutron.doc.getElementById("exportPath").innerText := settingsObj.exportFilePath

;; set the main GUI to today's date and keep updating every 1 min
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
		sb_saveCurrent(neutron)
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

sb_saveParent(neutron, event)
{
	global
	
	event.preventDefault()

	userInput := neutron.GetFormData(event.target).saveDir
	settingsObj.saveDirParent := userInput
	sb_saveSettings()
}

sb_saveExport(neutron, event)
{
	global

	event.preventDefault()

	userInput := neutron.GetFormData(event.target).exportPath
	settingsObj.exportFilePath := userInput
	sb_saveSettings()
}

sb_saveSettings()
{
	global

	settingsStr := JSON.stringify(settingsObj)
	fileDelete(settings_location)
	fileAppend(settingsStr, settings_location)
}

sb_saveCurrent(neutron:="", event:="")
{
	global

	currentTitle := biga.trim(neutron.qs("#mainDate").innerText)
	currentText := neutron.qs("#mainText").innerText

	; create the dir
	if (biga.size(currentText) > 4) {
		if (biga.includes(currentTitle, g_dateRegex)) {
			dateArr := strSplit(currentTitle, ".")
			fileCreateDir(settingsObj.saveDirParent "\" dateArr[1])
			filePath_selected := settingsObj.saveDirParent "\" dateArr[1] "\" currentTitle ".txt"
		} else {
			filePath_selected := settingsObj.saveDirParent "\" currentTitle ".txt"
		}
		fileDelete(filePath_selected)
		l_file := fileOpen(filePath_selected, "rw", "UTF-8")
		l_file.write(currentText)
		l_file.close()
	}
}

sb_openFile(para_date)
{
	global

	; understand the path
	currentTitle := biga.trim(neutron.qs("#mainDate").innerText)
	; treat differently depending if user entered plain date or not
	if (biga.includes(currentTitle, g_dateRegex)) {
		dateArr := strSplit(currentTitle, ".")
		filePath_selected := settingsObj.saveDirParent "\" dateArr[1] "\" currentTitle ".txt"
	} else {
		filePath_selected := settingsObj.saveDirParent "\" currentTitle ".txt"
	}

	; open the file and get contents
	l_file := fileRead(filePath_selected)

	; assign contents to the GUI
	neutron.qs("#mainText").innerText := l_file
}

sb_openBTN(event)
{
	global

	event.preventDefault()

	; Get the new date user wants to work on
	userInput_title := trim(InputBox(this_projectName, "Enter the log's title`nA date in YYYY.MM.DD format is recomended"))
	if (userInput_title == "" || ErrorLevel == 1) {
		return
	}
	; turn off timer that auto-tries new date
	setTimer, sb_updateDate, Off
	dateArr := strSplit(userInput_title, ".")
	if (biga.includes(currentTitle, g_dateRegex)) {
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
		l_contents := fileRead(A_LoopFilePath)
		l_date := strSplit(A_LoopFileName, ".txt")[1]
		fileAppend("## " l_date "`n" l_contents "`n`n", settingsObj.exportFilePath)
	}
}

NeutronClose:
sb_saveCurrent(neutron)
exitApp


; ------------------
; functions
; ------------------
