OPT_LEVEL ?=
USE_SSE2 ?=
EMCC_WASM_BACKEND ?=

CFLAGS = -I. -Wall -Werror -fno-strict-aliasing $(OPT_LEVEL)
CXXFLAGS = -I. -Wall -Werror --std=c++11 $(OPT_LEVEL)

ifeq ($(USE_SSE2),1)
CFLAGS += -msse2
CXXFLAGS += -msse2
endif

PROGS = test/hash \
	test/hash.js \
	test/hash-wasm.js \
	test/vectest \
	test/vectest.js \
	test/vectest-wasm.js

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

%-wasm.js: %.cc
	$(EM++) -s WASM=1 $(CXXFLAGS) -o $@ $^

%-wasm.js: %.c
	$(EMCC) -s WASM=1 $(CFLAGS) -o $@ $^

test/hash: $(OBJS)

test/hash.js: $(EM_OBJS)

test/hash-wasm.js: $(EM_OBJS)

test/vectest: $(OBJS)

test/vectest.js: $(EM_OBJS)

test/vectest-wasm.js: $(EM_OBJS)

module.js: $(EM_OBJS)
	$(EMCC) -s MODULARIZE=1 -s NO_DYNAMIC_EXECUTION=1 -s EXPORTED_FUNCTIONS="['_cryptonight']" -s EXPORTED_RUNTIME_METHODS="['malloc', 'Pointer_stringify', 'cwrap', 'UTF8ToString']" -o $@ $^

cryptonight.js: pre.js module.js api.js post.js
	cat $^ > $@

test: all
	(cd test && ./test.sh)

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
