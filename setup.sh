#!/bin/bash

########## LICENCE ##########
# Copyright (c) 2014,2015 Genome Research Ltd.
#
# Author: Cancer Genome Project <cgpit@sanger.ac.uk>
#
# This file is part of cgpVcf.
#
# cgpVcf is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# 1. The usage of a range of years within a copyright statement contained within
# this distribution should be interpreted as being equivalent to a list of years
# including the first and last year specified and all consecutive years between
# them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
# 2009, 2011-2012’ should be interpreted as being identical to a statement that
# reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
# statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
# identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
# 2009, 2010, 2011, 2012’."
########## LICENCE ##########


SOURCE_TABIX="http://sourceforge.net/projects/samtools/files/tabix/tabix-0.2.6.tar.bz2/download"
SOURCE_VCFTOOLS="http://sourceforge.net/projects/vcftools/files/vcftools_0.1.12a.tar.gz/download"

done_message () {
    if [ $? -eq 0 ]; then
        echo " done."
        if [ "x$1" != "x" ]; then
            echo $1
        fi
    else
        echo " failed.  See setup.log file for error messages." $2
        echo "    Please check INSTALL file for items that should be installed by a package manager"
        exit 1
    fi
}

get_distro () {
  EXT=""
  DECOMP="gunzip -f"
  if [[ $2 == *.tar.bz2* ]] ; then
    EXT="tar.bz2"
    DECOMP="bzip2 -fd"
  elif [[ $2 == *.tar.gz* ]] ; then
    EXT="tar.gz"
  else
    echo "I don't understand the file type for $1"
    exit 1
  fi
  if hash curl 2>/dev/null; then
    curl -sS -o $1.$EXT -L $2
  else
    wget -nv -O $1.$EXT $2
  fi
  mkdir -p $1
  `$DECOMP $1.$EXT`
  tar --strip-components 1 -C $1 -xf $1.tar
}

get_file () {
# output, source
  if hash curl 2>/dev/null; then
    curl --insecure -sS -o $1 -L $2
  else
    wget -nv -O $1 $2
  fi
}

if [[ ($# -ne 1 && $# -ne 2) ]] ; then
  echo "Please provide an installation path and optionally perl lib paths to allow, e.g."
  echo "  ./setup.sh /opt/myBundle"
  echo "OR all elements versioned:"
  echo "  ./setup.sh /opt/cgpVcf-X.X.X /opt/PCAP-X.X.X/lib/perl"
  exit 0
fi

INST_PATH=$1

if [[ $# -eq 2 ]] ; then
  CGP_PERLLIBS=$2
fi

CPU=`grep -c ^processor /proc/cpuinfo`
if [[ $? -eq 0 ]]; then
  if [[ $CPU -gt 6 ]]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"

# get current directory
INIT_DIR=`pwd`

# re-initialise log file
echo > $INIT_DIR/setup.log

# log information about this system
(
    echo '============== System information ===='
    set -x
    lsb_release -a
    uname -a
    sw_vers
    system_profiler
    grep MemTotal /proc/meminfo
    set +x
    echo; echo
) >>$INIT_DIR/setup.log 2>&1

# cleanup inst_path
mkdir -p $INST_PATH/bin
cd $INST_PATH
INST_PATH=`pwd`
cd $INIT_DIR

# make sure that build is self contained
PERLROOT=$INST_PATH/lib/perl5
if [ -z ${CGP_PERLLIBS+x} ]; then
  export PERL5LIB="$PERLROOT"
else
  export PERL5LIB="$PERLROOT:$CGP_PERLLIBS"
fi

#create a location to build dependencies
SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR

## grab cpanm:
rm -f $SETUP_DIR/cpanm
get_file $SETUP_DIR/cpanm http://xrl.us/cpanm
chmod +x $SETUP_DIR/cpanm

cd $SETUP_DIR

CURR_TOOL="tabix"
CURR_SOURCE=$SOURCE_TABIX
echo -n "Building $CURR_TOOL ..."
if [ -e $SETUP_DIR/$CURR_TOOL.success ]; then
  echo -n " previously installed ..."
else
  (
    set -ex
    get_distro $CURR_TOOL $CURR_SOURCE
    cd $SETUP_DIR/$CURR_TOOL
    make -j$CPU
    cp tabix $INST_PATH/bin/.
    cp bgzip $INST_PATH/bin/.
    cd perl
    patch Makefile.PL < $INIT_DIR/patches/tabixPerlLinker.diff
    perl Makefile.PL INSTALL_BASE=$INST_PATH
    make
    make test
    make install
    touch $SETUP_DIR/$CURR_TOOL.success
  ) >>$INIT_DIR/setup.log 2>&1
fi
done_message "" "Failed to build $CURR_TOOL."

cd $SETUP_DIR

CURR_TOOL="vcftools"
CURR_SOURCE=$SOURCE_VCFTOOLS
echo -n "Building $CURR_TOOL ..."
if [ -e $SETUP_DIR/$CURR_TOOL.success ]; then
  echo -n " previously installed ..."
else
  (
    set -ex
    get_distro $CURR_TOOL $CURR_SOURCE
    cd $SETUP_DIR/$CURR_TOOL
    patch Makefile < $INIT_DIR/patches/vcfToolsInstLocs.diff
    patch perl/Vcf.pm < $INIT_DIR/patches/vcfToolsProcessLog.diff
    make -j$CPU PREFIX=$INST_PATH
    touch $SETUP_DIR/$CURR_TOOL.success
  ) >>$INIT_DIR/setup.log 2>&1
fi
done_message "" "Failed to build $CURR_TOOL."

#add bin path for install tests
export PATH="$INST_PATH/bin:$PATH"

cd $INIT_DIR

echo -n "Installing Perl prerequisites ..."
if ! ( perl -MExtUtils::MakeMaker -e 1 >/dev/null 2>&1); then
    echo
    echo "WARNING: Your Perl installation does not seem to include a complete set of core modules.  Attempting to cope with this, but if installation fails please make sure that at least ExtUtils::MakeMaker is installed.  For most users, the best way to do this is to use your system's package manager: apt, yum, fink, homebrew, or similar."
fi
(
  set -x
  $SETUP_DIR/cpanm -v --mirror http://cpan.metacpan.org --notest -l $INST_PATH/ --installdeps . < /dev/null
  set +x
) >>$INIT_DIR/setup.log 2>&1
done_message "" "Failed during installation of core dependencies."

echo -n "Installing cgpVcf ..."
(
  set -e
  cd $INIT_DIR
  perl Makefile.PL INSTALL_BASE=$INST_PATH
  make
  make test
  make install
) >>$INIT_DIR/setup.log 2>&1
done_message "" "cgpVcf install failed."

# cleanup all junk
rm -rf $SETUP_DIR

echo
echo
echo "Please add the following to beginning of path:"
echo "  $INST_PATH/bin"
echo "Please add the following to beginning of PERL5LIB:"
echo "  $PERLROOT"
echo

exit 0
