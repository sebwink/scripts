#!/usr/bin/env bash

OPTIND=1
PATH=$HOME/bin:$HOME/tools/bin:/usr/local/bin:/usr/bin:/bin:/sbin

CRAN_DOWNLOAD_ROOT=https://cran.r-project.org/src/base/R-3
RVERSION=3.4.3
CONFIGURE_ARGS="--enable-R-shlib --enable-memory-profiling"

show_help() {
	echo "Usage: installr.sh [ -v R-Version ] (default: $RVERSION)"
	echo "                   [ -p install_prefix ] (default: $HOME/tools/R/<version>)"
	echo "                   [ -s unpacked_source ]"
	echo "                   [ -c configure_args ]"
}

while getopts "h?v:p:s:c:" opt; do
	case "$opt" in
		h|\?)
			show_help
			exit 0
			;;
		v)
			RVERSION="$OPTARG"
			;;
		p)
			INSTALL_PREFIX="$OPTARG"
			;;
		s)
			UNPACKED_RSRC="$OPTARG"
			;;
		c)
			CONFIGURE_ARGS="$OPTARG"
	esac
done

DOWNLOAD_URL=$CRAN_DOWNLOAD_ROOT/R-$RVERSION.tar.gz

if [ -z $UNPACKED_RSRC ]; then
	mkdir -p src
	UNPACKED_RSRC=src/R-$RVERSION
	RSRC_ARCHIVE=src/R-$RVERSION.tar.gz
	if [ ! -f $RSRC_ARCHIVE ]; then
		wget $DOWNLOAD_URL
		mv R-$RVERSION.tar.gz src
	else
		rm -r $UNPACKED_RSRC
	fi
	tar -xvf $RSRC_ARCHIVE -C src
fi

if [ -z $INSTALL_PREFIX ]; then
	INSTALL_PREFIX=$HOME/tools/R/$RVERSION
fi

cd $UNPACKED_RSRC

./configure --prefix=$INSTALL_PREFIX $CONFIGURE_ARGS

make && \
make install 

echo "R_LIBS_USER='$INSTALL_PREFIX/packages'" >> $INSTALL_PREFIX/lib*/R/etc/Renviron
mkdir $INSTALL_PREFIX/packages

cd ../..
rm -r $UNPACKED_RSRC
