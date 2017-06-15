#!/bin/bash

#Created on Mar 28 
#@author wangyunhua@smeyun.com
#Version 0.1 



lock_file() {
    list=("/etc/passwd" "/etc/group" "/root/.ssh/authorized_keys" "/home/webapp/.ssh/authorized_keys" "/etc/sudoers" "/var/log/messages" "/etc/shadow" "/etc/gshadow")
	
	for files in ${list[*]}
	do
	if [ -f "$files" ]; then
	/usr/bin/chattr +i $files
	echo "lock $files"
	fi
	done	

}

lock_soft(){
	echo "lock softwore"
	list=("finger" "ping" "w" "whereis" "pico" "ifconfig" "gcc" "who" "locate" "vi" "which" "make" "rpm" "crontab" "wget" "python" "curl" "nc" "perl")

	for prcc in ${list[*]}
	do
	path=`which $prcc`
	if [ $path ];then
	/bin/chmod 700 $path
	fi
	done

	/bin/chmod 700 /etc/rc.d/init.d/*
}

clean_sysinfo(){
	echo "clean system info"
	rm -f /etc/issue /etc/issue.net;touch /etc/issue /etc/issue.net
}


open_file() {
    list=("/etc/passwd" "/etc/group" "/root/.ssh/authorized_keys" "/home/webapp/.ssh/authorized_keys" "/etc/sudoers" "/var/log/messages" "/etc/shadow" "/etc/gshadow")
	
	for files in ${list[*]}
	do
	if [ -f "$files" ]; then
	/usr/bin/chattr -i $files
	echo "unlock $files"
	fi
	done
	chmod a+x /usr/bin/python
}

open_prc() {
	chmod a+x /usr/bin/python
}



limit_su(){
	if [ -z "`grep "fyhz_user" /etc/passwd`" ];then
	echo "check user alived" 
	elif [ -z "`grep "auth required pam_wheel.so group=" /etc/pam.d/su`" ];then
		sed -i '$a\auth required pam_wheel.so group=fyhz_user' /etc/pam.d/su
		echo "inset fyhz_user to su"
	fi
}


case "$1" in
    lock)
        lock_file
        lock_soft
        clean_sysinfo
	;;
    open)
    open_prc
	;;
    file)
    open_file
	;;
    limit)
    limit_su
	;;	

    *)
        echo "$0 [lock|open|limit|file]"
        exit 1
esac

exit 0
