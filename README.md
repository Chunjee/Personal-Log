<div align="center">
    <img alt="personal-log header" src="https://github.com/Chunjee/personal-log/blob/main/assets/header.jpeg?raw=true"/>
</div>

## Overview

Personal Log is a very simple application designed to help users maintain a daily log or diary. A minimal GUI offers a blank space to write.

## Features

### Automatic Daily Log

- The application attempts to keep today's date open and editable at all times.
- Changes in the date trigger saving the current log.
- Changing the date also presents a blank log for the new date.
- All logs are saved as .txt files

### Options

#### Parent Directory

- Allows user to set the parent directory for saving logs.
- Takes user input for the save directory and saves it in the settings.
- This does not move any existing log files to the new parent. This could be useful if you want your logs to existing in an automatically backed up location.

#### Export Path

- Enables user to set the export path for saving .
- Takes user input for the export path and saves it in the settings.

#### Export All

- Exports all logs to a single file.
- This will recursively check all files and folders in the log parent directory and consolidate all files into one large file for easy uploading or backing up
- The is no import button however so you should backup the raw .txt log files ideally

## How to use the Main tab

3. **Saving Current Log:**
   - To manually save, click the "Save" button.

4. **Opening Log Files:**
   - Use the "Open" button any type in a title or date to start a new log.
   - The application will display the log content for the chosen date if any exist already.

## Important Notes

- Opening a custom log or date will cancel the automatic date update behavior.
- Ensure that the date format follows the YYYY.MM.DD format for best compatibility.

Feel free to explore and make the most of your Personal Log.