#!/bin/bash

HOME=$(pwd)
TOOL=$HOME/ProjectOutput

function CHECK_APPS()
{
	#bulk extractor check
	echo "Checking if Bulk_Extractor exist on the system.."
	which bulk_extractor  > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		echo "Bulk is already installed. skipping.."
	else
		echo "Bulk does not exist. Installing..."
		apt-get update 
		apt-get install -y bulk-extractor 
	fi
	
	#binwalk check
	echo "Checking if binwalk. exist on your system."
	which binwalk  > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		echo "binwalk is already installed. skipping"
	else
		echo "bin walk does not exist. Installing..."
		apt-get update  > /dev/null 2>&1
		apt-get install -y binwalk  > /dev/null 2>&1
	fi
	#foremost check
	echo "Checking if foremost exist on your system."
	which foremost  > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		echo "foremost is already installed. skipping"
	else
		echo "foremost does not exist. Installing..."
		sudo apt-get update  > /dev/null 2>&1
		sudo apt-get install -y foremost  > /dev/null 2>&1
	fi
	# strings check
	echo "Checking if strings exists on your system..."
	which strings  > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		echo "strings is already installed. Skipping..."
	else
		echo "strings not found. Installing..."
		apt-get install -y binutils  > /dev/null 2>&1
	fi
	
	# Volatility 2.5 check
	echo "Checking if volatility_2.5_linux_x64 exists in the current folder..."
	if [ -f "$HOME/volatility_2.5_linux_x64" ]; then
	chmod +x "$HOME/volatility_2.5_linux_x64"
	echo "vol 2.5 adjusted to your machine"
	echo "Volatility version:"
	./vol 2>&1 | head -n 1
	else
	echo "[-] volatility_2.5_linux_x64 not found in: $HOME"
	fi
	
	#zip install check
	echo "Checking if ZIP is installed to your machine"
	if ! command -v zip &> /dev/null
	then
		echo "zip not found. Installing zip..."
		apt-get install -y zip > /dev/null 2>&1
	else
		echo "zip is already installed. skipping..."
	fi

	MENU
}

function MENU() 
{
	echo -e "What would you like to do with the file? [CHOOSE A NUMBER]\n [+] 1 - BINWALK [+] 2 - STRINGS [+] 3 - FOREMOST \n [+] 4 - BULK_EXTRACTOR [+] 5 - Extract Network traffic file \n [+] 6 - Human readable files (exe files, usernames etc) [+] 7 - Voladillity extract \n [+] 0 - Quit and Save Results"
	read OPTIONS
	
	case $OPTIONS in
	
	1)
		BINWALK
	;;
	
	2)
		STRINGS
	;;
	
	3)
		FOREMOST
	;;
	
	4)
		BULK_EXTRACTOR
	;;
	
	5)
		NETWORK
	;;
	
	6)
		HUMAN
	;;
	
	7) 
		Volatility
	;;
	
	0) 
		Results 	
	;;
	
	*)
	echo "Invalid option. Try again."
		MENU
	;;
	
	esac
}

function BINWALK() #binwalk command
{
	echo "Running Binwalk on $path"
	BINWALK_DIR=$TOOL/binwalk_results
	mkdir -p "$BINWALK_DIR"

	binwalk -e "$path" --directory "$BINWALK_DIR" --run-as=root

	echo "[+] Binwalk extraction completed. Files saved to: $BINWALK_DIR"
	
	MENU
	
}

function FOREMOST() #foremost command
{
	echo "Running Foremost on $path"
	Foremost_DIR="$TOOL/foremost_results"
	mkdir -p "$Foremost_DIR" 2>&1 > /dev/null
	foremost -i "$path" -o "$Foremost_DIR" 2>&1 > /dev/null
	echo "[+] Foremost extraction completed. Files saved to: $Foremost_DIR"
	
	MENU
}

function BULK_EXTRACTOR() #bulk_extractor command
{
	echo "Running Bulk_Extractor on $path"
	BULK_DIR="$TOOL/bulk_results"
	mkdir -p "$BULK_DIR" 2>&1 > /dev/null
	bulk_extractor "$path" -o "$BULK_DIR" -f all  2>&1 > /dev/null
	echo "[+] Bulk Extractor completed. Files saved to: $BULK_DIR"
	
	MENU
}

function STRINGS() #strings command
{
	echo "Running strings on $path"
	STRINGS_DIR="$TOOL/strings_results"
	mkdir -p "$STRINGS_DIR" 2>&1 > /dev/null
	strings "$path" > "$STRINGS_DIR/strings_output.txt" 2>&1
	echo "[+] strings completed. Output saved to: $STRINGS_DIR/strings_output.txt"
	
	MENU
}

