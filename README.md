# Slackware ARM cross-compiler Bash script README

This script downloads RPi Linux kernel source and the required binaries, \
and configures, builds, patches, and installs a gcc 10.2.x aarch64-linux \
cross-compiler on Slackware ARM current running on a Raspberry Pi 3/4.

## Usage & Installation ###
You should create a 'build-dir' folder and copy this script to it \
(e.g. /tmp/build-dir) and run it from there as a 'root' user. 

~# chmod +x SARPi64.SlackBuild-gcc-10.2-aarch64-cc.sh \
~# ./SARPi64.SlackBuild-gcc-10.2-aarch64-cc.sh

You may install the cross-compiler anywhere you like, as long as it can be \
accessed by a normal user (i.e. not 'root'). The default is /tmp/.gcc-cross \
but if this is not suitable then set your own installation directory with \
INSTALL_PATH variable, in the settings below.  

Ensure 'bison', 'flex', 'gawk', and 'git' are installed on your system \
before running this script! Use these commands to check:

~# whereis gawk \
~# whereis git \
~# whereis bison \
~# whereis flex

If you need to install any of the packages above [* check for updates!]: \
http://slackware.uk/slackwarearm/slackwarearm-current/slackware/a/gawk*.txz \
http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/git*.txz \
http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/bison*.txz \
http://slackware.uk/slackwarearm/slackwarearm-current/slackware/d/flex*.txz \

NB: The gcc package you compile should match your currently installed gcc \
version. Use this command to check your current gcc version:

~# gcc --version

More recent gcc packages-versions may exist. You may wish to install them. \
NB: if you use newer packages - glibc version _MUST_ suit gcc version! The \
thing to make sure is the release dates of gcc and glibc versions being as \
close as possible.

binutils - https://ftp.gnu.org/gnu/binutils/ \
cloog - ftp://gcc.gnu.org/pub/gcc/infrastructure/ \
gcc - https://ftp.gnu.org/gnu/gcc/ \
glibc - https://ftp.gnu.org/gnu/glibc/ \
gmp - https://ftp.gnu.org/gnu/gmp/ \
isl - ftp://gcc.gnu.org/pub/gcc/infrastructure/ \
mpfr - https://ftp.gnu.org/gnu/mpfr/ \
mpc - https://ftp.gnu.org/gnu/mpc/ \
 
 ### IMPORTANT! ### 
Before running this build script, export the INSTALL_PATH on your \
root 'user'. Also do this each time you (re)boot your system so that \
the location of the cross-compiler is always the first item in your \
$PATH. You can also add this command to your ~/.profile as a more \
permanent fixture. It's up to you if/how you do it. Example export \
PATH command: 

~# export PATH=/tmp/.gcc-cross/bin:$PATH \

To check that the INSTALL_PATH is in your $PATH use this command: 

~# echo $PATH

 ### Usage ### 
This script was created on Slackware ARM and intended for research and \
development towards a Slackware AArch64 port. This script may work on \
other Linux distributions and hardware but it has not been tested and \
therefore cannot be verified. It may be freely distributed, copied, \
modified, or plagiarised in the hope that it will be of some use towards \
the goal of Slackware AArch64. 

Edit the INSTALL_PATH variable before you run this script. This the location \
where you want the cross-compiler to be installed on your system.
```
# Installation directory - edit INSTALL_PATH as required
INSTALL_PATH=/tmp/.gcc-cross
```
