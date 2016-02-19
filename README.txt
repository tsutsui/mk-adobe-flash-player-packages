Please check desctiption in mk-adobe-flash-plugin-packages.sh script.

Quick procedure:

% su
# export PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/`uname -p`/`uname -r`/All
# pkg_add -v rpm2pkg git-base mozilla-rootcerts
 :
# exit
% git clone https://github.com/tsutsui/mk-adobe-flash-plugin-packages
 :
% cd mk-adobe-flash-plugin-packages
% sh mk-adobe-flash-plugin-packages.sh
 :
% su
# export PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/`uname -p`/`uname -r`/All
pkg_add -v `uname -p`/adobe-flash-plugin
 :
# exit
% 

Please also read adobe's readme.txt as prompted by the mk-adobe-flash-plugin-packages.sh script.
