function [top_boxes, cats_found, top_scores]=detect10k_demo(rcnn_model, imfile, recompute, outname)
th = tic;
% Read image
fprintf('Reading image... ');
im = imread(imfile);
fprintf('done (in %.3fs)\n',toc(th));

if ~exist('recompute','var')
    recompute = 0;
end

[~,imname,~] = fileparts(imfile);
% Get boxes
cached_boxes = fullfile('temp',[imname '_boxes.mat']);
if exist(cached_boxes,'file') && ~recompute
    fprintf('Loading pre-computed bboxes\n');
    boxes = load(cached_boxes);
    boxes = boxes.boxes;
else
    boxes = extract_boxes(im);
    save(cached_boxes,'boxes');
end

% Extract per region features and scores
cached_feat = fullfile('temp',[imname '_feat.mat']);
if exist(cached_feat,'file') && ~recompute
    fprintf('Loading pre-computed cnn features\n');
    feat = load(cached_feat);
    feat = feat.feat;
else
    feat = per_region_features(rcnn_model, im, boxes);
    save(cached_feat,'feat');
end
th1 = tic;
fprintf('Scoring windows... ')
scores = bsxfun(@plus, feat*rcnn_model.detectors.W, rcnn_model.detectors.B);
fprintf('done (in %.3fs)\n',toc(th1))
% Prune the boxes based on scoresegprs
[top_boxes, cats_ids] = prune_boxes(boxes, scores);
cats_found = rcnn_model.classes(cats_ids);

d = pdist2(top_boxes(:,1:4),boxes);
[~,keep] = min(d,[],2);
top_scores = scores(keep,:);

figure(1)
clf
showboxes(im,top_boxes)
title('Candidate Windows', 'FontSize', 14, 'FontWeight','bold');
drawnow
print(gcf,'-dpdf',['figures/' imname '_region.pdf']);
pause(1)

fprintf('\n Final time: %.3fs\n', toc(th));
% Show detections
m = min(length(cats_ids), 16);
top_boxes = top_boxes(1:m,:);
cats_found = cats_found(1:m);
cats_ids = cats_ids(1:m);
top_scores = top_scores(1:m,:);

figure(2)
clf
if exist('outname', 'var')
    showdets(im, top_boxes(1:m,:), cats_found(1:m), cats_ids(1:m), outname);
else
    showdets(im, top_boxes(1:m,:), cats_found(1:m), cats_ids(1:m));
end
title('LSDA CNN-7k Category Recognition', 'FontSize', 14, 'FontWeight','bold');
drawnow
print(gcf,'-dpdf',['figures/' imname '_region_category.pdf']);
pause(1)
end

function [top_boxes, cats_ids] = prune_boxes(boxes, scores)

th = tic;
fprintf('Prune boxes...');

% find scores > 0
[ind_c, c] = find(scores > 0);
nz_classes = unique(c);
top_boxes = zeros(50,5); % preallocate some space
cats_ids = zeros(50,1);
index = 1;
thresh = 0.1; % percat threshold for nms
for i = 1:length(nz_classes)
    ind = c==nz_classes(i);
    scored_boxes = cat(2, boxes(ind_c(ind),:), scores(ind_c(ind), nz_classes(i)));
    keep = nms(scored_boxes, thresh);
    indices = index:index+length(keep)-1;
    top_boxes(indices,:) = scored_boxes(keep,:);
    cats_ids(indices) = nz_classes(i)*ones(length(keep),1);
    index = index + length(keep);
end
top_boxes = top_boxes(1:index-1,:);
cats_ids = cats_ids(1:index-1);

keep = nms(top_boxes,0.4);
cats_ids = cats_ids(keep);
top_boxes = top_boxes(keep,:);

ind = find(top_boxes(:,5) >= 1.0);
if length(ind) >= 2
    top_boxes = top_boxes(ind,:);
    cats_ids = cats_ids(ind);
end
fprintf(' done (ind %.3fs)\n', toc(th));
end



function feat = per_region_features(rcnn_model, im, boxes)
fprintf('Extracting CNN features from regions...');
th = tic();
% HACK: compute to pool5 only and then do the rest on the fly
rcnn_pool5 = rcnn_model;
rcnn_pool5.training_opts.layer = 5;
rcnn_pool5.cnn.definition_file ='models-defs/caffe_batch_256_output_pool5.prototxt';
rcnn_pool5 = rcnn_load_model(rcnn_pool5,1,1);
tt = tic;
feat = rcnn_features(im, boxes, rcnn_pool5);
fprintf('ft comp in %.3f\n', toc(tt));
feat = rcnn_pool5_to_fcX(feat, 8, rcnn_model);
ft_norm = rcnn_model.training_opts.feat_norm_mean;
feat = rcnn_scale_features(feat, ft_norm);
fprintf('done (in %.3fs).\n', toc(th));
end
