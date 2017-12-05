OPT_LEVEL ?=
USE_SSE2 ?=

CFLAGS = -I. -Wall -Werror -fno-strict-aliasing $(OPT_LEVEL)
CXXFLAGS = -I. -Wall -Werror --std=c++11 $(OPT_LEVEL)

ifeq ($(USE_SSE2),1)
CFLAGS += -msse2
endif

PROGS = test/hash \
	test/hash.js \
	test/vectest \
	test/vectest.js

all: $(PROGS)

OBJS = keccak/keccak.o \
       blake/blake.o \
       skein/skein.o \
       groestl/groestl.o \
       oaes/oaes_lib.o \
       cryptonight/cryptonight.o

ifeq ($(USE_SSE2),1)
OBJS += jh/jh_sse2_opt64.o
else
OBJS += jh/jh_ansi_opt64.o
endif

EM_OBJS = $(OBJS:.o=.js.o)

# emscripten docker
EM_DOCKER = docker run -v $(CURDIR):/src:z,rw \
	trzeci/emscripten:sdk-tag-1.37.21-64bit
EMCC = $(EM_DOCKER) emcc
EM++ = $(EM_DOCKER) em++

$(EM_OBJS): %.js.o: %.c
	$(EMCC) $(CFLAGS) -o $@ $<

%.js: %.cc
	$(EM++) $(CXXFLAGS) -o $@ $^

%.js: %.c
	$(EMCC) $(CFLAGS) -o $@ $^

test/hash: $(OBJS)

test/hash.js: $(EM_OBJS)

test/vectest: $(OBJS)

test/vectest.js: $(EM_OBJS)

test: all
	test/test.sh

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
