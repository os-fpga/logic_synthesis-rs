# Install required dependencies for CentOS systems
yum update -y
yum group install -y "Development Tools" 
yum install -y epel-release 
curl -C - -O https://cmake.org/files/v3.15/cmake-3.15.7-Linux-x86_64.tar.gz
tar xzf cmake-3.15.7-Linux-x86_64.tar.gz
ln -s $PWD/cmake-3.15.7-Linux-x86_64/bin/cmake /usr/bin/cmake
yum install -y openssh-server openssh-clients
yum install -y centos-release-scl
yum install -y devtoolset-9
yum install -y devtoolset-9-toolchain
yum install -y devtoolset-9-gcc-c++
scl enable devtoolset-9 bash
yum install -y make
yum install -y readline-devel
yum install http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-1.noarch.rpm
yum install -y ninja-build


ln -s $PWD/cmake-3.15.7-Linux-x86_64/bin/ctest /usr/bin/ctest
echo 'QMAKE_CC=/opt/rh/devtoolset-9/root/usr/bin/gcc' >> $GITHUB_ENV
echo 'QMAKE_CXX=/opt/rh/devtoolset-9/root/usr/bin/g++' >> $GITHUB_ENV
