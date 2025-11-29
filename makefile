all: clean preprocess build run

preprocess:
	./build_tools/preprocess.sh

build:
	./build_tools/build_no_docker.sh
    
run:
	./build_tools/run_no_docker.sh

clean:
	rm -rf ./app/*.bin ./app/*.img ./src/kernel.asm

