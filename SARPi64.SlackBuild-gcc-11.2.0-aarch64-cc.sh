#! /bin/bash

##############################################################################
# Slackware ARM gcc-11.2.0 aarch64 cross-compiler for Raspberry Pi
#
# SARPi64.SlackBuild-gcc-11.2.0-aarch64-cc [v1.4] - 2021-09-25
#
# 2021-09-25 by Exaga   -   v1.4   -  gcc-11.x
# 2020-12-29 by Exaga   -   v1.3   -  gcc-10.x
# 2019-07-10 by Exaga   -   v1.2   -  gcc-9.x
# 2016-12-17 by Exaga 	-   v1.0   -  gcc-5.x
# 2016-12-12 by Exaga 	-   v0.2b  -  beta
# 2016-12-05 by Exaga 	-   v0.1a  -  alpha
#
##############################################################################
#
# This script downloads RPi Linux kernel source and the required binaries, 
# and configures, builds, patches, and installs a gcc 11.2.x aarch64-linux 
# cross-compiler on Slackware ARM current running on a Raspberry Pi 3/4.
#
### Usage & Installation ###
# You should create a 'build-dir' folder and copy this script to it 
# (e.g. /tmp/build-dir) and run it from there as a 'root' user. 
#
# ~# chmod +x SARPi64.SlackBuild-gcc-11.2.0-aarch64-cc.sh
# ~# ./SARPi64.SlackBuild-gcc-11.2.0-aarch64-cc.sh
#
# You may install the cross-compiler anywhere you like, as long as it can be 
# accessed by a normal user (i.e. not 'root'). The default is /tmp/.gcc-cross 
# but if this is not suitable then set your own installation directory with 
# INSTALL_PATH variable, in the settings below.  
#
# Ensure 'bison', 'flex', 'gawk', and 'git' are installed on your system 
# before running this script! Use these commands to check:
# 
# ~# whereis gawk
# ~# whereis git
# ~# whereis bison
# ~# whereis flex
#
# If you need to install any of the packages above [* check for updates!]:
# http://slackware.uk/slackwarearm/slackwarearm-current/slackware/a/gawk*.txz  
# http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/git*.txz 
# http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/bison*.txz 
# http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/flex*.txz
#
# NB: The gcc package you compile should match your currently installed gcc 
# version. Use this command to check your current gcc version:
#
# ~# gcc --version
#
# More recent gcc packages-versions may exist. You may wish to install them. 
# NB: if you use newer packages - glibc version _MUST_ suit gcc version! The
# thing to make sure is the release dates of gcc and glibc versions being as
# close as possible.
#
# binutils - https://ftp.gnu.org/gnu/binutils/
# cloog - ftp://gcc.gnu.org/pub/gcc/infrastructure/
# gcc - https://ftp.gnu.org/gnu/gcc/
# glibc - https://ftp.gnu.org/gnu/glibc/
# gmp - https://ftp.gnu.org/gnu/gmp/
# isl - ftp://gcc.gnu.org/pub/gcc/infrastructure/
# mpfr - https://ftp.gnu.org/gnu/mpfr/
# mpc - https://ftp.gnu.org/gnu/mpc/
#
### IMPORTANT! ###
# This script will export the INSTALL_PATH variable into the $PATH. 
# The PATH of the cross-compiler should always be the first item in 
# the $PATH. PATH command: 
# 
# ~# export PATH=/tmp/.gcc-cross/bin:$PATH
#
# To check that the INSTALL_PATH is in your $PATH use this command: 
# 
# ~# echo $PATH
#
### Usage ###
# This script was created on Slackware ARM and intended for research and 
# development towards a Slackware AArch64 port. This script may work on 
# other Linux distributions and hardware but it has not been tested and
# therefore cannot be verified. It may be freely distributed, copied, 
# modified, or plagiarised in the hope that it will be of some use towards
# the goal of Slackware AArch64. 
#
### Resource(s) ###
# http://www.slackware.com
# http://slackware.uk
# http://arm.slackware.com/FAQs
# http://wiki.osdev.org/GCC_Cross-Compiler
# https://www.raspberrypi.org/documentation/linux/kernel
# https://www.github.com/raspberrypi
# https://ftp.gnu.org/gnu
# ftp://gcc.gnu.org/pub/gcc/infrastructure
#
##############################################################################


