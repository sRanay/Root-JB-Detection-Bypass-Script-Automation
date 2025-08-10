#!/bin/bash

# Prompt the user for the target app package name and the folder containing Frida scripts
read -p "Enter the target app package name (e.g., com.example.app): " targetApp
read -p "Which Platform it is: " scriptFolder
read -p "Is this a remote device? (yes/y or no/n): " connectionType
read -p "Testing for SSL Pinning (S) or Root/JB Detection (D)? " typeofScriptsUsed


# Convert connectionType to lowercase for consistent checks
connectionType=$(echo "$connectionType" | tr '[:upper:]' '[:lower:]')

# Set Frida connection option based on user input
if [[ "$connectionType" == "yes" || "$connectionType" == "y" ]]; then
    read -p "Enter the IP address of the target: " ipAddr
    fridaOption="-H $ipAddr"
else
    fridaOption="-U"
fi

# Check if the folder exists
if [[ ! -d "$scriptFolder" ]]; then
    echo "The specified folder path does not exist. Exiting."
    exit 1
fi

typeofScriptsUsed=$(echo "$typeofScriptsUsed" | tr '[:upper:]' '[:lower:]')

if [[ "$typeofScriptsUsed" == "s" ]]; then
    scriptFolder=("$scriptFolder/SSL")
elif [[ "$typeofScriptsUsed" == "d" ]]; then
    scriptFolder=("$scriptFolder/Detection")
else
    echo "Invalid script type entered. Exiting."
    exit 1
fi    

# Find all .js files in the specified folder
scriptFiles=("$scriptFolder"/*.js)
scriptCount=${#scriptFiles[@]}

# Check if any .js scripts were found
if [[ $scriptCount -eq 0 || "${scriptFiles[0]}" == "$scriptFolder/*.js" ]]; then
    echo "No .js scripts found in the specified folder. Exiting."
    exit 1
fi

# Run each Frida script on the target app
for i in "${!scriptFiles[@]}"; do
    scriptPath="${scriptFiles[$i]}"
    scriptCurr=$((i + 1))
    echo "Running $scriptCurr/$scriptCount"
    echo "Running Frida script: $scriptPath on app: $targetApp"
    frida $fridaOption -f "$targetApp" -l "$scriptPath"
    read -p "Did the script successfully bypass? (yes/y or no/n): " isBypassed
    if [[ "$isBypassed" == "yes" || "$isBypassed" == "y" ]]; then
        echo "Script successfully bypassed"
        exit 0
    read -p "Press Enter to continue to the next script..."
done

echo "All scripts have been executed."
