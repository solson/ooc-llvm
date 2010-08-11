OOC?=rock

all:
	${OOC} -v -g test.ooc

#	${OOC} $(shell llvm-config --ldflags --libs core executionengine jit interpreter native) -v -g -linker=g++ +-DNDEBUG +-D_GNU_SOURCE +-D__STDC_LIMIT_MACROS +-D__STDC_CONSTANT_MACROS +-O3 +-fPIC +-fomit-frame-pointer test

clean:
	rm -rf ooc_tmp/ rock_tmp/ test

test: all
	./test

.PHONY: clean test
