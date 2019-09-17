#!/bin/bash

# Abort if error
trap "exit 1" ERR

# Environments
export PATCH_DIR=$(pwd)/patches
export OUT_DIR=$(pwd)/

#====================================
# Build the checkinstall's RPM file.
#====================================

# Create a working directory.
mkdir -p /tmp/build
export BUILD_TMP="/tmp/build"
cd /tmp/build

# Install dependencies to build
export BUILD_REQUIRES="gcc,gettext,make"
yum -y install ${BUILD_REQUIRES//,/ }

#Go back out to where we were building things
cd $OUT_DIR
# Apply patches
yum -y install patch

cd ../
# Make and install
make install

# Run checkinstall to create its rpm
## Install dependencies to run checkinstall
export REQUIRES="gettext,file,which,tar,rpm-build"
yum -y install ${REQUIRES//,/ }
## Prepare environment to run the rpm-build
export HOME=/root
mkdir -p $HOME/rpmbuild/SOURCES
## Identify the version string. ("x.y.z")
export VERSION=$(checkinstall --version | grep "^checkinstall" | sed "s/checkinstall \(.*\), .*/\1/")
## Build a rpm.
checkinstall --type=rpm --pkgname=checkinstall --pkgversion=$VERSION --default --requires=$REQUIRES
## Save the full path of the rpm file into a file
export RPM_PATH="$HOME/rpmbuild/RPMS/$(arch)/checkinstall-$VERSION-1.$(arch).rpm"
## Install the generated rpm file to test it
yum -y localinstall $RPM_PATH
cd $BUILD_TMP

# Export
cp -a $RPM_PATH $OUT_DIR
rm -f $RPM_PATH
echo "========================="
echo "Created: $(basename $RPM_PATH)"
echo "========================="

# Clean up
cd /
yum clean all
rm -rf $BUILD_TMP
