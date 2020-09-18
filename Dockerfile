FROM python:3.7

RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt update -q && apt install -y libedgetpu1-std libgl1-mesa-glx python3-edgetpu

# tflite runtime for python 3.7
# See https://www.tensorflow.org/lite/guide/python for other python versions
RUN pip install --upgrade pip
RUN pip3 install https://dl.google.com/coral/python/tflite_runtime-2.1.0.post1-cp37-cp37m-linux_x86_64.whl
RUN pip3 install opencv-python scipy

ADD run.py /
ADD posenet /

ENV PYTHONPATH=$PYTHONPATH:/usr/lib/python3/dist-packages:/usr/local/python3.7/dist-packages

ENTRYPOINT [ "python3", "/run.py" ]