# Installation directory - edit INSTALL_PATH as required
INSTALL_PATH=/tmp/.gcc-cross

# Required build packages-versions [* newer versions may exist]
BINUTILS_VERSION=binutils-2.37
CLOOG_VERSION=cloog-0.18.1
GCC_VERSION=gcc-11.2.0
GLIBC_VERSION=glibc-2.34
GMP_VERSION=gmp-6.2.1
ISL_VERSION=isl-0.18
MPFR_VERSION=mpfr-4.1.0
MPC_VERSION=mpc-1.2.1

# RPi GitHub Linux source - working branch [e.g. rpi-4.14.y | rpi-4.19.y | rpi-5.2.y ] 
DEV_BRANCH=rpi-5.14.y


#############################################################################
## DO NOT EDIT ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING! ##
#############################################################################

# Halt build process on error [with output]
set -euo pipefail
IFS=$'\n\t'
# Uncomment for additional error output when testing/debugging
#trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
#trap 'echo "exit $? due to $previous_command"' EXIT

# Build variables
PRGNAM=SARPi64.SlackBuild-aarch64-cc
ARCH_TARGET=aarch64-linux  
LINUX_ARCH=arm64
QUADLET=aarch64-unknown-linux-gnu # aarch64-arm-none-eabi
LINUX_FLAVOUR=linux-rpi 
RPI_GITURL_LINUX=https://github.com/raspberrypi
BUILD_LANGUAGES="--enable-languages=c,c++" # --enable-languages=all,ada,c,c++,fortran,go,jit,lto,objc,obj-c++
ALT_CONFIG_OPTIONS="--disable-multilib" # --disable-threads --disable-shared --disable-multiarch
TEST_CONFIG_OPTIONS="--with-arch=armv8-a --with-tune=cortex-a72 --with-fpu=vfpv3-d16 --with-float=hard" # 
RPI4_CONFIG_OPTIONS="--prefix=$INSTALL_PATH --target=arm-linux-gnueabihf --enable-languages=c,c++ --with-arch=armv8-a --with-fpu=vfp --with-float=hard --disable-multilib" # 
PARALLEL_JOBS=-j4 # https://www.gnu.org/software/make/manual/html_node/Parallel.html
CWD=$(pwd)

# Define CONFIG_OPTIONS for build
CONFIG_OPTIONS=$ALT_CONFIG_OPTIONS

# Uncomment to log EVERYTHING during build process [** WARNING! HUGE log filesize! **]
#LOGFLE=${PRGNAM}_build_$(date +"%F").log
#exec 1> >(logger -s -t $(basename $0)) 2>&1 > $LOGFLE

# Output aesthetics
sarpiSP64 () {
echo 
echo " ############################################"
echo " ## $PRGNAM "
echo " ## Build: $GCC_VERSION  Kernel ${DEV_BRANCH} "
echo " ## Timestamp: $(date '+%F %T') "
echo " ## SARPi64 Project [sarpi64.penthux.net] "
echo " ############################################"
echo 
}

sarpiSP64
echo "Starting $PRGNAM build ..."

# INSTALL_PATH needs to be at the front of $PATH
# Command: export PATH=/tmp/.gcc-cross/bin:$PATH
echo "Checking $ARCH_TARGET $INSTALL_PATH/bin \$PATH ..."
if [[ ! "$PATH" =~ $INSTALL_PATH ]]; then
    export PATH=/"${INSTALL_PATH}"/bin:$PATH 
# echo -e $INSTALL_PATH/bin:$(cat $PATH) > $PATH || exit 1
else
    echo "Found $INSTALL_PATH\/bin in \$PATH : OK! ... "
fi

# Prerequisite packages
BISON_REQ=$(which bison)
FLEX_REQ=$(which flex)
GAWK_REQ=$(which gawk)
GIT_REQ=$(which git)

