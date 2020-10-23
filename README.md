# posenet on tflite CPU

A setup to test the approach described in https://github.com/google-coral/edgetpu/issues/127

```python
import tflite_runtime.interpreter as tflite
tpu = tflite.load_delegate('libedgetpu.so.1')
posenet = tflite.load_delegate('posenet_decoder.so')
interpreter = tflite.Interpreter('posenet_mobilenet_v1_075_353_481_quant_decoder.tflite'), 
                                               experimental_delegates=[tpu, posenet])

```                  

## Usage

1. download edgetpu repo and build bazel image

```sh
make setup
```

2. Compile 

```sh
make compile 
```

