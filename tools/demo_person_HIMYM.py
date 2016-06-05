#!/usr/bin/env python

# --------------------------------------------------------
# Faster R-CNN
# Copyright (c) 2015 Microsoft
# Licensed under The MIT License [see LICENSE for details]
# Written by Ross Girshick
# --------------------------------------------------------

"""
Demo script showing detections in sample images.

See README.md for installation instructions before running.
"""

import _init_paths
from fast_rcnn.config import cfg
from fast_rcnn.test import im_detect
from fast_rcnn.nms_wrapper import nms
from utils.timer import Timer
import matplotlib.pyplot as plt
import numpy as np
import scipy.io as sio
import caffe, os, sys, cv2
import argparse

CLASSES = ('__background__',
           'aeroplane', 'bicycle', 'bird', 'boat',
           'bottle', 'bus', 'car', 'cat', 'chair',
           'cow', 'diningtable', 'dog', 'horse',
           'motorbike', 'person', 'pottedplant',
           'sheep', 'sofa', 'train', 'tvmonitor')

NETS = {'vgg16': ('VGG16',
                  'VGG16_faster_rcnn_final.caffemodel'),
        'zf': ('ZF',
                  'ZF_faster_rcnn_final.caffemodel')}

detclass = ('person')


def vis_detections(im, class_name, dets, thresh=0.5):
    """Draw detected bounding boxes."""
    inds = np.where(dets[:, -1] >= thresh)[0]
    if len(inds) == 0:
        return

    im = im[:, :, (2, 1, 0)]
    fig, ax = plt.subplots(figsize=(12, 12))
    ax.imshow(im, aspect='equal')
    for i in inds:
        bbox = dets[i, :4]
        score = dets[i, -1]

        ax.add_patch(
            plt.Rectangle((bbox[0], bbox[1]),
                          bbox[2] - bbox[0],
                          bbox[3] - bbox[1], fill=False,
                          edgecolor='red', linewidth=3.5)
            )
        ax.text(bbox[0], bbox[1] - 2,
                '{:s} {:.3f}'.format(class_name, score),
                bbox=dict(facecolor='blue', alpha=0.5),
                fontsize=14, color='white')

    ax.set_title(('{} detections with '
                  'p({} | box) >= {:.1f}').format(class_name, class_name,
                                                  thresh),
                  fontsize=14)
    plt.axis('off')
    plt.tight_layout()
    plt.draw()

def demo(net, image_name, classes, savefile):
    """Detect object classes in an image using pre-computed object proposals."""

    # Load the demo image
    im_file = os.path.join(cfg.DATA_DIR, 'demo', image_name)
    im = cv2.imread(im_file)

    # Detect all object classes and regress object bounds
    timer = Timer()
    timer.tic()
    scores, boxes = im_detect(net, im)
    timer.toc()
    #print ('Detection took {:.3f}s for ''{:d} object proposals').format(timer.total_time, boxes.shape[0])

    fid = open(savefile,'w')


    # Visualize detections for each class
    CONF_THRESH = 0.8
    NMS_THRESH = 0.3
    cls = 'person'
    cls_ind = 15 # CLASSES.index(cls)
    cls_boxes = boxes[:, 4*cls_ind:4*(cls_ind + 1)]
    cls_scores = scores[:, cls_ind]
    dets = np.hstack((cls_boxes,
                      cls_scores[:, np.newaxis])).astype(np.float32)
    keep = nms(dets, NMS_THRESH)
    dets = dets[keep, :]
    inds = np.where(dets[:, -1] >= CONF_THRESH)[0]
    for i in inds:
        bbox = dets[i, :4]
        score = dets[i, -1]
        fid.write('{0:.3f}'.format(score))
        for j in range(4):
            fid.write(' ')
            fid.write('{0:.3f}'.format(bbox[j]))
        fid.write('\n')

    # vis_detections(im, cls, dets, thresh=CONF_THRESH)

    fid.close()
    


def parse_args():
    """Parse input arguments."""
    parser = argparse.ArgumentParser(description='Faster R-CNN demo')
    parser.add_argument('--gpu', dest='gpu_id', help='GPU device id to use [0]',
                        default=0, type=int)
    parser.add_argument('--cpu', dest='cpu_mode',
                        help='Use CPU mode (overrides --gpu)',
                        action='store_true')
    parser.add_argument('--net', dest='demo_net', help='Network to use [vgg16]',
                        choices=NETS.keys(), default='vgg16')

    args = parser.parse_args()

    return args

if __name__ == '__main__':
    cfg.TEST.HAS_RPN = True  # Use RPN for proposals

    args = parse_args()

    prototxt = os.path.join(cfg.MODELS_DIR, NETS[args.demo_net][0],
                            'faster_rcnn_alt_opt', 'faster_rcnn_test.pt')
    caffemodel = os.path.join(cfg.DATA_DIR, 'faster_rcnn_models',
                              NETS[args.demo_net][1])

    if not os.path.isfile(caffemodel):
        raise IOError(('{:s} not found.\nDid you run ./data/script/'
                       'fetch_faster_rcnn_models.sh?').format(caffemodel))

    if args.cpu_mode:
        caffe.set_mode_cpu()
    else:
        caffe.set_mode_gpu()
        caffe.set_device(args.gpu_id)
        cfg.GPU_ID = args.gpu_id
    net = caffe.Net(prototxt, caffemodel, caffe.TEST)

    print '\n\nLoaded network {:s}'.format(caffemodel)

    # Warmup on a dummy image
    im = 128 * np.ones((300, 500, 3), dtype=np.uint8)
    for i in xrange(2):
        _, _= im_detect(net, im)

    # detection on HIMYM trajectories
    # detlist = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/detlist.txt' 
    # jpgdir  = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/frames_prune/'
    # savedir = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/det_result_txt/'
    # samplefolder = './S01/E0001.mkv/00000007/'

    # detection on HIMYM matches
    detlist = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/matches/002_HIMYMData_clust50.h5.imlist' 
    jpgdir  = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/matches/cpframes/'
    savedir = '/nfs/ladoga_no_backups/users/xiaolonw/affordance/matches/det_result_txt/'
    samplefolder = './S02/E0019.mkv/'

    samplelen = len(samplefolder)

    with open(detlist) as f:
        im_names = [x.strip() for x in f.readlines()]
    listlen = len(im_names)


    for idx in range(listlen): # range(listlen):
        if idx % 100 == 0:
            print(idx)
        im_name = im_names[idx]
        im_folder = im_name[0:samplelen] 
        im_folder = savedir + '/' + im_folder + '/'
        if os.path.isdir(im_folder) == False:
            os.makedirs(im_folder)
        txt_name = im_name.replace('.jpg', '.txt')
        savefile = savedir + txt_name 
        im_name2 = jpgdir + im_name 
        # print '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        # print 'Demo for data/demo/{}'.format(im_name)
        demo(net, im_name2, detclass, savefile)


    # plt.show()



