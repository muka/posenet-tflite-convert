# posenet-tflite-convert

This code is a PoC based on the great write up https://towardsdatascience.com/optimizing-pose-estimation-on-the-coral-edge-tpu-d331c63cfed

* Requires a Coral TPU to run

## Setup 

`make clean download convert` 


## Docker build & run 

1. Build image `make docker/build`
2. run with mobilenet `make mobilenet/run`
3. run with resnet `make resnet/run` (not working, WIP)