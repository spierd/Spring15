#!/bin/sh
#This script will show all installed packages and format them into a yum-ready paragraph.

yum list installed | tail -n +3 | cut -d" " -f1 | grep -v '^$' | tr '\n' ' '

exit 0
