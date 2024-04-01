# vm_restore

I build this script to quickly and easily restore backups of my KVM virtualized machines into my homelab structure.

## :hammer_and_wrench: How to install: :hammer_and_wrench:

The script works with absolute paths. The variable BAKPATH must be adjusted in the script to the absolute path where the backup files are located.

Example: /mnt/backup/

In addition, the backup files should be saved in subfolders that specify a date.

Example: /mnt/backup/2024-01-10/

The backup should consist of a .qcow2 image file and an .xml configuration file.

The virsh program is also required.

## Listing of an example backup:
```
$ tree /mnt/backup/2024-*

/mnt/backup/2024-01-10
├── debiantest-clone.qcow2
└── debiantest-clone.xml
/mnt/backup/2024-02-05
├── debiantest-clone.qcow2
└── debiantest-clone.xml
```

## The script execution looks like this:
```
###############################
### Virtual machine Restore ###
###############################

Which virtual machine would you like to restore?
0: archlinux		2: debiantest-clone	4: testServer
1: debiantest		3: fileserver		5: ubuntu

Select [0-5]: 2

Which date would you like to restore?
0: 2024-01-10
1: 2024-02-05

Select [0-1]: 1

The following commands are executed:

virsh destroy --domain debiantest-clone
virsh undefine --domain debiantest-clone
cp /mnt/backup/2024-02-05/debiantest-clone.qcow2 --target-directory=/var/lib/libvirt/images/
virsh define /mnt/backup/2024-02-05/debiantest-clone.xml

Would you like to continue? [Y/N]: Y
The virtual machine debiantest-clone was sucessfully restored.
```
The following steps are carried out:
1) Any running virtual machine is terminated "hard".
2) Any defined virtual machine becomes undefined.
3) The image from the backup is saved in the standard path "/var/lib/libvirt/images/" and any existing image will be overwritten.
4) The virtual machine from the backup is defined and can then be restarted.


## :construction: What doesn't work (yet)? :construction:
Currently the script works with clear names from the backup files. If the virtual machine is renamed, the backup will not work. I am currently working on adapting the script to UUID's.
