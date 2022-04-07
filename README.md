# Introduction
This repository is a collection of logic synthesis tools and utilities.

# Requirements
The repository requires SSH key setup. Please see instructions at [connecting-to-github-with-ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

# Repository Structure
```
.
|-- LSOracle-rs
|-- abc-rs
`-- de 

```

The repository has the following submodules:
 - [abc-rs](https://github.com/RapidSilicon/abc-rs.git) 
 - [LSOracle-rs](https://github.com/RapidSilicon/LSOracle-rs.git) 

 - `de` directory contains sources of Design Explorer utility.

## Build
After cloning the repo initialize/update submodules
```bash
git submodule update --init --recursive

```
To build DE:
```bash
cd logic_synthesis-rs
mkdir build
cd build
cmake ../
make
```
