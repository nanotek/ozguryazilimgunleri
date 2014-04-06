

Özgür Yazılım Günleri 2011, VoIP Ağı Kuralım Atölyesi için kobisun.org bulut sunucusu http://ec2.kobisun.org üzerinde yapılan kurulumun Debian 6/Squeeze için güncellenmiş notlarıdır.

Amazon EC2 Bulut EU bölgesi (İrlanda) üzerinde t1.micro instance başlatıldı ve Elastic IP Adresimiz ile entegre edildi.

FreeSwitch WiKi’ye göre (http://wiki.freeswitch.org/wiki/Linux_Quick_Install_Guide) FreeSwitch derlemek için gerekli yazılımlar:

    GIT
    WGET
    AUTOCONF
    AUTOMAKE
    GCC-C++
    LIBJPEG-DEVEL Used by mod_spandsp for basic codecs
    LIBTOOL
    MAKE
    NCURSES-DEVEL

WiKi’ye göre bazı FreeSwitch modüllerini derlemek için gerekli yazılımlar:

    curl-devel for mod_xml_curl
    expat-devel
    GnuTLS for Dingaling
    libtiff for fax support
    libx11-devel for mod_skypopen
    ODBC or UNIX-ODBC and ODBC-devel see the ODBC page for information
    OpenSSL for SIP SSL & TLS
    python-devel for the python interface
    ZLIB and ZLIB-devel
    libzrtp ZRTP encryption support, see the FreeSWITCH™ ZRTP page

FreeSwitch git deposundan kurulum genellikle problemsiz ve kurulum için tercih edilmesi tavsiye ediliyor, bu sebeple gerekli paketleri sistemimize yükledikten sonta git deposunu klonlayarak deb paketlerini üretebilir, ya da git sürümünü derleyerek kurulumu yapabiliriz. Ben derleme ve kurulum işlemleri için screen kullanıyorum, böylece sistem ile bağlantımın kesilmesi durumunda derleme işlemleri yarım kalmıyor. Sistem ile bağlantınız kesilirse ssh ile tekrar bağlanıp screen -r komutu ile tekrar sanal konsola bağlanabilirsiniz.

Standart olarak FreeSwitch /usr/local altına yerleşirken .deb paketleri Debian politikası uyarınca /opt altına kuruluyor. Bu sebeple kaynak dosyalarını da /opt/src altına indirmeyi uygun gördüm.

apt-get install git-core build-essential autoconf automake libtool libncurses5 libncurses5-dev libjpeg62-dev bison screen fail2ban
screen
cd /opt
mkdir src
cd src/
git clone git://git.freeswitch.org/freeswitch.git
cd freeswitch

Bu noktada dpkg-checkbuilddeps komutu ile sistemin gerekli paketlere sahip olup olmadığını kontrol edebiliriz. Bu sayede derlemek için gerekli paketlerin listesini elde edeceğiz. Eksik paketleri yükledikten sonra tekrar kontrol ederek sorun yoksa derlemeye başlayabiliriz.

dpkg-checkbuilddeps
# dpkg-checkbuilddeps: Unmet build dependencies: debhelper unixodbc-dev libasound2-dev libcurl3-openssl-dev | libcurl4-openssl-dev libssl-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev libgnutls-dev libtiff4-dev python-dev libx11-dev uuid-dev
apt-get install debhelper unixodbc-dev libasound2-dev libcurl4-openssl-dev libssl-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev libgnutls-dev libtiff4-dev python-dev libx11-dev uuid-dev
dpkg-checkbuilddeps
# Eğer problem yoksa derlemeye başlayabiliriz
dpkg-buildpackage -uc -us -b

Bu işlem t1.micro üzerinde yaklaşık 1 saat kadar sürüyor, isterseniz http://ec2.kobisun.org/dosyalar/ adresinden .deb dosyalarını indirebilirsiniz.

cd ..
ls *.deb
# .deb dosyaları oluştuysa kuruluma geçebiliriz
# komutlara * koydum ki git sürümü değişince de kopyala-yapıştır yapabilin
dpkg -i freeswitch_1.0.head-git.*.deb
dpkg -i freeswitch-lang-en_1.0.head-git.*.deb
dpkg -i freeswitch-lua_1.0.head-git.master.*.deb
# şimdilik bu modüller yeterli olmalı, sesleri de hazır edelim
cd /opt/src/freeswitch
make cd-sounds
make cd-moh
cd /opt/freeswitch/sounds
tar -zxvf /opt/src/freeswitch/freeswitch-sounds-en-us-callie-16000-1.0.16.tar.gz
tar -zxvf /opt/src/freeswitch/freeswitch-sounds-en-us-callie-8000-1.0.16.tar.gz
tar -zxvf /opt/src/freeswitch/freeswitch-sounds-music-16000-1.0.8.tar.gz
tar -zxvf /opt/src/freeswitch/freeswitch-sounds-music-8000-1.0.8.tar.gz
sed -i 's/FREESWITCH_ENABLED="false"/FREESWITCH_ENABLED="true"/g' /etc/default/freeswitch
service freeswitch start
# Bakalım kurulum çalışmış mı?
ps aux | grep freeswitch
102        649  0.5  4.1 277728 26112 ?        Sl   Aug08 208:16 /opt/freeswitch/bin/freeswitch -nc
root      9095  0.0  0.1   7544   840 pts/1    S+   16:44   0:00 grep freeswitch
# Şimdi FreeSwitch CLI'ye bağlanabiliriz
/opt/freeswitch/bin/fs_cli

FreeSwitch ile mod_skypopen kullanmak için küçük de olsa bir XServer kuramak gerekiyor, Skype kurulumunu da kolaylıka yapabilmek için x11vnc ile beraber kurmaya karar verdim. Skypopen oss modülü ile dummy bir ses kartı yaratılıyor, birden fazla skype kanalı kullanmak için ise XVfb çalıştırarak her skype için ayrı bir Xserver oturumu çalıştırılıyor.

Ben kendi kurulumumda kolaylık sağlamak için install.pl dosyasında gelen kurulum parametrelerini ihtiyacıma göre baştan düzenledim. Aşağıdaki diff çıktısı “git diff src/mod/endpoints/mod_skypopen/install/install.pl” komutu ile üretilmiştir. Mesela sed -i ‘s=/usr/local/freeswitch/=/opt/freeswitch/=g’ src/mod/endpoints/mod_skypopen/install/install.pl gibi big komut kullanarak tek seferde halledebilirsiniz. Bu sed komutunda önceki sed komutundan farklı olarak seperatör olarak “/” yerine “=” kullanılmıştır, böylece dizinde geçen “/” işaretlerini “///” gibi yazmaktan kurtulmuş olduk.

sed -i 's=/usr/local/freeswitch/=/opt/freeswitch/=g' src/mod/endpoints/mod_skypopen/install/install.pl
git diff src/mod/endpoints/mod_skypopen/install/install.pl

Sonra da böyle bir sonuç elde edersiniz:

diff --git a/src/mod/endpoints/mod_skypopen/install/install.pl b/src/mod/endpoints/mod_skypopen/install/install
index f4c04f3..9acfee0 100755
--- a/src/mod/endpoints/mod_skypopen/install/install.pl
+++ b/src/mod/endpoints/mod_skypopen/install/install.pl
@@ -6,11 +6,11 @@ my $skype_download_pkg = "skype-oss-2.0.0.72-2-i686.pkg.tar.gz";
 my $skype_binary_dir = "/usr/bin";
 my $skype_download_dir = "/tmp/skype_download";
 my $skype_share_dir = "/usr/share/skype";
-my $freeswitch_modules_config_dir = "/usr/local/freeswitch/conf/autoload_configs";
-my $skypopen_sound_driver_dir = "/usr/local/freeswitch/skypopen/skypopen-sound-driver-dir";
-my $skype_config_dir = "/usr/local/freeswitch/skypopen/skype-clients-configuration-dir";
-my $skype_startup_dir = "/usr/local/freeswitch/skypopen/skype-clients-startup-dir";
-my $skype_symlinks_dir = "/usr/local/freeswitch/skypopen/skype-clients-symlinks-dir";
+my $freeswitch_modules_config_dir = "/opt/freeswitch/conf/autoload_configs";
+my $skypopen_sound_driver_dir = "/opt/freeswitch/skypopen/skypopen-sound-driver-dir";
+my $skype_config_dir = "/opt/freeswitch/skypopen/skype-clients-configuration-dir";
+my $skype_startup_dir = "/opt/freeswitch/skypopen/skype-clients-startup-dir";
+my $skype_symlinks_dir = "/opt/freeswitch/skypopen/skype-clients-symlinks-dir";
 my $skype_clients_to_be_launched = "5";
 my $skype_clients_starting_number = "100";
 my $multi_skypeusername = "one";

Şimdi install.pl tarafından indirilerek kurulmuş olan Skype (static) çalıştırılarak FreeSwitch ile bağlanabilir.

apt-get install xfonts-100dpi xfonts-75dpi xfonts-encodings xfonts-scalable xfonts-utils x11vnc xvfb libxss1
cd /opt/src/freeswitch/mod/endpoints/mod_skypopen/oss
make
cd ../install
./install.pl
# Burada çıkan sorulara teker teker yanıt vermelisiniz
sh /opt/freeswitch/skypopen/skype-clients-startup-dir/start_skype_clients.sh
cd /opt/freeswitch
./bin/fs_cli
load mod_skypopen

Şimdi Skype ile bilgisayarınızdan kurduğunuz sisteme bağlanın, eğer herşey yolunda gittiyse Demo IVR sizi karşılayacaktır.

FreeSwitch 32-bit deb paketlerini http://ec2.kobisun.org/ adresinden indirebilirsiniz.

İkinci bölümde ESL ile Skype mesajlarını interaktif olarak IVR ile kullanmayı katmayı deneyeceğiz.

