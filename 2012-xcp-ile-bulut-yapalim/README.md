Özgür Yazılım Günleri 2012 – Debian SID ile Xen Cloud Platform Kurulumu
By kobisun | Published: 2012/03/30

Özgür Yazılım Günleri 2012 Notları

# /etc/apt/sources.list dosyasında sid depolarını aktive edelim
# ve sistemimizi sid sürümüne yükseltelim
 
perl -pi -e 's/squeeze/sid/g' /etc/apt/sources.list
apt-get update
apt-get dist-upgrade
reboot
 
# şimdi xcp-xapi kurulumunu yapalım xend'in otomatik başlamasını engelleyelim
# ve Xen Dom0 çekirdeğinin açılışta otomatik seçilmesini sağlayalım
 
apt-get install xcp-xapi
 
# vm komutlari icin bash-completion paketini yukleyip /etc/bash.bashrc icinde etkinlestirelim
apt-get install bash-completion
 
# xend çalışırsa xapi çalışmıyor, ama init.d/xend bazı gerekli ayarları yapıyor
 
sed -i -e 's/xend_start$/#xend_start/' -e 's/xend_stop$/#xend_stop/' /etc/init.d/xend
update-rc.d xendomains disable
 
# grub'ı ayarlıyoruz ki otomatik Xen başlayabilsin
 
sed -i 's/GRUB_DEFAULT=.\+/GRUB_DEFAULT="Xen 4.1-amd64"/' /etc/default/grub
update-grub
 
# TOOLSTACK değişkeni seçilmiş olmalı ki xapi başlayabilsin
 
sed -i -e 's/TOOLSTACK=$/TOOLSTACK=xapi/' /etc/default/xen
 
# eth0 için DHCP kapatılmalı xenbr0 içinse dhcp açılmalı yoksa problem oluyor
# muhtemelen udev'in hotplug eventlerini etkisiz kilmak gerekli olacaktir
 
# /etc/network/interfaces dosyasini bu sekilde degistirelim
 
auto lo xenbr0
iface lo inet loopback
 
iface eth0 inet manual
 
iface xenbr0 inet dhcp
        bridge_ports eth0
 
reboot
 
# öncelikle Dom0 aktif mi bakalım
 
xe vm-list
 
# şimdi bir storage repository açalım /dev/sda3 bizim için hazır
 
SR=`xe sr-create type=ext device-config:device=/dev/sda3 name-label=ext`
POOL=`xe pool-list --minimal`
xe pool-param-set uuid=$POOL default-SR=$SR
 
# vncterm çalıştırabilmek için qemu keymapleri bulabilmesi lazım
mkdir /usr/share/qemu
ln -s /usr/share/qemu-linaro/keymaps /usr/share/qemu/keymaps
 
# simdi ilk VMmimizi kurma zamani
 
template=`xe template-list name-label="Debian Squeeze 6.0 (32-bit)" --minimal`
vm=`xe vm-install template=$template new-name-label=squeeze32`
network=`xe network-list bridge=xenbr0 --minimal`
vif=`xe vif-create vm-uuid=$vm network-uuid=$network device=0 mac=random`
 
xe vm-param-set uuid=$vm other-config:install-repository=http://ftp.tr.debian.org/debian
xe vm-param-set uuid=$vm PV-args="auto-install/enable=true interface=auto netcfg/dhcp_timeout=600 hostname=squeeze32 domain=sq32.xcp.local"
 
xe vm-start uuid=$vm

Bu script XCP Live CD için de kullanılabilir, belki shelli başka bir shell ile değiştirmek gerekebilir.

#!/bın/bash
 
set -e
set -x
 
vmname=openstack
 
template=`xe template-list name-label="Debian Squeeze 6.0 (32-bit)" --minimal`
vm=`xe vm-install template=$template new-name-label=$vmname`
 
network=`xe network-list bridge=xenbr0 --minimal`
vif=`xe vif-create vm-uuid=$vm network-uuid=$network mac=random device=0`
 
xe vm-param-set uuid=$vm other-config:install-repository=http://ftp.tr.debian.org/debian
xe vm-param-set uuid=$vm PV-args="auto-install/enable=true interface=auto netcfg/dhcp_timeout=600 hostname=squeeze32 domain=xcp.local"
 
xe vm-start uuid=$vm

Kalanı atölyede beraber yapabileceklerimize kalıyor.

Referanslar:

    http://docs.vmd.citrix.com/XenServer/6.0.0/1.0/en_gb/
    http://wiki.xen.org/wiki/Project_Kronos
    http://wiki.xen.org/wiki/XCP_Command_Line_Interface

