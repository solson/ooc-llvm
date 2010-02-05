all:
	ooc $(shell llvm-config --ldflags --libs core) -v -driver=sequence -linker=g++ +-O3 +-fPIC +-fomit-frame-pointer test
clean:
	rm -rf ooc_tmp/ test

test:
	./test
