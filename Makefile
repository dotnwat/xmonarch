CFLAGS = -Wall
CXXFLAGS = -Wall

PROGS = test_keccak test_keccak.js
all: $(PROGS)

OBJS = keccak.o
EM_OBJS = $(OBJS:.o=.js.o)

# emscripten docker
EM_DOCKER = docker run -v $(CURDIR):/src \
	trzeci/emscripten:sdk-tag-1.37.3-64bit
EMCC = $(EM_DOCKER) emcc
EM++ = $(EM_DOCKER) em++

$(EM_OBJS): %.js.o: %.c
	$(EMCC) -o $@ $<

%.js: %.cc
	$(EM++) -o $@ $^

test_keccak: $(OBJS)

test_keccak.js: $(EM_OBJS)

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
