#!/usr/bin/env sh
# This scripts downloads the caffe_dda_imagenet7k+200 model
# used for Large Scale Object Detection
# It was built combining 7404 Classfiers trained on Imagenet 2011 Leaf Categories
# and 200 Detectors trained on the ILSVRC'13 Imagenet Object Detection Challenge

MODEL=caffe_dda_imagenet7k_200.model
CHECKSUM=6a30463df22dae9af28ed6cd785c60e6

if [ -f $MODEL ]; then
  echo "Model already exists."
else
 echo "Downloading model..."
 wget --no-check-certificate https://www.dropbox.com/s/bcvabei6xxd481o/$MODEL;
fi
echo "Checking that md5 checksum is $CHECKSUM"
os=`uname -s`
if [ "$os" = "Linux" ]; then
  checksum=`md5sum $MODEL | awk '{ print $1 }'`
elif [ "$os" = "Darwin" ]; then
  checksum=`cat $MODEL | md5`
fi
if [ "$checksum" = "$CHECKSUM" ]; then
  echo "Model checksum is correct. No need to download."
  exit 0
else
  echo "Model checksum is incorrect."
  echo "Please remove '$MODEL' and download it again."
  exit 1
fi

echo "Done."
