
*FreeBSD-8.0 Kurulumu:*

Yazılım Geliştirici kurulumu yapılır.
Port ağacı sisteme yüklenir.

Dosya Sistemi aşağıdaki gibi seçilir.

*35G /
*5G /swap

*Kurulumdan sonra yapılanlar:*

Öncelikle root şifresi değiştirilir ve /etc/rc.conf dosyası düzenlenir ve sistem yeniden başlatılır.

<pre>
passwd
ee /etc/rc.conf
</pre>

_rc.conf Dosyası:_

<pre>
keymap="us.iso"
hostname="kobisundev"
ifconfig_em0="dhcp"
sendmail_enable="NONE"
sshd_enable="YES"
</pre>

CVSUP ve Subversion paketleri kurularak hem sistemin kaynak kosları ve port dosyaları güncellenir hem de kobisun.org ile ilgili dosyalar SVN deposundan sisteme indirilir.

<pre>
pkg_add -r cvsup-without-gui
pkg_add -r subversion
rehash
svn co svn://kobisun.org/kobisun/kobisun-nano
cvsup -g -L 2 /root/kobisun-nano/kobisun-supfile
</pre>

İndirdiğimiz cvsup dosyası ile hem kaynak kodları hem de port ağacı güncellendi. Şimdi sıra FreeBSD sistemimizi güncel hale getirmeye geldi.

<pre>
cd /usr/src
make buildworld
make buildkernel KERNCONF=KOBISUN
make installkernel KERNCONF=KOBISUN
reboot
mergemaster
make installworld
reboot
mergemaster -p
</pre>

======================= tinderbox Sunucusunda Yapılanlar ===============================

<pre>
cd /usr/local/tinderbox/scripts/
./tc createPortsTree -p RF3D -u NONE -m /usr/ports/ -d "Render Farm"
./tc configDistfile -c /usr/ports/distfiles
./tc createBuild -b 8-NanoBSD-RF3D -j 8-NanoBSD -p RF3D -d "kobisun.org RenderFarm Packages"
cd ..
mkdir options/8-NanoBSD-RF3D
mkdir options/8-NanoBSD-RF3D/options
cd scripts/
./tc configOptions -e -o /options
cd /root/kobisun/nanobsd/
ee pkg.RF3D
./generate_packages.sh pkg.RF3D
./tc tinderbuild -b 8-NanoBSD-RF3D -nullfs
</pre>

http://nanotek.ath.cx/tb/ adresinden tinderbox tarafından hazırlanan paketler incelenebilir ve kurulum için gerekli paketler sistemimize indirilebilir.


======================= ATÖLYE BAŞLANGICI ==============================================



SVN sürüm bilgisini kullanarak sürüm numarası yaratan komut aşağıdadır.

<pre>
svn info |  grep Revision | awk -F':' '{ print $2 }'
</pre>



