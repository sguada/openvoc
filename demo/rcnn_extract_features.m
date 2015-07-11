function feat = rcnn_extract_features(im, boxes, rcnn_model)
% [batches, batch_padding] = rcnn_extract_regions(im, boxes, rcnn_model)
%   Extract image regions and preprocess them for use in Caffe.
%   Output is a cell array of batches.
%   Each batch is a 4-D tensor formatted for input into Caffe:
%     - BGR channel order
%     - single precision
%     - mean subtracted
%     - dimensions from fastest to slowest: width, height, channel, batch_index
%
%   im is an image in RGB order as returned by imread
%   boxes are in [x1 y1 x2 y2] format with one box per row

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

% make sure that caffe has been initialized for this model
assert(caffe('is_initialized')==1)
if rcnn_model.cnn.init_key ~= caffe('get_init_key')
  warning('You probably need to call rcnn_load_model');
end
% convert image to BGR and single
im = single(im(:,:,[3 2 1]));
num_boxes = size(boxes, 1);
batch_size = rcnn_model.cnn.batch_size;
feat_size = size(rcnn_model.cnn.layers(end).weights{1},2);
num_batches = ceil(num_boxes / batch_size);

crop_mode = rcnn_model.detectors.crop_mode;
image_mean = rcnn_model.cnn.image_mean;
crop_size = size(image_mean,1);
crop_padding = rcnn_model.detectors.crop_padding;

feat = zeros(num_boxes, feat_size);
for batch = 1:num_batches
  batch_start = (batch-1)*batch_size+1;
  batch_end = min(num_boxes, batch_start+batch_size-1);
  current_batch_size = batch_end-batch_start+1;

  ims = zeros(crop_size, crop_size, 3, batch_size, 'single');
  parfor j = 1:batch_end-batch_start
    bbox = boxes(j+batch_start-1,:);
    crop = rcnn_im_crop(im, bbox, crop_mode, crop_size, ...
        crop_padding, image_mean);
    % swap dims 1 and 2 to make width the fastest dimension (for caffe)
    ims(:,:,:,j) = permute(crop, [2 1 3]);
  end
  f = caffe('forward', {ims});
  f = squeeze(f{1})';
  feat(batch_start:batch_end,:) = f(1:current_batch_size,:);
end

