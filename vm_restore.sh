#!/bin/bash

#########################################
# Name:   virtual_machine_restore       #
# Author: https://github.com/w-manuel   #
#########################################

# variables defined for color text output
printf_green=`tput setaf 2`
printf_red=`tput setaf 1`
printf_reset=`tput sgr0`

# build main function
fn_main() {

# define absolute paths
BAKPATH='/mnt/backup/'
CONFPATH='/etc/libvirt/qemu/'
VMIMGPATH='/var/lib/libvirt/images/'

typeset -a vmpool bakfilelist bakconflist

printf ${printf_green}"\n###############################"${printf_reset}
printf ${printf_green}"\n### Virtual machine Restore ###"${printf_reset}
printf ${printf_green}"\n###############################\n\n"${printf_reset}

# read in existing backup .qcow2 files from backup path
vmpool=($(find $BAKPATH -type f -name '*.qcow2' | cut -d'/' -f5 | sed -e 's/.qcow2//g' | sort | uniq))

# Check whether backups are available, otherwise abort the program
if (( ${#vmpool[@]} >= 1 ))
then
    echo -e "Which virtual machine would you like to restore?"

    # print formatted list in terminal
    for ((loopcount=0; loopcount<$(echo ${#vmpool[@]}); loopcount++))
    do
        echo -e "$loopcount: ${vmpool[loopcount]}"
    done | column

    # calculate possible backup numbers and ask the user which backup should be restored
    echo; read -p "Select [0-$((${#vmpool[@]} - 1))]: " vmtobackup
else
    echo "No virtual machine exists!"
    exit 0
fi

# import the appropriate .qcow2 and .xml file from the backup for the selected virtual machine
bakfilelist=($(find $BAKPATH -type f -name "${vmpool[vmtobackup]}.qcow2" | sort))
bakconflist=($(find $BAKPATH -type f -name "${vmpool[vmtobackup]}.xml"))

# Check whether .qcow2 and .xml files are available, otherwise abort the program
if (( ${#bakfilelist[@]} >= 1 )) && (( ${#bakconflist[@]} >= 1 ))
then
    echo -e "\nWhich date would you like to restore?"

    # output existing times to existing backups
    for ((loopcount=0; loopcount<$(echo ${#bakfilelist[@]}); loopcount++))
    do
        echo -e "$loopcount: $(echo ${bakfilelist[loopcount]} | sed -e "s|"$BAKPATH"||g" | sed -e 's/\/.*//g')"
    done

    echo; read -p "Select [0-$((${#bakfilelist[@]} - 1))]: " datetobackup

    # control output what is executed and request confirmation
    echo; echo -e "The following commands are executed:\n"

    echo "virsh destroy --domain ${vmpool[vmtobackup]}"
    echo "virsh undefine --domain ${vmpool[vmtobackup]}"
    echo "cp ${bakfilelist[$datetobackup]} --target-directory=$VMIMGPATH"
    echo "virsh define ${bakconflist[$datetobackup]}"

    echo; read -p "Would you like to continue? [Y/N]: " proceed
    if [[ $proceed == "Y" ]] || [[ $proceed == "y" ]]
    then
        # stop old vm and delete it, then restore the selected backup and define it
        virsh destroy --domain ${vmpool[vmtobackup]} &>/dev/null 
        virsh undefine --domain ${vmpool[vmtobackup]} &>/dev/null
        cp ${bakfilelist[$datetobackup]} --target-directory=$VMIMGPATH
        virsh define ${bakconflist[$datetobackup]} &>/dev/null

        printf ${printf_green}"The virtual machine${printf_reset} ${vmpool[vmtobackup]} ${printf_green}was sucessfully restored.\n"${printf_reset}
        exit 0
    else
        printf ${printf_red}"No valid entry, abort...\n"${printf_reset}
        exit 0
    fi
else
    printf ${printf_red}"No backup exists for this virtual machine...\n"${printf_reset}
    exit 0
fi
}

# check whether the program has been started with the required authorizations and start the main function
if [ $(id -u $USER) -eq 0 ]
then
    fn_main
else
    echo "Please start Program with sudo or as root user!"
fi

