#!/bin/bash

# --- 1. Configuration & Logging ---
TARGET_URL=$1
WORDLIST="/usr/share/wordlists/dirb/common.txt"
TIMESTAMP=$(date +%s)
LOOT_DIR="./bubble_loot_${TIMESTAMP}"
REPORT_FILE="${LOOT_DIR}/final_report.txt"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; 
BLUE='\033[0;34m'; PURPLE='\033[1;35m'; CYAN='\033[0;36m'; NC='\033[0m'

if [ -z "$1" ]; then echo -e "${RED}Usage: ./bubble_scanner.sh <url>${NC}"; exit 1; fi
[[ "$TARGET_URL" != http* ]] && TARGET_URL="http://$TARGET_URL"

mkdir -p "$LOOT_DIR"
echo -e "BUBBLE-BASH SCAN REPORT - $(date)" > "$REPORT_FILE"
echo -e "TARGET: $TARGET_URL\n--------------------------" >> "$REPORT_FILE"

# --- 2. The Internal Scanners ---

# Hunt for hardcoded secrets in HTML source
scan_source_code() {
    local url=$1
    local content=$(curl -s -L "$url")
    
    # Check for secrets
    secrets=$(echo "$content" | grep -Ei "password|api_key|db_pass|secret|token" | grep "=" | cut -c 1-100)
    
    if [ ! -z "$secrets" ]; then
        msg="[!] SENSITIVE DATA IN SOURCE: $url"
        echo -e "${RED}$msg${NC}"
        echo -e "$msg\n$secrets\n" >> "${LOOT_DIR}/leaked_secrets.txt"
        echo -e "$msg" >> "$REPORT_FILE"
    fi
}

# Check for upload forms (Shell Hunting)
check_upload_vuln() {
    local url=$1
    form_check=$(curl -s -L "$url" | grep -Ei 'type=["'\'']file["'\'']')
    
    if [ ! -z "$form_check" ]; then
        msg="[!!!] UPLOAD FORM DETECTED: $url"
        echo -e "${RED}$msg${NC}"
        echo "$url" >> "${LOOT_DIR}/rce_targets.txt"
        echo -e "$msg" >> "$REPORT_FILE"
    fi
}

# --- 3. Main Bubble-Dive Engine ---
bubble_dive() {
    local base_url=$1
    echo -e "\n${PURPLE}--- DIVE START: $base_url ---${NC}"
    echo -e "\nPHASE: FUZZING & SOURCE SCAN\n" >> "$REPORT_FILE"
    
    head -n 1000 "$WORDLIST" | while read -r path; do
        url="${base_url%/}/${path}"
        res=$(curl -s -o /dev/null -w "%{http_code}" "$url" --connect-timeout 2)

        if [ "$res" == "200" ]; then
            msg="[!] POP! Found: $url"
            echo -e "${YELLOW}$msg${NC}"
            echo "$msg" >> "$REPORT_FILE"
            
            # Run all sub-scanners on discovered page
            scan_source_code "$url"
            check_upload_vuln "$url"

            # SQLi Check
            if curl -s "${url}?id='" | grep -Ei "sql|mysql|error|syntax" >/dev/null; then
                sqli_msg="    └─ [!!!] SQLi VULNERABILITY DETECTED"
                echo -e "${RED}$sqli_msg${NC}"
                echo "$sqli_msg" >> "$REPORT_FILE"
                echo "$url" >> "${LOOT_DIR}/sqli_urls.txt"
            fi
        fi
    done
}

# --- 4. Execution & Final Wrap ---
clear
echo -e "${CYAN}"
echo '      _.._      _.._      _.._ '
echo '    ."    ".  ."    ".  ."    ". '
echo -e "${PURPLE}  ● BUBBLE-BASH REPORT EDITION V37.0 ● ${NC}"
echo -e "${CYAN}   Loot & TXT Report: $LOOT_DIR ${NC}\n"

bubble_dive "$TARGET_URL"

echo -e "\n${PURPLE}=============================================${NC}"
echo -e "             SCAN COMPLETE                   "
echo -e "=============================================${NC}"
echo -e "${GREEN}[+] All findings saved to: $REPORT_FILE${NC}"
echo -e "${GREEN}[+] Leaked files and secrets saved in: $LOOT_DIR${NC}"
echo -e "${PURPLE}=============================================${NC}"

# Add summary to the TXT report
echo -e "\n--------------------------\nSCAN FINISHED: $(date)" >> "$REPORT_FILE"

