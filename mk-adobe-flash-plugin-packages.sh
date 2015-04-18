#! /bin/sh
#
# Copyright (c) 2015 Izumi Tsutsui.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#
# mk-adobe-flash-plugin-packages.sh
#
# What's this?
#  A dumb script to create adobe-flash-plugin11 binary packages
#  (not redistributable so adobe binaries should be downloaded by users)
#  for pkgsrc on NetBSD/i386 6.1.5 and NetBSD/amd64 6.1.5
#
# Quick procedure:
#  See README.txt in https://github.com/tsutsui/mk-adobe-flash-plugin-packages
#
# Preparation:
#  - Install "rpm2pkg" command in pkgsrc/pkgtools/rpm package
#    by "pkg_add rpm2pkg" etc.
#  - Also install "nspluginwrapper" package in pkgsrc/www/nspluginwrapper
#    (necessary to determine which Linux binary 64 bit or 32 bit on x86_64
#     is required)
#
# Build:
#  - Just type "sh mk-adobe-flash-plugin-packages.sh"
#    then ${MACHINE_ARCH}/adobe-flash-plugin-${FLASH_VERSION}.tgz
#    will be created.
#
# Caveats:
#  - Dumb idea, poor design and lack of documentation.
#  - There are few error checks.
#  - Needs more sane shell script implementation (functions etc).
#

FLASH_VERSION=11.2.202.457

# check platform and setup platform specific values
MACHINE_ARCH=`uname -p`
if [ ${MACHINE_ARCH} = "i386" ]; then
	FLASH_ARCH=i386
	FLASH_LIBDIR=lib
	PKGFILESDIR=pkgfiles
elif [ ${MACHINE_ARCH} = "x86_64" ]; then
# check nspluginwrapper package is already installed
NSPLUGINWRAPPERDIR=/usr/pkg/lib/nspluginwrapper
if [ ! -f ${NSPLUGINWRAPPERDIR}/noarch/npviewer.sh ]; then
fi
if [ -x ${NSPLUGINWRAPPERDIR}/x86_64/linux/npviewer.bin ]; then
	FLASH_ARCH=x86_64
	FLASH_LIBDIR=lib64
	PKGFILESDIR=pkgfiles64
elif [ -x ${NSPLUGINWRAPPERDIR}/i386/linux/npviewer.bin ]; then
	FLASH_ARCH=i386
	FLASH_LIBDIR=lib
	PKGFILESDIR=pkgfiles
else
	echo "nspluginwrapper is not installed. Try \"pkg_add nspluginwrapper\" first."
	exit 1
fi
else
	echo "Error: non-x86 platform?"
	exit 1
fi

# check rpm2pkg command in rpm2pkg package to extract files from .rpm
RPM2PKG=/usr/pkg/sbin/rpm2pkg
if [ ! -x ${RPM2PKG} ]; then
	echo "${RPM2PKG} is not found. Try \"pkg_add rpm2pkg\" etc."
	exit 1
fi

PKGNAME=adobe-flash-plugin-${FLASH_VERSION}
DISTNAME=flash-plugin-${FLASH_VERSION}-release.${FLASH_ARCH}
EXTRACT_SUFX=.rpm
MASTER_SITES=http://fpdownload.macromedia.com/get/flashplayer/pdc/${FLASH_VERSION}/
DISTRPM=${DISTNAME}${EXTRACT_SUFX}

LIBFLASH=libflashplayer.so
LIBFLASHPATH=./usr/${FLASH_LIBDIR}/flash-plugin
PKGLIBFLASHPATH=lib/netscape/plugins

PKGFILES="+CONTENTS +COMMENT +DESC +INSTALL +DEINSTALL +BUILD_VERSION +BUILD_INFO +SIZE_PKG +SIZE_ALL"

DOWNLOADDIR=${MACHINE_ARCH}/download
WORKDIR=${MACHINE_ARCH}/work
PACKAGESDIR=${MACHINE_ARCH}

rm -rf ${DOWNLOADDIR}
rm -rf ${WORKDIR}

echo "Downloading a libflashplayer archive from adobe site..."
mkdir -p ${DOWNLOADDIR}
ftp -o ${DOWNLOADDIR}/${DISTRPM} ${MASTER_SITES}${DISTRPM}

echo "Extracting libflashplayer files from rpm file..."
${RPM2PKG} -d ${DOWNLOADDIR} ${DISTRPM}

echo "Creating a packages tgz file using downloaded libflashplayer file..."
# copy template files into work dir
mkdir -p ${WORKDIR}
(cd ${MACHINE_ARCH}/${PKGFILESDIR} && pax -rw . ../../${WORKDIR})

# copy necessary shlib into work dir
cp ${DOWNLOADDIR}/${LIBFLASHPATH}/${LIBFLASH} ${WORKDIR}/${PKGLIBFLASHPATH}

# create .tgz package file
GZIP=-9 tar -zcf ${PACKAGESDIR}/${PKGNAME}.tgz -C ${WORKDIR} \
	${PKGFILES} ${PKGLIBFLASHPATH}/${LIBFLASH}

# complete.
echo "Done."
echo "------------------------------------------------------------------------"
echo "${PACKAGESDIR}/${PKGNAME}.tgz has been created."

# to avoid possible bikeshed about legal issue...
echo "------------------------------------------------------------------------"
echo "Please read readme.txt file in"
echo "${DOWNLOADDIR}/usr/share/doc/flash-plugin-${FLASH_VERSION} dir."
echo "------------------------------------------------------------------------"
