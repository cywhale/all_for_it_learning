# Solve fdisk /dev/sda error: "All space for primary partitions is in use. Adding logical partition 6 No free sectors available."
# ref: https://www.rootusers.com/how-to-increase-the-size-of-a-linux-lvm-by-expanding-the-virtual-machine-disk/
fdisk -l ## to check current partition and make cure new partition number, see ref URL (may need sudo) 
# fdisk /dev/sda ## enter prompt
# n ## add new partition
###### then follow ref URL steps, works for Centos 6.5. BUT encounter problems in Ubuntu 16.04
###### Error: "All space for primary partitions is in use. Adding logical partition 6 No free sectors available."
###### Find another ref to solve: http://bit.ly/31SqOaY

sudo parted /dev/sda
#(parted) print
#(parted) resizepart 2
#End?  [53.7GB]? -0  
#(parted) print
#(parted) q

sudo fdisk /dev/sda
# p

## Device     Boot  Start       End   Sectors   Size Id Type
## /dev/sda1  *      2048    499711    497664   243M 83 Linux
## /dev/sda2       501758 314572799 314071042 149.8G  5 Extended
## /dev/sda5       501760 104855551 104353792  49.8G 8e Linux LVM

# Command (m for help): n

## All space for primary partitions is in use.
## Adding logical partition 6
## First sector (104857600-314572799, default 104857600): 
## Last sector, +sectors or +size{K,M,G,T,P} (104857600-314572799, default 314572799): 

## Created a new partition 6 of type 'Linux' and of size 100 GiB.

# p

## Device     Boot     Start       End   Sectors   Size Id Type
## /dev/sda1  *         2048    499711    497664   243M 83 Linux
## /dev/sda2          501758 314572799 314071042 149.8G  5 Extended
## /dev/sda5          501760 104855551 104353792  49.8G 8e Linux LVM
## 8/dev/sda6       104857600 314572799 209715200   100G 83 Linux

# Command (m for help): t
# Partition number (1,2,5,6, default 6): 6
# Partition type (type L to list all types): 8e

## Changed type of partition 'Linux' to 'Linux LVM'.

# wq

sudo vgdisplay

##  --- Volume group ---
##  VG Name               ubuntu-vg

reboot
## ------------------- after reboot
sudo vgextend ubuntu-vg /dev/sda6

sudo lvdisplay
##  --- Logical volume ---
##  LV Path                /dev/ubuntu-vg/root

sudo lvresize -l  100%FREE /dev/ubuntu-vg/root

df -h
## /dev/mapper/ubuntu--vg-root   48G   37G  9.3G  80% /

sudo resize2fs -p /dev/mapper/ubuntu--vg-root
df -h
## /dev/mapper/ubuntu--vg-root   99G   37G   58G  39% / #### !! Success extend LVM !!

