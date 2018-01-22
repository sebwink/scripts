#!/usr/bin/env xonsh

import os
import glob

RSTUDIO_INSTALL_ROOT=$HOME+'/tools/R/rstudio'
RSTUDIO_DOWNLOAD_ROOT='https://download1.rstudio.org/'

def get_latest_rstudio_version():
	RSTUDIO_DOWNLOAD_PAGE='https://www.rstudio.com/products/rstudio/download/#download'
	curl @(RSTUDIO_DOWNLOAD_PAGE) | grep 'RStudio Release Notes' > .magicline
	magicline = $(cat .magicline)
	return $(cat .magicline).split('strong>')[1].split(' ')[-1][:-2]

def DEFAULT_DEBIAN_BUILD(version):
	return 'rstudio-'+version+'-amd64-debian.tar.gz'

def DEFAULT_FEDORA_BUILD(version):
	return 'rstudio-'+version+'-x86_64-fedora.tar.gz'

def download_build(version, build):
	wget @(RSTUDIO_DOWNLOAD_ROOT+build)

def install_build(build_archive, install_root, version):
	INSTALL_DIR = install_root+'/'+version
	UNPACKED_ARCHIVE = install_root+'/rstudio-'+version
	mkdir -p @(install_root)
	tar -xvf @(build_archive) -C @(install_root)
	mkdir @(INSTALL_DIR)
	for file in glob.glob(UNPACKED_ARCHIVE+'/*'):
		mv @(file) @(INSTALL_DIR+'/'+os.path.basename(file))
	rmdir @(UNPACKED_ARCHIVE)
	print('RStudio '+version+' installed @ '+INSTALL_DIR)


def main():
	LATEST_RSTUDIO_VERSION = get_latest_rstudio_version()
	print('Latest available R-Studio version: '+LATEST_RSTUDIO_VERSION)
	
	rstudio_version = LATEST_RSTUDIO_VERSION
	get_debian_build = DEFAULT_DEBIAN_BUILD
	get_fedora_build = DEFAULT_FEDORA_BUILD
	install_root = RSTUDIO_INSTALL_ROOT

	# on Debian derivatives
	if os.path.isfile('/etc/debian_version'):
		echo 'Apparently on a Debian-derived system.'
		build = get_debian_build(rstudio_version)
	else: # else assuming Fedora, OpenSUSE or CentOS
		echo 'Apparently on a Fedora-like system.'
		build = get_fedora_build(rstudio_version)
	
	download_build(rstudio_version, build)
	install_build(build, install_root, rstudio_version)

main()
