#OOC_LIBS=.
OOC_FLAGS=-DNDEBUG -D_GNU_SOURCE -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS +-O3 +-fomit-frame-pointer +-fPIC -noclean -v -c -driver=sequence
LLVM_FLAGS=$(shell llvm-config --ldflags --libs core) -O3 -fomit-frame-pointer -fPIC
OBJECTS=$(shell find ooc_tmp/ -name "*.o")

all: cpp_phase

ooc_phase:
	OOC_LIBS=. ooc test.ooc ${OOC_FLAGS}

cpp_phase: ooc_phase
	g++ ${OBJECTS} ${LLVM_FLAGS} -o test  /blue/Dev/ooc/libs/linux32/libgc.a

clean:
	rm -rf ooc_tmp/ test

test:
	./test