#checking for netwrok files
function NETWORK()
{
	echo "[+] Attempting to extract PCAP file from $path..."
	PCAP_DIR="$TOOL/bulk_dir"
	rm -rf "$PCAP_DIR" 2>/dev/null
	bulk_extractor -x all -e net -e httplogs -e gzip -e zip -x winpe -x elf -o "$PCAP_DIR" "$path" > /dev/null 2>&1
	
	if [ -f "$PCAP_DIR/packets.pcap" ] 
	then
		mkdir -p "$TOOL/PCAP"
		cp "$PCAP_DIR/packets.pcap" "$TOOL/PCAP"
		
		SIZE=$(ls -lh "$TOOL/PCAP/packets.pcap" | awk '{print $5}')
		echo "[+] Found Network File -> Saved into $TOOL/PCAP [Size: $SIZE]"
		rm -rf "$PCAP_DIR"
	else
		echo "[-] No PCAP file was found in the memory image."
	fi
	
	MENU
}

#checking for human readable files
function HUMAN()
{
    echo "Running strings on $path"
    HUMAN_DIR="$TOOL/HUMAN_results"
    mkdir -p "$HUMAN_DIR" > /dev/null 2>&1

    # 1. Emails helped by chatgpt
    strings "$path" | grep -Eoi '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' > "$HUMAN_DIR/STRINGS_emails.txt"

    # 2. .exe file names  helpedby chatgpt
    strings "$path" | grep -Eoi '\b[a-zA-Z0-9_/\\.-]+\.exe\b' > "$HUMAN_DIR/STRINGS_exe.txt"

    # 3. Passwords  helped by chatgpt
    strings "$path" | grep -Eoi 'pass(word)?[^[:space:]=:]{0,1}[:=][^[:space:]]{1,30}|pwd[^[:space:]=:]{0,1}[:=][^[:space:]]{1,30}' > "$HUMAN_DIR/STRINGS_passwords.txt"
	strings "$path" | grep -Eoi '\b[a-zA-Z0-9@#%^*!_+=-]{4,30}\b' | grep -i 'pass' > "$HUMAN_DIR/STRINGS_passwords2.txt"
    
    # 4. Usernames - helpedby chatgpt
    strings "$path" | grep -Eoi 'user(name)?[^[:space:]=:]{0,1}[:=][^[:space:]]{1,30}' > "$HUMAN_DIR/STRINGS_usernames.txt"

    echo "[+] Search completed. Results saved in: $HUMAN_DIR"
	
	MENU
}

function Volatility() #Volatility command
{
    echo "Analyzing $path"
    PROFILE=$(./vol -f "$path" imageinfo | grep Suggested | awk -F',' '{print $1}' | awk -F':' '{print $2}' | sed 's/ //g')

    if [ -z "$PROFILE" ]; then
        echo "[!] imageinfo couldn't find a suggested profile - file can't be analyzed by Volatility"
        return
    fi

    echo "Image_info/os: $PROFILE"
    PLUGINS="imageinfo netscan connscan pslist hivelist printkey"
    mkdir -p "$TOOL/Volatility"

    for plugin in $PLUGINS
    do
        echo "Using $plugin against the file"
        ./vol -f "$path" --profile=$PROFILE $plugin > "$TOOL/Volatility/results_$plugin.txt" 2>/dev/null
    done

    echo "[+] Done executing plugin commands. Files were saved to: $TOOL/Volatility"
	
	MENU
}

function Results() #save result statistics and zip it with the output of therest commands executed
{
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo "[+] Collecting statistics..."

    NUM_FILES=$(find "$TOOL" -type f | wc -l)
    NUM_DIRS=$(find "$TOOL" -type d | wc -l)

    REPORT="$HOME/results.txt"
    {
        echo "=== Analysis Report ==="
        echo "Start Time: $(date -d @$START_TIME)"
        echo "End Time: $(date -d @$END_TIME)"
        echo "Duration: $DURATION seconds"
        echo "Files Extracted: $NUM_FILES"
        echo "Directories Created: $NUM_DIRS"
        echo "Results Directory: $TOOL"
    } > "$REPORT"

    echo "[+] Report saved to $REPORT"

    ZIP_FILE="$HOME/results.zip"
    zip -r "$ZIP_FILE" "$TOOL" "$REPORT" > /dev/null 2>&1

    echo "[+] All results compressed into $ZIP_FILE"
    echo "Thanks for using the Forensics Tool. Goodbye!"
    exit
 
}

#this function checks whether the given file exist on the system.
function FILE_CHECK()
{
	echo "Please insert a full path to the image file:"
	read path
	if [ -s "$path" ]
	then
		echo "File exist"
		CHECK_APPS
	else
		echo "File does not exist. Please try again."
		FILE_CHECK
	fi	
}

# This function starts the script. checks if the user is root or not, create a main directory.
function START ()
{
	START_TIME=$(date +%s)
	USER=$(whoami)
	if [ "$USER" != "root" ]
	then
		echo "You are not root. Exiting.."
		exit
	else
		figlet "Forensics Investigation -by Dor Amihai - S23 -lecturer's name Erel"
		mkdir -p ProjectOutput > /dev/null 2>&1 # --> main directory will be ProjectOutput...
		FILE_CHECK
	fi
}

START

