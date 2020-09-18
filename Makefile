
TFLITE_MODEL ?= posenet_mobilenet_v1_075_353_481_quant_decoder_edgetpu

SCHEMA ?= /data/schema.fbs
MODEL ?= /data/$(TFLITE_MODEL).tflite
MODEL_UPDATE ?= /data/$(TFLITE_MODEL).updated.json
FLATC ?= docker run -v `pwd`/data:/data neomantra/flatbuffers flatc

DOCKER_IMAGE ?= opny/posenet-tpu

clean:
	rm -rf ./data

download:
	mkdir -p ./data
	wget https://github.com/google-coral/project-posenet/blob/master/models/mobilenet/$(TFLITE_MODEL).tflite?raw=true -O data/$(TFLITE_MODEL).tflite
	# tflite schema
	wget https://github.com/tensorflow/tensorflow/raw/master/tensorflow/lite/schema/schema.fbs -O data/schema.fbs

convert: convert/json convert/update_model convert/tflite

#1 tflite -> json
convert/json:
	$(FLATC) -t --strict-json --defaults-json -o /data $(SCHEMA) -- $(MODEL)

#2 drop custom ops
convert/update_model:
	python3 convert.py

#3 json -> tflite
convert/tflite:
	$(FLATC) -c -b -o /data $(SCHEMA) $(MODEL_UPDATE)

docker/build:
	docker build . -t $(DOCKER_IMAGE)

docker/run:
	docker run --rm -it \
	-v `pwd`/data:/data \
	-v `pwd`/test.jpg:/test.jpg \
	-v `pwd`/run.py:/run.py \
	-v `pwd`/posenet:/posenet \
	-v /dev:/dev \
	--privileged \
	$(DOCKER_IMAGE)
