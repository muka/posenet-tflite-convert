#!/usr/bin/env python
#
# Test Posenet model with custom decoding
# ----------------------------------------------------------------------------------------------------------------------
import cv2
import numpy as np
from edgetpu.basic.basic_engine import BasicEngine
from edgetpu import __version__ as edgetpu_version
from posenet.decode_multi import decode_multiple_poses

TFLITE_MODEL = 'posenet_mobilenet_v1_075_353_481_quant_decoder_edgetpu'

MODEL = "/data/%s.updated.tflite" % TFLITE_MODEL
OUTPUT_STRIDE = 16
NUM_KEYPOINTS = 17


def extract_outputs(outputs, engine):
    """Extract heatmaps, offsets, and displacement vectors"""

    # Input image and heatmap dimensions
    _, img_h, img_w, channels = engine.get_input_tensor_shape()
    height = int(1 + (img_w - 1) / OUTPUT_STRIDE)
    width = int(1 + (img_h - 1) / OUTPUT_STRIDE)

    # Reshape output tensors
    out_sz = engine.get_all_output_tensors_sizes()


    # Heatmaps
    ofs = 0
    ofs0 = int(ofs + out_sz[0])
    heatmaps = outputs[ofs:ofs0].reshape(height, width, NUM_KEYPOINTS)
    ofs += int(out_sz[0])

    # Offsets - [height, width, 2, 17]
    ofs1 = int(ofs + out_sz[1])
    offsets = outputs[ofs:ofs1].reshape(height, width, NUM_KEYPOINTS * 2)
    ofs += int(out_sz[1])

    # Displacement vectors (FWD, BWD): size [height, width, 4, 16], columns [fwd_i, fwd_j, bwd_i, bwd_j]
    ofs2 = int(ofs + out_sz[2])
    raw_dsp = outputs[ofs:ofs2].reshape(height, width, 4, -1)
    fwd = raw_dsp[:, :, 0:2, :]
    bwd = raw_dsp[:, :, 2:4, :]

    return {
        # apply sigmoid function to heatmaps
        'heatmaps': 1. / (1. + np.exp(-heatmaps)),
        'offsets': offsets,
        'displacements_fwd': fwd,
        'displacements_bwd': bwd
    }


# ----------------------------------------------------------------------------------------------------------------------
# Testing
# ----------------------------------------------------------------------------------------------------------------------
INPUT_IMG = '/test.jpg'

def main():
    # Read input image
    frame = cv2.imread(INPUT_IMG)
    frame = cv2.resize(frame, (481, 353))
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Instantiate inference engine
    engine = BasicEngine(MODEL)
    inference_time, output = engine.run_inference(frame.flatten())
    print('Done, inference time: %d msec, output shape: %s' %
          (inference_time, output.shape))

    # Decode pose
    out = extract_outputs(output, engine)
    pose_scores, keypoint_scores, keypoint_coords = decode_multiple_poses(
        out['heatmaps'],
        out['offsets'],
        out['displacements_fwd'],
        out['displacements_bwd'],
        OUTPUT_STRIDE,
        max_pose_detections=10, score_threshold=0.5, nms_radius=20, min_pose_score=0.1
    )
    print('pose_scores: %s' % str(pose_scores))



if __name__ == '__main__':

    print('edgetpu_version:' + edgetpu_version)
    engine = BasicEngine(MODEL)
    print('Input shape:', engine.get_input_tensor_shape())
    print('Output sizes:', engine.get_all_output_tensors_sizes())

    main()
