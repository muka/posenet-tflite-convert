
TFLITE_MODEL_RESNET ?= posenet_resnet_50_416_288_16_quant_edgetpu_decoder
TFLITE_MODEL_MOBILENET ?= posenet_mobilenet_v1_075_353_481_quant_decoder_edgetpu

TFLITE_MODEL ?= $(TFLITE_MODEL_MOBILENET)

SCHEMA ?= /data/schema.fbs
MODEL ?= /data/$(TFLITE_MODEL).tflite
MODEL_UPDATE ?= /data/$(TFLITE_MODEL).updated.json
FLATC ?= docker run -v `pwd`/data:/data neomantra/flatbuffers flatc

DOCKER_IMAGE ?= opny/posenet-tpu

clean:
	rm -rf ./data

download:
	mkdir -p ./data
	cd data && wget https://github.com/google-coral/project-posenet/raw/master/models/mobilenet/$(TFLITE_MODEL_MOBILENET).tflite
	cd data && wget https://github.com/google-coral/project-posenet/raw/master/models/resnet/$(TFLITE_MODEL_RESNET).tflite
	# tflite schema
	wget https://github.com/tensorflow/tensorflow/raw/master/tensorflow/lite/schema/schema.fbs -O data/schema.fbs

model/convert: model/convert/json model/convert/update_model model/convert/tflite

#1 tflite -> json
model/convert/json:
	$(FLATC) -t --strict-json --defaults-json -o /data $(SCHEMA) -- $(MODEL)

#2 drop custom ops
model/convert/update_model:
	TFLITE_MODEL=$(TFLITE_MODEL) python3 src/convert.py

#3 json -> tflite
model/convert/tflite:
	$(FLATC) -c -b -o /data $(SCHEMA) $(MODEL_UPDATE)

docker/build:
	docker build . -t $(DOCKER_IMAGE)

docker/run:
	docker run --rm -it \
	-v `pwd`/data:/data \
	-v `pwd`/src:/src \
	-v /dev:/dev \
	-e TFLITE_MODEL=$(TFLITE_MODEL) \
	--privileged \
	$(DOCKER_IMAGE)


mobilenet/convert:
	TFLITE_MODEL=$(TFLITE_MODEL_MOBILENET) make model/convert

mobilenet/run:
	TFLITE_MODEL=$(TFLITE_MODEL_MOBILENET) make docker/run

resnet/convert:
	TFLITE_MODEL=$(TFLITE_MODEL_RESNET) make model/convert

resnet/run:
	TFLITE_MODEL=$(TFLITE_MODEL_RESNET) make docker/run

convert: resnet/convert mobilenet/convert