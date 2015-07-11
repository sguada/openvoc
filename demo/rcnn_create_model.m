function rcnn_model = rcnn_create_model(cnn_definition_file, cnn_binary_file, cache_name)
% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick, 
% Modified by Sergio Guadarrama
%
% This file is part of the R-CNN code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

if ~exist('cache_name', 'var') || isempty(cache_name)
    cache_name = 'none';
end

try
    % Very hacky but read batch_size and input_dim from the cnn_definition
    % It assumes that they are in order batch_size, channels, height, width
    definition=importdata(cnn_definition_file);
    % Check that we extract 4 numbers
    assert(size(definition.data,1)==4)
    % Check height = width
    assert(definition.data(3)==definition.data(4))
    cnn.batch_size = definition.data(1);
    cnn.input_size = definition.data(3);
catch
    % If it didn't work use defaults for Alexnet
    cnn.batch_size = 256;
    cnn.input_size = 227;
end

% init convnet
if exist(sprintf('%s.mat', cnn_binary_file),'file')
    load(sprintf('%s.mat', cnn_binary_file));
else
    assert(exist(cnn_binary_file, 'file')~=0,'Binary file does not exist');
    assert(exist(cnn_definition_file, 'file')~=0,'Definition file does not exist');
    cnn.binary_file = cnn_binary_file;
    cnn.definition_file = cnn_definition_file;
    cnn.init_key = -1;

    % load the ilsvrc image mean
    data_mean_file = './external/caffe/matlab/caffe/ilsvrc_2012_mean.mat';
    assert(exist(data_mean_file, 'file') ~= 0);
    ld = load(data_mean_file);
    image_mean = ld.image_mean; clear ld;
    off = floor((size(image_mean,1) - cnn.input_size)/2)+1;
    image_mean = image_mean(off:off+cnn.input_size-1, off:off+cnn.input_size-1, :);
    cnn.image_mean = image_mean;
end

% init empty detectors
detectors.W = [];
detectors.B = [];
detectors.crop_mode = 'warp';
detectors.crop_padding = 16;
detectors.nms_thresholds = [];

% rcnn model wraps the convnet and detectors
rcnn_model.cnn = cnn;
rcnn_model.cache_name = cache_name;
rcnn_model.detectors = detectors;
