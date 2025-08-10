@echo off
setlocal enabledelayedexpansion

:: Prompt the user for the target app package name and the folder containing Frida scripts
set /p targetApp="Enter the target app package name (e.g., com.example.app): "
set /p scriptFolder="Which Platform it is: "
set /p connectionType="Is this a remote device? (yes/y or no/n): "
set /p typeofScriptsUsed="Testing for SSL Pinning or Root/JB Detection? (S/s or D/d): "

:: Normalise the input to lowercase
set "connectionType=%connectionType%"
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "connectionType=!connectionType:%%A=%%A!"
)

:: Set Frida connection option
if /I "%connectionType%" EQU "yes" (
    set /p ipAddr="Enter the IP address of the target: "
    set fridaOption=-H %ipAddr%
) else if /I "%connectionType%" EQU "y" (
    set /p ipAddr="Enter the IP address of the target: "
    set fridaOption=-H %ipAddr%
) else (
    set fridaOption=-U
)

:: Check if the folder exists
if not exist "%scriptFolder%" (
    echo The specified folder path does not exist. Exiting.
    exit /b
)

:: Determine script subfolders to search
if /I "%typeofScriptsUsed%" EQU "s" (
    set "scriptFolder=%scriptFolder%\SSL"
) else if /I "%typeofScriptsUsed%" EQU "S" (
    set "scriptFolder=%scriptFolder%\SSL"
) else if /I "%typeofScriptsUsed%" EQU "d" (
    set "scriptFolder=%scriptFolder%\Detection"
) else if /I "%typeofScriptsUsed%" EQU "D" ( 
    set "scriptFolder=%scriptFolder%\Detection"
) else (
    echo Invalid script type entered. Exiting.
    exit /b
)

:: Find all .js files in the specified folder
set scriptCount=0
for %%f in ("%scriptFolder%\*.js") do (
    set "scriptFiles[!scriptCount!]=%%f"
    set /a scriptCount+=1
)

:: Check if any .js scripts were found
if %scriptCount% EQU 0 (
    echo No .js scripts found in the specified folder. Exiting.
    exit /b
)

:: Run each Frida script on the target app
set /A end=%scriptCount%-1
for /L %%i in (0,1,!end!) do (
    set "scriptPath=.\!scriptFiles[%%i]!"
    set /A scriptCurr = %%i+1
    echo Running !scriptCurr!/%scriptCount%
    echo Running Frida script: !scriptPath! on app: %targetApp%
    frida %fridaOption% -f %targetApp% -l "!scriptPath!"
    pause
    set /p isScriptWorked="Did the script worked? (yes/y or no/n): "
    if /I "%isScriptWorked%" EQU "yes" (
        goto :FinishedMidWay
    ) 
    if /I "%isScriptWorked%" EQU "y" (
        goto :FinishedMidWay
    )
)

echo All scripts have been executed.
pause

:FinishedMidWay
echo Script successfully bypassed
pause
