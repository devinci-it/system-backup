#!/bin/bash

print_colored_dot() {
    local color=$1
    local dot_color=""
    
    case "$color" in
        "yellow") dot_color=226 ;;
        "gray") dot_color=244 ;;
        "green") dot_color=40 ;;
        "red") dot_color=196 ;;
        *) echo "Unknown color"; return 1 ;;
    esac

    echo -e "\e[38;5;${dot_color}m ● \e[0m $2"
}


# Define colors
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Read contents of the .status file
STATUS=$(<"$HOME/SystemBackup/.status")

# Print table header
printf "%-25s %-50s\n" "careerhub.vincedetorres.bio | BackupManager"
printf "%-25s %-50s\n"

# Print colored status
if [[ $STATUS == *"Completed"* ]]; then
    print_colored_dot green "Latest backup attempt completed successfully."
    printf "%-25s %-50s\n"

    echo -e "${GREEN}$STATUS${RESET}"
else

    echo -e "${RED}$STATUS${RESET}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print the directory
