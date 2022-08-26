# Introduction
This repository is a collection of logic synthesis tools and utilities.

# Requirements
The repository requires SSH key setup. Please see instructions at [connecting-to-github-with-ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

# Repository Structure
```
.
|-- abc-rs
|-- Raptor_Tools
`-- de 

```

The repository has the following submodules:
 - [abc-rs](https://github.com/RapidSilicon/abc-rs.git) 
 - [Raptor_Tools](git@github.com:RapidSilicon/Raptor_Tools.git) 

 - `de` directory contains sources of Design Explorer utility.

## Build
After cloning the repository run the following commands.
```bash
  cd logic_synthesis-rs
  make
  make debug
  make test
  make install
```

Note 1: If you would like to update your local repository and build, then run the following commands.

```bash
  cd logic_synthesis-rs
  git pull
  make UPDATE_SUBMODULES=ON
```

Note 2: To build with production mode provide additional `PRODUCTION_BUILD=ON` make option.

```bash
  cd logic_synthesis-rs
  make PRODUCTION_BUILD=ON
```
