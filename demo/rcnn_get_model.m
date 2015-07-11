function rcnn_model = rcnn_get_model(varargin)
ip = inputParser;
ip.addParamValue('imdb',     struct(),      @isstruct);
ip.addParamValue('layer',           8,      @isscalar);
ip.addParamValue('crop_mode',       'warp', @isstr);
ip.addParamValue('crop_padding',    16,     @isscalar);
ip.addParamValue('net_file', ...
    './models/caffe_dda_imagenet7k_200.model', @isstr);
ip.addParamValue('net_def_file', ...
    './models-defs/caffe_dda_imagenet7k_200_deploy.prototxt', @isstr);
ip.addParamValue('class_names', ...
    './models-defs/dda_imagenet7k_200_class_names.txt', @isstr);

ip.addParamValue('detectors_bias', 0, @isscalar);
ip.addParamValue('detectors_pos_w', 1, @isscalar);
ip.addParamValue('detectors_neg_w', -1, @isscalar);
ip.addParamValue('detectors_others_w', 0, @isscalar);
ip.addParamValue('feat_norm_mean', 25.2841, @isscalar);
ip.addParamValue('sparsity', 0.5710, @isscalar);
ip.addParamValue('use_gpu', 1, @isscalar);
ip.addParamValue('device_id', 1, @isscalar);

ip.parse(varargin{:});
opts = ip.Results;
fprintf('rnn_get_model options\n');
disp_struct(opts)


rcnn_model = rcnn_create_model(opts.net_def_file, opts.net_file);
rcnn_model = rcnn_load_model(rcnn_model, opts.use_gpu, opts.device_id);

if exist(opts.class_names,'file')
    fid = fopen(opts.class_names);
    classes = textscan(fid, '%s', 'Delimiter', '\n');
else
    warning('Class_names doesn''t exits');
    classes = {''};
end

rcnn_model.classes = classes{1};
rcnn_model.detectors.crop_mode = opts.crop_mode;
rcnn_model.detectors.crop_padding = opts.crop_padding;
num_classes = size(rcnn_model.cnn.layers(end).weights{1},2)-1;
W =  opts.detectors_others_w*ones(num_classes+1,num_classes);
W(1,:) = opts.detectors_neg_w;
W(2:end,:) = opts.detectors_pos_w*eye(num_classes);
B = opts.detectors_bias*ones(1,num_classes);

rcnn_model.detectors.W = W;
rcnn_model.detectors.B = B;

% ------------------------------------------------------------------------
% Get the average norm of the features
if opts.feat_norm_mean == 0
    [opts.feat_norm_mean,~,opts.sparsity] = rcnn_feature_stats(opts.imdb, opts.layer, rcnn_model);
end
fprintf('average norm = %.3f\n', opts.feat_norm_mean);
fprintf('sparsity = %.3f\n',opts.sparsity);
rcnn_model.training_opts = opts;
% ------------------------------------------------------------------------

