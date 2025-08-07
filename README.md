# Forensic-Automation-Script
A Bash script that automates disk and memory forensic investigation on Linux. Supports Volatility 2.5, Binwalk, Foremost, Strings, Bulk Extractor, PCAP parsing, and organized reporting. Outputs are saved in a structured format and compressed into a ZIP archive. Created as part of the Cyber Defender course (May 2025), John Bryce, Israel.
# Linux Forensic Investigation Script

A Bash script that automates disk and memory forensic investigation on Linux systems.

## 🔍 Overview

This script streamlines the process of extracting forensic artifacts from Linux machines.  
It covers both **disk** and **memory** analysis using popular tools like:

- Volatility 2.5
- Binwalk
- Foremost
- Strings
- Bulk Extractor
- PCAP extraction and parsing

All results are saved in a structured directory and compressed into a final ZIP archive for easy reporting.

## 🛠️ Requirements

- Bash (Linux-based environment)
- Volatility 2.5 (Python 2)
- Binwalk
- Foremost
- Strings (from `binutils`)
- Bulk Extractor
- Wireshark (for `.pcap` files)

> ⚠️ Note: The script assumes that all tools are installed and available in `$PATH make sure download all files put them in the same directory and than run the script from the path.

## 🚀 Usage

1. Place your evidence files (e.g., `.raw`, `.mem`, `.pcap`) in the input folder.
2. Run the script:  
   bash ./FIA_PROJECT.sh
