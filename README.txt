Please check desctiption in mk-adobe-flash-player-packages.sh script.

Quick procedure:

% su
# export PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/`uname -p`/`uname -r`/All
# pkg_add -v unzip git-base mozilla-rootcerts
# /usr/pkg/sbin/mozilla-rootcerts install
 :
# exit
% git clone https://github.com/tsutsui/mk-adobe-flash-player-packages
 :
% cd mk-adobe-flash-player-packages
% sh mk-adobe-flash-player-packages.sh
 :
% su
# export PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/`uname -p`/`uname -r`/All
# pkg_add -v `uname -p`/adobe-flash-player
("pkg_add -v `uname -p`/adobe-flash-plugin" for 7.0 and 6.x)
 :
# exit
% 

Please also read adobe's readme.txt as prompted by the mk-adobe-flash-player-packages.sh script.
