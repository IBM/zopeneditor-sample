#
# Sample Program: Biorhythm
# Description   : Calculates biorhythm based on the current
#                 system date and birth date entered
#
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
#
# This example is taken from
# https://www.ibm.com/docs/en/zos/3.2.0?topic=guide-zos-xl-c-examples
#


TARGET = bio
SRC    = ccnubrc.cpp
HDR    = ccnubrh.hpp

CXX    = c++
CXXFLAGS = -+ -Wc,xplink
LDFLAGS  = -Wl,xplink

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC) $(HDR)
	$(CXX) -o $(TARGET) $(CXXFLAGS) $(LDFLAGS) $(SRC)

clean:
	rm -f $(TARGET)
