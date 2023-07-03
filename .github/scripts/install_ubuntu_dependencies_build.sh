# Install required dependencies for Ubuntu systems
sudo apt-get update -qq
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt install -y \
  g++-11 gcc-11 \
  cmake \
  build-essential \
  libreadline-dev \
  ninja-build 
  
sudo ln -sf /usr/bin/g++-11 /usr/bin/g++
sudo ln -sf /usr/bin/gcc-11 /usr/bin/gcc
sudo ln -sf /usr/bin/gcov-11 /usr/bin/gcov
