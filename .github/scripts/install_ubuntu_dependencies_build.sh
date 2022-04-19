# Install required dependencies for Ubuntu systems
sudo apt-get update -qq
sudo apt install -y \
  g++-9 \
  cmake \
  build-essential \
  libreadline-dev \
  ninja-build 
  
sudo ln -sf /usr/bin/g++-9 /usr/bin/g++
sudo ln -sf /usr/bin/gcc-9 /usr/bin/gcc
sudo ln -sf /usr/bin/gcov-9 /usr/bin/gcov