# Check prerequisites are installed, or exit 
if [ ! -e "$BISON_REQ" ]; then
  echo "ERROR: bison not found!"
  echo "Install bison before you run this script!"
  exit 1
elif [ ! -e "$FLEX_REQ" ]; then
  echo "ERROR: flex not found!"
  echo "Install flex before you run this script!"
  exit 1
elif [ ! -e "$GAWK_REQ" ]; then
  echo "ERROR: gawk not found!"
  echo "Install gawk before you run this script!"
  exit 1
elif [ ! -e "$GIT_REQ" ]; then
  echo "ERROR: git not found!"
  echo "Install git before you run this script!"
  exit 1
else
  echo "Prerequisite packages are installed ..."	
fi

# Download RPi kernel source ** this may take a while **
cd "$CWD"
echo "Checking kernel $DEV_BRANCH source ..."
if [ ! -e $LINUX_FLAVOUR/Makefile ]; then
  echo "Downloading kernel $DEV_BRANCH source ..."
  git clone --depth=1 $RPI_GITURL_LINUX/linux.git --branch $DEV_BRANCH $LINUX_FLAVOUR
fi
cd $LINUX_FLAVOUR
echo "Checking kernel $DEV_BRANCH branch for updates ..."
git checkout -f $DEV_BRANCH
cd "$CWD"

