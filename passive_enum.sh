#!/bin/bash

ANEW_PATH="/home/pixel/go/bin/anew"
GITHUB_PATH="/home/pixel/go/bin/github-subdomains"
HTTPX_PATH=$(which httpx)
BASE_DIR=$(pwd)
TOKEN_FILE="$BASE_DIR/github_token.txt"

if [[ -f "$TOKEN_FILE" ]]; then
    GITHUB_TOKEN=$(<"$TOKEN_FILE")
    echo "[+] GitHub token loaded successfully."
else
    echo "[!] Warning: github_token.txt not found in $BASE_DIR. Skipping GitHub scans."
fi
# Getting input from terminal
echo "Enter the website domain:"
read domain
echo "You entered $domain. Is this correct? (y/n)"
read confirm
mkdir -p "$domain" && cd "$domain"

# Function to check for tools using their absolute paths
check_tools() {
    local missing=false
    
    # Check standard tools
    for tool in subfinder amass jq curl; do
        if ! command -v "$tool" &> /dev/null; then
            echo "[-] Error: $tool is missing."
            missing=true
        fi
    done

    # Check the Go tools using the paths we set above
    if [[ ! -x "$ANEW_PATH" ]]; then
        echo "[-] Error: anew not found at $ANEW_PATH"
        missing=true
    fi

    if [[ ! -x "$GITHUB_PATH" ]]; then
        echo "[-] Error: github-subdomains not found at $GITHUB_PATH"
        missing=true
    fi

    if [ "$missing" = true ]; then
        exit 1
    fi
    echo "[+] All tools found!"
}
check_tools



# Confirmation check
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then 
    
    echo "Confirmed. Starting scans..."
    
    # Subfinder scan
    subfinder -d "$domain" -silent -all -recursive -o subfinder_subs.txt
    
    # Amass scan
    amass enum -passive -d "$domain" -o amass_passive_subs.txt
    
    # Crtsh scan
    curl -s "https://crt.sh/?q=%25.${domain}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > crtsh_subs.txt
    
    # Github dorking
    $GITHUB_PATH -d "$domain" -t "$TOKEN_FILE" -o github_subs.txt
 
    
    # Subdomain aggregation
    cat subfinder_subs.txt amass_passive_subs.txt crtsh_subs.txt github_subs.txt 2>/dev/null | sort -u | $ANEW_PATH all_subs.txt
    
    

elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
    echo "Please rerun the script with the correct domain."
    exit 1
else
    echo "Invalid input. Exiting."
    exit 1
fi
