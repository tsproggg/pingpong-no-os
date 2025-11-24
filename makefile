all: clean build run

build:
	./build_tools/build_no_docker.sh
    
run:
	./build_tools/run_no_docker.sh

clean:
	rm -rf ./app/*.bin ./app/*.img

