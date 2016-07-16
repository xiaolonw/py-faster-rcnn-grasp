#!/bin/bash
# Usage:
# ./experiments/scripts/faster_rcnn_end2end.sh GPU NET DATASET [options args to {train,test}_net.py]
# DATASET is either pascal_voc or coco.
#
# Example:
# ./experiments/scripts/faster_rcnn_end2end.sh 0 VGG_CNN_M_1024 pascal_voc \
#   --set EXP_DIR foobar RNG_SEED 42 TRAIN.SCALES "[400, 500, 600, 700]"

set -x
set -e

export PYTHONUNBUFFERED="True"

GPU_ID=$1
NET=$2
NET_lc=${NET,,}
DATASET=$3

array=( $@ )
len=${#array[@]}
EXTRA_ARGS=${array[@]:3:$len}
EXTRA_ARGS_SLUG=${EXTRA_ARGS// /_}

case $DATASET in
  nyud2_voc)
    TRAIN_IMDB="nyud2_images_2015_trainval"
    TEST_IMDB="nyud2_images_2015_test"
    PT_DIR="nyud2_voc"
    ITERS=70000
    ;;
  nyud3_voc)
    TRAIN_IMDB="nyud3_images_2015_trainval"
    TEST_IMDB="nyud3_images_2015_test"
    PT_DIR="nyud3_voc"
    ITERS=90000
    ;;
  pascal_voc)
    TRAIN_IMDB="voc_2007_trainval"
    TEST_IMDB="voc_2007_test"
    PT_DIR="pascal_voc"
    ITERS=70000
    ;;
  coco)
    # This is a very long and slow training schedule
    # You can probably use fewer iterations and reduce the
    # time to the LR drop (set in the solver to 350,000 iterations).
    TRAIN_IMDB="coco_2014_train"
    TEST_IMDB="coco_2014_minival"
    PT_DIR="coco"
    ITERS=490000
    ;;
  *)
    echo "No dataset given"
    exit
    ;;
esac

set +x
NET_FINAL='/nfs.yoda/xiaolonw/faster_rcnn/xiaolonw/py-faster-rcnn2/output/faster_rcnn_end2end_2/nyud3_images_2015_trainval/vgg_cnn_m_1024_faster_rcnn_iter_90000.caffemodel'
set -x

time ./tools/test_net.py --gpu ${GPU_ID} \
  --def models/${PT_DIR}/${NET}/faster_rcnn_end2end/test.prototxt \
  --net ${NET_FINAL} \
  --imdb ${TEST_IMDB} \
  --cfg experiments/cfgs/faster_rcnn_end2end_2.yml \
  ${EXTRA_ARGS}
