OPT_LEVEL ?=
USE_SSE2 ?=

CFLAGS = -Wall -Werror -fno-strict-aliasing $(OPT_LEVEL)
CXXFLAGS = -Wall -Werror --std=c++11 $(OPT_LEVEL)

ifeq ($(USE_SSE2),1)
CFLAGS += -msse2
endif

PROGS = hash_test hash_test.js hash_test2 hash_test2.js
all: $(PROGS)

OBJS = keccak.o blake.o skein.o groestl.o \
	   oaes_lib.o cryptonight.o

ifeq ($(USE_SSE2),1)
OBJS += jh/jh_sse2_opt64.o
else
OBJS += jh/jh_ansi_opt64.o
endif

EM_OBJS = $(OBJS:.o=.js.o)

# emscripten docker
EM_DOCKER = docker run -v $(CURDIR):/src \
	trzeci/emscripten:sdk-tag-1.37.3-64bit
EMCC = $(EM_DOCKER) emcc
EM++ = $(EM_DOCKER) em++

$(EM_OBJS): %.js.o: %.c
	$(EMCC) $(CFLAGS) -o $@ $<

%.js: %.cc
	$(EM++) $(CXXFLAGS) -o $@ $^

%.js: %.c
	$(EMCC) $(CFLAGS) -o $@ $^

hash_test: $(OBJS)

hash_test.js: $(EM_OBJS)

hash_test2: $(OBJS)

hash_test2.js: $(EM_OBJS)

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
