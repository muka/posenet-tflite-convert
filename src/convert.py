#!/usr/bin/python
import json
import os

TFLITE_MODEL = os.environ["TFLITE_MODEL"]

INPUT_MODEL = './data/%s.json' % TFLITE_MODEL
OUTPUT_MODEL_JSON = './data/%s.updated.json' % TFLITE_MODEL

# Load model
model = json.load(open(INPUT_MODEL))

# Remove operator 1 (custom decoding)
del model['operator_codes'][1]
del model['subgraphs'][0]['operators'][1]

# Keep only tensors and buffers 0, 1, 2, 3
model['subgraphs'][0]['tensors'] = model['subgraphs'][0]['tensors'][0:4]
model['buffers'] = model['buffers'][0:4]

# Set output to match buffers [0, 1, 2]
model['subgraphs'][0]['outputs'] = [0, 1, 2]

# Save model
with open(OUTPUT_MODEL_JSON, 'w') as fp:
   fp.write(json.dumps(model))
