#! /bin/sh
#
# Copyright (c) 2015, 2017 Izumi Tsutsui.
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
#  for pkgsrc on NetBSD/i386 7.*/6.1.5 and NetBSD/amd64 7.*/6.1.5
#
# Quick procedure:
#  See README.txt in https://github.com/tsutsui/mk-adobe-flash-plugin-packages
#
# Preparation:
#  - Install "nspluginwrapper" package in pkgsrc/www/nspluginwrapper
#    (necessary to determine which Linux binary 64 bit or 32 bit on x86_64
#     is required)
#  - For adobe-flash-plugin11 packages (for 6.1.5 and 7.0),
#    install "unzip" command in pkgsrc/archivers/unzip package
#    by "pkg_add unzip" etc.
#
# Build:
#  - Just type "sh mk-adobe-flash-plugin-packages.sh"
#    then ${MACHINE_ARCH}/adobe-flash-player-${FLASH_VERSION}.tgz
#    (or ${MACHINE_ARCH}/adobe-flash-plugin-${FLASH_VERSION}.tgz)
#    will be created.
#
# Caveats:
#  - Dumb idea, poor design and lack of documentation.
#  - There are few error checks.
#  - Needs more sane shell script implementation (functions etc).
#

FLASH_VERSION25=25.0.0.148
PKGREVISION25=

FLASH_VERSION11=11.2.202.644
PKGREVISION11=1

# check platform and setup platform specific values
MACHINE_ARCH=`uname -p`
RELEASE=`uname -r`
if [ ${MACHINE_ARCH} = "i386" ]; then
	FLASH_ARCH=i386
	PKGFILESDIR=pkgfiles
	FP_ARCHIVE_DIR_SUFFIX=32bit
elif [ ${MACHINE_ARCH} = "x86_64" ]; then
	FLASH_ARCH=x86_64
	PKGFILESDIR=pkgfiles64
	FP_ARCHIVE_DIR_SUFFIX=64bit
else
	echo "Error: non-x86 platform?"
	exit 1
fi
if [ ${RELEASE} = "7.0" -o ${RELEASE} = "7.0.1" -o ${RELEASE} = "7.0.2" \
    -o ${RELEASE} = "6.1.5" ]; then
	FLASH_VERSION=${FLASH_VERSION11}
	PKGREVISION=${PKGREVISION11}
	PKGNAME_BASE=adobe-flash-plugin
	DISTNAME=fp_${FLASH_VERSION}_archive
	EXTRACT_SUFX=.zip
	MASTER_SITES=http://fpdownload.macromedia.com/pub/flashplayer/installers/archive/
	FP_ARCHIVE_VERSION=11_2r202_644
	FP_ARCHIVE_DIR_PREFIX=11_2_r202_644
	FP_ARCHIVE_DIR=${FP_ARCHIVE_DIR_PREFIX}_${FP_ARCHIVE_DIR_SUFFIX}
	FP_ARCHIVE=flashplayer${FP_ARCHIVE_VERSION}_linux.${FLASH_ARCH}.tar.gz
else
	FLASH_VERSION=${FLASH_VERSION25}
	PKGREVISION=${PKGREVISION25}
	PKGNAME_BASE=adobe-flash-player
	DISTNAME=flash_player_npapi_linux.${FLASH_ARCH}
	EXTRACT_SUFX=.tar.gz
	MASTER_SITES=http://fpdownload.macromedia.com/get/flashplayer/pdc/${FLASH_VERSION}/
fi

# check unzip command in unzip package to extract files from .zip
if [ "${FLASH_VERSION}" = "${FLASH_VERSION11}" ]; then
	UNZIP=/usr/pkg/bin/unzip
	if [ ! -x ${UNZIP} ]; then
		echo "${UNZIP} is not found. Try \"pkg_add unzip\" etc."
		exit 1
	fi
fi

if [ ${PKGREVISION}x = "x" -o ${PKGREVISION}x = "0x" ]; then
	PKGNAME=${PKGNAME_BASE}-${FLASH_VERSION}
else
	PKGNAME=${PKGNAME_BASE}-${FLASH_VERSION}nb${PKGREVISION}
fi
DISTFILE=${DISTNAME}${EXTRACT_SUFX}

LIBFLASH=libflashplayer.so
PKGLIBFLASHPATH=lib/netscape/plugins

PKGFILES="+CONTENTS +COMMENT +DESC +INSTALL +DEINSTALL +BUILD_VERSION +BUILD_INFO +SIZE_PKG +SIZE_ALL"

DOWNLOADDIR=${MACHINE_ARCH}/download
WORKDIR=${MACHINE_ARCH}/work
PACKAGESDIR=${MACHINE_ARCH}

rm -rf ${DOWNLOADDIR}
rm -rf ${WORKDIR}

echo "Downloading a libflashplayer archive from adobe site..."
mkdir -p ${DOWNLOADDIR}
ftp -o ${DOWNLOADDIR}/${DISTFILE} ${MASTER_SITES}${DISTFILE}

echo "Extracting libflashplayer files from distfile..."
if [ "${FLASH_VERSION}" = "${FLASH_VERSION11}" ]; then
	unzip -q -d ${DOWNLOADDIR} ${DOWNLOADDIR}/${DISTFILE}
	tar -C ${DOWNLOADDIR} -zxf ${DOWNLOADDIR}/${FP_ARCHIVE_DIR}/${FP_ARCHIVE}
else
	tar -C ${DOWNLOADDIR} -zxf ${DOWNLOADDIR}/${DISTFILE}
fi

echo "Creating a packages tgz file using downloaded libflashplayer file..."
# copy template files into work dir
mkdir -p ${WORKDIR}
(cd ${MACHINE_ARCH}/${RELEASE}/${PKGFILESDIR} && pax -rw . ../../../${WORKDIR})

# copy necessary shlib into work dir
cp ${DOWNLOADDIR}/${LIBFLASH} ${WORKDIR}/${PKGLIBFLASHPATH}

# create .tgz package file
GZIP=-9 tar -zcf ${PACKAGESDIR}/${PKGNAME}.tgz -C ${WORKDIR} \
	${PKGFILES} ${PKGLIBFLASHPATH}/${LIBFLASH}

# complete.
echo "Done."
echo "------------------------------------------------------------------------"
echo "${PACKAGESDIR}/${PKGNAME}.tgz has been created."

# to avoid possible bikeshed about legal issue...
echo "------------------------------------------------------------------------"
echo "Please read readme.txt file in ${DOWNLOADDIR} dir."
echo "------------------------------------------------------------------------"
