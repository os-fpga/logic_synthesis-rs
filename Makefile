SHELL := /bin/bash

ifeq ($(CPU_CORES),)
	CPU_CORES := $(shell nproc)
	ifeq ($(CPU_CORES),)
		CPU_CORES := $(shell sysctl -n hw.physicalcpu)
	endif
	ifeq ($(CPU_CORES),)
		CPU_CORES := 2  # Good minimum assumption
	endif
endif

ADDITIONAL_CMAKE_OPTIONS ?=
PREFIX ?= /usr/local
RULE_MESSAGES ?= off

ABC=$(PREFIX)/bin/abc
DE=$(PREFIX)/bin/de
LSORACLE=$(PREFIX)/bin/lsoracle

##
## @ release
##     |---> info       :  Release build
##     |---> usage      :  make release
release: run-cmake-release
	cmake --build build -j $(CPU_CORES)

##
## @ debug
##     |---> info       :  Debug build
##     |---> usage      :  make debug
debug: run-cmake-debug
	cmake --build dbuild -j $(CPU_CORES)

run-cmake-release:
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_RULE_MESSAGES=$(RULE_MESSAGES) $(ADDITIONAL_CMAKE_OPTIONS) -S . -B build

run-cmake-debug:
	cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_RULE_MESSAGES=$(RULE_MESSAGES) $(ADDITIONAL_CMAKE_OPTIONS) -S . -B dbuild

##
## @ test
##     |---> info       :  Run tests
##     |---> usage      :  make test
test: release
	cmake --build build --target test
	#source tests/export_env.sh && $(ABC) -f tests/abc.scr

##
## @ clean
##     |---> info       :  Clean all
##     |---> usage      :  make clean
clean:
ifneq ("","$(wildcard build/Makefile)")
	cmake --build build --target clean
endif	
ifneq ("","$(wildcard dbuild/Makefile)")
	cmake --build dbuild --target clean
endif	
	$(RM) -r build dbuild

##
## @ install
##     |---> info       :  Install binaries and libraries
##     |---> usage      :  make install
install: release
	cmake --install build

# exports should not be used when https://github.com/RapidSilicon/yosys_verific_rs/issues/168 is fixed
##
## @ test_install
##     |---> info       :  Test if everything is installed properly
##     |---> usage      :  make test_install
test_install:
	export ABC=$(ABC) &&\
	export DE=$(DE) &&\
	export LSORACLE=$(LSORACLE) &&\
	cd abc-rs && $(ABC) -f ../tests/abc.scr

##
## @ uninstall
##     |---> info       :  Uninstall binaries and libraries
##     |---> usage      :  make uninstall
uninstall:
	$(RM) -r $(PREFIX)/bin/abc
	$(RM) -r $(PREFIX)/bin/de
	$(RM) -r $(PREFIX)/lib/abc

help: Makefile
	@echo '   #############################################'
	@echo '  ###############################################'
	@echo ' ###                                           ###'
	@echo '###  ###    ###  ########  ###       #########  ###'
	@echo '###  ###    ###  ########  ###       #########  ###'
	@echo '###  ###    ###  ###       ###       ###   ###  ###'
	@echo '###  ##########  ########  ###       #########  ###'
	@echo '###  ##########  ########  ###       #########  ###'
	@echo '###  ###    ###  ###       ###       ###        ###'
	@echo '###  ###    ###  ########  ########  ###        ###'
	@echo '###  ###    ###  ########  ########  ###        ###'
	@echo ' ###                                           ###'
	@echo '  ###############################################'
	@echo '   #############################################'
	@sed -n 's/^##//p' $<
