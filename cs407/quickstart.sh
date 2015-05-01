!#/bin/sh
##Temporarily reuploaded, though some errors need to be addressed. 

#This script will bring new VMs up to speed. 
#Script is still in development.
#v0.2

#ensures 2 flags are present
if [ "$#" -ne 2 ]
then
    echo "Two flags required."
    echo "Usage:"
    echo " -i <last octet of ip> -n <hostname>"
    echo " example: -i 140 -n auth"
    echo " Note: arguments are not checked for validity"
    exit 1
fi

ip=""
name=""

while getopts "in" opt; do
        case "$opt" in
        i)
                ip="$OPTARG"
                ;;
        n)
                name="$OPTARG"
                ;;

        *)
                echo "Two flags required."
                echo "Usage:"
                echo " -i <last octet of ip> -n <hostname>"
                echo " example: -i 140 -n auth"
                echo " Note: arguments are not checked for validity"
                exit 2
                ;;
        esac
done

echo "adding spierd user"
useradd spierd

echo "adding spierd SSH keys"
mkdir ~spierd/.ssh
touch ~spierd/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAycVbVPvISLjzCrE7YFytCKEmrNhRuS6hcio65ijwl1lUetudL9rsUDfqeR3Q0TI8nyQzQzACpuRoNDYw2h531Xrl2O5AU2UuHfz8BU29j6RiJ/UOUGEwjtm+LFot9vNYJzdFabVfJffHIqI1tq0etYY1wz1mRqtr+BckiSwofoOBjl0nown2KZEFaUCaA8KRbmPHfN5uDwderzPM6VK8bWRZH8EX3C8eXXKby8hLikAKhKmBABL+FORaP+a2xCHWlzjcYwrRwLLoqlySDp1QP+VjnSqLXvPXAot6oBOunvfuUUPMSeoeus5uhMJcsmKDiYpJYUlJsTVfvc/j3x spierd@fang.cs.sunyit.edu">~spierd/.ssh/authorized_keys
echo "adding root SSH keys"
mkdir ~root/.ssh
touch ~root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAycVbVPvISLjzCrE7YFytCKEmrNhRuS6hcio65ijwl1lUetudL9rsUDfqeR3Q0TI8nyQzQzACpuRoNDYw2h531Xrl2O5AU2UuHfz8BU29j6RiJ/UOUGEwjtm+LFot9vNYJzdFabVfJffHIqI1tq0etYY1wz1mRqtr+BckiSwofoOBjl0nown2KZEFaUCaA8KRbmPHfN5uDwderzPM6VK8bWRZH8EX3C8eXXKby8hLikAKhKmBABL+FORaP+a2xCHWlzjcYwrRwLLoqlySDp1QP+VjnSqLXvPXAot6oBOunvfuUUPMSeoeus5uhMJcsmKDiYpJYUlJsTVfvc/j3x spierd@fang.cs.sunyit.edu">~root/.ssh/authorized_keys

echo "adding toor user"
useradd -g 0

cp /etc/shadow ~/shadow.bak
sed -i 's/\(^toor:\)!!\(:.*\)/\1$6$8Yon5kVb$oatkGA1vlwNrGpUI6IfnHWFnxhB1QAQV.Yy4ZSLolxZ35Kk2FY\/Fmu8auTSVb5mKxQnG4uUT4DazeFkJjGPjK\/\2/' /etc/shadow 

echo "adding admin user"
useradd admin -u 1000 -g 100

chmod 600 ~/.ssh/authorized_keys
chmod 600 ~spierd/.ssh/authorized_keys

echo "modifying eth0 config"
sed -i 's/ONBOOT=NO/ONBOOT=YES/' /etc/sysconfig/network-scripts/ifcfg-eth0 
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/' /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "IPADDR=10.103.36.$ip" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=255.255.0.0" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETWORKING=yes
HOSTNAME=$name
GATEWAY=10.103.0.1" >> /etc/sysconfig/network

echo "adding dns server"

echo "search cs.sunyit.edu
nameserver 10.102.0.32" > /etc/resolv.conf

echo "restarting networking"

service network restart
ifdown eth0 && ifup eth0

echo "adding local repo"
echo "[DogNET]
name=CS407 CentOS 6 Repo
baseurl=ftp://repo.cs407.net/CentOS/6/
gpgcheck=1
gpgkey=ftp://repo.cs407.net/CentOS/6/os/x86_64/RPM-GPG-KEY-CentOS-6
enabled=1" > /etc/yum.repos.d/cs407.repo

echo "installing packages and rebooting"
yum -y install epel-release && yum -y install vim nmap && yum -y install man wget nc telnet bind-utils openssh-clients rsync gcc make perl && yum -y update && shutdown -r now

echo "done"

exit 0
