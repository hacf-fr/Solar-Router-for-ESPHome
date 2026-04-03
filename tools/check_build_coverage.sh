#!/bin/bash

EXIT_STATUS=0

# Use the tput command for colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

for iloop in $(ls solar_router/*); do 
    # Extract the filename without the relative path
    filename=$(basename "$iloop")
    
    echo -n "$iloop -> "
    
    # First search within .yaml files
    if grep  "$iloop" *.yaml | grep -v local > /dev/null; then
        COUNT=$(grep $iloop *.yaml 2> /dev/null | wc -l)
        echo "${GREEN}OK ($COUNT)${RESET}"
    else
        # If not found, search for the filename within the solar_router directory files
        if grep -r "$filename" solar_router/*.yaml > /dev/null; then
            echo "${GREEN}OK (include)${RESET}"
        else
            echo "${RED}KO${RESET}"
            EXIT_STATUS=1
        fi
    fi
done

exit $EXIT_STATUS