# Download gcc and related packages to build cross-compiler
echo "Downloading packages ..."
if [ ! -d "$CWD"/$BINUTILS_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz
  tar -xvf $BINUTILS_VERSION.tar.gz
fi
if [ ! -d "$CWD"/$GCC_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
  tar -xvf $GCC_VERSION.tar.gz
fi
if [ ! -d "$CWD"/$GLIBC_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.xz
  tar -xvf $GLIBC_VERSION.tar.xz
fi
if [ ! -d "$CWD"/$GMP_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
  tar -xvf $GMP_VERSION.tar.xz
fi
if [ ! -d "$CWD"/$MPFR_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
  tar -xvf $MPFR_VERSION.tar.xz
fi
if [ ! -d "$CWD"/$MPC_VERSION ]; then
  wget -nc --progress=bar https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz
  tar -xvf $MPC_VERSION.tar.gz
fi
if [ ! -d "$CWD"/$ISL_VERSION ]; then
  wget -nc --progress=bar ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
  tar -xvf $ISL_VERSION.tar.bz2
fi
if [ ! -d "$CWD"/$CLOOG_VERSION ]; then
  wget -nc --progress=bar ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz
  tar -xvf $CLOOG_VERSION.tar.gz
fi

# Create symbolic links so gcc builds these dependencies automatically
echo "Creating symbolic links in gcc ..."
cd "$CWD"/$GCC_VERSION
ln -sf ../$MPFR_VERSION mpfr
ln -sf ../$GMP_VERSION gmp
ln -sf ../$MPC_VERSION mpc
ln -sf ../$ISL_VERSION isl
ln -sf ../$CLOOG_VERSION cloog

# Create aarch64 cross-compiler install directory
echo "Creating $INSTALL_PATH directory ..."
rm -rf $INSTALL_PATH
mkdir -p $INSTALL_PATH
chown "$(whoami)" $INSTALL_PATH
cd "$CWD"

# Build binutils
echo "Building binutils ..."
rm -rf build-binutils
mkdir build-binutils
cd build-binutils
../$BINUTILS_VERSION/configure --prefix=$INSTALL_PATH --target=$ARCH_TARGET $CONFIG_OPTIONS
make $PARALLEL_JOBS
echo "Installing binutils ..."
make install

# Install Linux kernel headers
echo "Installing kernel headers ..."
cd "$CWD"/$LINUX_FLAVOUR
make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$INSTALL_PATH/$ARCH_TARGET headers_install
cd "$CWD"

# Build gcc C and C++ cross-compilers
echo "Building gcc $ARCH_TARGET C,C++ cross-compiler ..."
mkdir -p build-gcc
cd build-gcc
../$GCC_VERSION/configure --prefix=$INSTALL_PATH --target=$ARCH_TARGET $BUILD_LANGUAGES $CONFIG_OPTIONS
make $PARALLEL_JOBS all-gcc
echo "Installing gcc $ARCH_TARGET cross-compiler to $INSTALL_PATH ..."
make $PARALLEL_JOBS install-gcc

# create gcc-11.2.0 libsanitizer asan_linux-cpp.patch file
cd "$CWD"
touch asan_linux-cpp.patch
cat << EOF > asan_linux-cpp.patch
--- gcc-11.2.0/libsanitizer/asan/asan_linux.cpp	2021-07-28 07:55:09.172313645 +0100
+++ asan_linux.cpp	2021-09-25 12:35:18.000000000 +0100
@@ -76,6 +76,10 @@
 asan_rt_version_t  __asan_rt_version;
 }
 
+#ifndef PATH_MAX
+#define PATH_MAX 4096
+#endif
+
 namespace __asan {
 
 void InitializePlatformInterceptors() {}

EOF

# Patch gcc-11.2.x/libsanitizerasan/asan_linux.cpp [or the build will fail]
ASANLINUXCC=$CWD/$GCC_VERSION/libsanitizer/asan/asan_linux.cpp
if [ ! -f "$ASANLINUXCC".orig ]; then
  echo "Patching $ASANLINUXCC ..."
  patch -b "$ASANLINUXCC" asan_linux-cpp.patch || exit 1
  sarpiSP64
  echo "$ASANLINUXCC has been PATCHED! ..."
  echo "Backup of original: $ASANLINUXCC.orig ..."
  sleep 10
fi

# Build and install glibc's standard C library headers and startup files
echo "Building glibc library headers ..."
mkdir -p build-glibc
cd build-glibc
../$GLIBC_VERSION/configure --prefix=$INSTALL_PATH/$ARCH_TARGET --build="$MACHTYPE" --host=$ARCH_TARGET --target=$ARCH_TARGET --with-headers=$INSTALL_PATH/$ARCH_TARGET/include $CONFIG_OPTIONS libc_cv_forced_unwind=yes
make $PARALLEL_JOBS install-bootstrap-headers=yes install-headers
make $PARALLEL_JOBS csu/subdir_lib
echo "Installing glibc library headers ..."
install csu/crt1.o csu/crti.o csu/crtn.o $INSTALL_PATH/$ARCH_TARGET/lib
$ARCH_TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $INSTALL_PATH/$ARCH_TARGET/lib/libc.so
touch $INSTALL_PATH/$ARCH_TARGET/include/gnu/stubs.h

# Build glibc support library
echo "Building glibc support library ..."
cd "$CWD"/build-gcc
make $PARALLEL_JOBS all-target-libgcc
echo "Installing glibc support library ..."
make install-target-libgcc

# Finish building glibc's standard C library and install it
echo "Completing glibc C library ..."
cd "$CWD"/build-glibc
make $PARALLEL_JOBS
echo "Installing glibc C library ..."
make install

# Finish building gcc's C++ library and install it
echo "Completing glibc C++ library ..."
cd "$CWD"/build-gcc
make $PARALLEL_JOBS
echo "Installing glibc C++ library ..."
make install
cd "$CWD"

# Check status of aarch64-linux-gcc cross-compiler
echo "Checking status of $ARCH_TARGET-gcc cross-compiler ..."
ARCH_TARGET_STATUS=$(which $ARCH_TARGET-gcc)
$ARCH_TARGET-gcc -v
if [ ! -e "$ARCH_TARGET_STATUS" ]; then
  # ERROR!
  echo "ERROR: $ARCH_TARGET-gcc not responding!"
  sarpiSP64
  echo "$(date +"%F %T") : $PRGNAM FAILED! ..."
  exit 1
else 
  # Done!
  echo "Verifying $ARCH_TARGET-gcc \$PATH ..."
  echo "PATH: $PATH"
  echo "Status: $ARCH_TARGET-gcc : READY!"
  sarpiSP64
  echo "$(date +"%F %T") : $PRGNAM build complete ..."
fi

# 
exit 0

#EOF<*>