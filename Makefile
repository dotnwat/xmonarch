OPT_LEVEL ?=

CFLAGS = -Wall $(OPT_LEVEL)
CXXFLAGS = -Wall $(OPT_LEVEL)

PROGS = hash_test hash_test.js
all: $(PROGS)

OBJS = keccak.o jh_ansi_opt64.o blake.o skein.o groestl.o
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

hash_test: $(OBJS)

hash_test.js: $(EM_OBJS)

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
