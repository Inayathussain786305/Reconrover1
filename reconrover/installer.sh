#!/bin/bash

echo "======================================"
echo "      ReconRover Installer Script     "
echo "======================================"
echo "Installing required tools..."
echo ""

sleep 1

# Update & install system dependencies
sudo apt update && sudo apt install -y \
  python3 python3-pip git curl wget nmap dnsutils \
  subfinder httpx nuclei golang jq chromium-browser \
  build-essential libssl-dev libffi-dev python3-dev

# Install Dalfox (XSS Scanner)
go install github.com/hahwul/dalfox/v2@latest
export PATH=$PATH:$(go env GOPATH)/bin

# Install JSFinder (place your own jsfinder.py in modules/)
pip3 install requests

# Install GitHub Dorking Tool
git clone https://github.com/techgaun/github-dorks.git modules/github-dorking
cp modules/github-dorking/github-dork.py modules/github-dork.py

# Install Shodan CLI
pip3 install shodan
echo "[*] Enter your Shodan API key:"
read -r SHODAN_API_KEY
shodan init "$SHODAN_API_KEY"

# Install Corsy
git clone https://github.com/s0md3v/Corsy.git modules/corsy
pip3 install -r modules/corsy/requirements.txt

# Install Knockpy
git clone https://github.com/guelfoweb/knock.git modules/knockpy
pip3 install -r modules/knockpy/requirements.txt

# Install Subjack
go install github.com/haccer/subjack@latest

# Install Katana
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Install Waybackurls
go install github.com/tomnomnom/waybackurls@latest

# Install Aquatone (requires Chromium)
go install github.com/michenriksen/aquatone@latest

# Install Httprobe
go install github.com/tomnomnom/httprobe@latest

# Install dnsenum
sudo apt install -y dnsenum

# Install SQLMap
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git modules/sqlmap

# Install CMSeek
git clone https://github.com/Tuhinshubhra/CMSeeK.git modules/cmseek
pip3 install -r modules/cmseek/requirements.txt

# Install WhatWeb
sudo apt install -y whatweb

# Install Wafoof
pip3 install wafw00f

# Copy jsfinder template if not available
[ ! -f modules/jsfinder.py ] && echo -e "# placeholder jsfinder.py" > modules/jsfinder.py

# Create output dir
mkdir -p output

# Install Flask for GUI
pip3 install flask flask-cors

echo ""
echo "======================================"
echo "      All tools installed ✅           "
echo "      Run './reconrover.sh' now       "
echo "======================================"

