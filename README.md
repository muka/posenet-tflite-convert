# posenet-tflite-convert


From https://github.com/google-coral/edgetpu/issues/127


Okay, so based on this documentation the tflite's python API does allows you to have multiple delegates, I just tested and this works:

```
import tflite_runtime.interpreter as tflite
tpu = tflite.load_delegate('libedgetpu.so.1')
posenet = tflite.load_delegate('posenet_decoder.so')
interpreter = tflite.Interpreter('posenet_mobilenet_v1_075_353_481_quant_decoder.tflite'), 
                                               experimental_delegates=[tpu, posenet])

```                  

I guess you can refer to #86 for usage instructions. Anyhow, you can get the posenet_decoder.so by building it with
`bazel build src/cpp/posenet/posenet_decoder.so` and it'll be in the bazel-bin/* directory.
When running, make sure to point `LD_LIBRARY_PATH=path/to/posenet_decoder.so` so that tflite can find it!

Closing for now, feel free to ask more questions if need more details :)