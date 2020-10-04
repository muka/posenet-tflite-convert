

clean:
	rm -rf ./data

setup: clean download bazel/build

download:
	mkdir -p ./data
	cd data && git clone https://github.com/google-coral/edgetpu.git
	cd data/edgetpu && git apply ../../edgetpu.diff

bazel/build:
	docker build . -f Dockerfile.bazel -t opny/posenet-tflite-convert

bazel/bash:
	mkdir -p ./data/tmp
	docker run \
		-v `pwd`/data/edgetpu:/src/workspace \
		-v `pwd`/data/tmp:/tmp/build_output \
		-w /src/workspace \
		--entrypoint bash -it \
		opny/posenet-tflite-convert

bazel/clean:
	rm -rf ./data/tmp
	mkdir -p ./data/tmp

bazel/compile:
	mkdir -p ./data/tmp
	docker run \
		-e BAZEL_CXXOPTS="-std=c++11" \
		-e USER="`id -u`" \
		-u="`id -u`" \
		-v `pwd`/data/edgetpu:/src/workspace \
		-v `pwd`/data/tmp:/tmp/build_output \
		-w /src/workspace \
		opny/posenet-tflite-convert \
		--output_user_root=/tmp/build_output build src/cpp/posenet/posenet_decoder.so \
		--sandbox_debug --verbose_failures
	cp data/tmp/*/execroot/edgetpu/bazel-out/k8-fastbuild/bin/src/cpp/posenet/posenet_decoder.so data/