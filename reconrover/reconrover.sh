#!/bin/bash

# Banner
banner() {
  echo "======================================"
  echo "        ReconRover CLI & Web based- Bug Bounty       "
  echo "======================================"
  echo "Author: Inayat Hussain"
  echo ""
}

# Show menu
menu() {
  echo "Select an option:"
  echo " 1) Subfinder"
  echo " 2) Httpx"
  echo " 3) Nuclei"
  echo " 4) Dalfox"
  echo " 5) JSFinder"
  echo " 6) GitHub Dork"
  echo " 7) Shodan"
  echo " 8) Corsy"
  echo " 9) Knockpy"
  echo "10) Subjack"
  echo "11) Katana"
  echo "12) Waybackurls"
  echo "13) Aquatone"
  echo "14) Httprobe"
  echo "15) Dnsenum"
  echo "16) Sqlmap"
  echo "17) CMSeek"
  echo "18) WhatWeb"
  echo "19) wafw00f "
  echo "20) Start Web GUI"
  echo " 0) Exit"
}

# Run tool based on selection
run_tool() {
  local domain="$1"
  local tool="$2"

  case "$tool" in
    1) subfinder -d "$domain" ;;
    2) echo "$domain" | httpx ;;
    3) nuclei -u "https://$domain" ;;
    4) dalfox url "https://$domain" ;;
    5) python3 modules/jsfinder.py -u "https://$domain" ;;
    6) python3 modules/github-dork.py "$domain" ;;
    7) shodan host "$domain" ;;
    8) corsy -u "https://$domain" ;;
    9) knockpy "$domain" ;;
    10) subjack -w "output/${domain}_subdomains.txt" -t 100 -timeout 30 -o "output/${domain}_subjack.txt" ;;
    11) katana -u "https://$domain" -json -o "output/${domain}_katana.json" ;;
    12) echo "$domain" | waybackurls ;;
    13) echo "$domain" | aquatone -out "output/${domain}_aquatone" ;;
    14) echo "$domain" | httprobe ;;
    15) dnsenum "$domain" ;;
    16) sqlmap -u "https://$domain" --batch --crawl=1 ;;
    17) cMseek -d "$domain" --no-plugins ;;
    18) whatweb "https://$domain" ;;
    19) wafw00f -d "$domain" ;;
    20) ./reconrover.sh --web ;;  # Relaunch GUI
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option!" ;;
  esac
}

# Main Execution
banner

# --web switch
if [[ "$1" == "--web" ]]; then
  echo "[+] Starting ReconRover Web GUI on http://127.0.0.1:5000 ..."
  cd "$(dirname "$0")"
  python3 app.py
  exit 0
fi

while true; do
  menu
  read -rp "Enter choice (0-20): " choice

  if [[ "$choice" == "20" ]]; then
    echo "[+] Starting Web GUI..."
    ./reconrover.sh --web
    break
  elif [[ "$choice" == "0" ]]; then
    echo "Goodbye!"
    break
  fi

  read -rp "Enter domain: " domain
  if [[ -z "$domain" ]]; then
    echo "[!] No domain entered. Try again."
    continue
  fi

  echo "[*] Running tool #$choice on $domain ..."
  echo "------------------------------------------"
  run_tool "$domain" "$choice"
  echo "------------------------------------------"
  echo ""
  read -rp "Press Enter to return to menu..."
done

