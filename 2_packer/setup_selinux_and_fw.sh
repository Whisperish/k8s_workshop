# Apply our host file

sudo cp hosts /etc/hosts

sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --permanent --add-port=8285/udp
#firewall-cmd --permanent --add-port=8472/udp

#systemctl restart firewalld

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo 'br_netfilter' > /etc/modules-load.d/br_netfilter.conf

#reboot
