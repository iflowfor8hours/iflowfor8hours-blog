---
title: List all installed packages on debian
layout: post
---
I found this on the debain forums, and thought it might be useful to repost here. With these commands, you can list all the packages that are installed on one debian/ubuntu box, and install them elsewhere really easily. This is useful when migrating services from one box to another, the lazy way. 

To get a list, and dump it into a file:

    dpkg --get-selections > installed-software

scp that file to your target machine:

    scp installed-software root@host-I-want-to-move-to:/root/installed-software

on the target host run:

    dpkg --set-selections < installed-software
    sudo apt-get install dselect
    sudo dselect

In the dselect menu, just hit install and go get some lunch. It may take a while to download and install everything. 
