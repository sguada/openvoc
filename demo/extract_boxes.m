function boxes = extract_boxes(im, numbox)
th = tic;
fprintf('Extract Region Proposals using Selective Search...');
fast_mode = true;
im_width = 500;
boxes = selective_search_boxes(im, fast_mode, im_width);
boxes = boxes(:, [2 1 4 3]); %[y1 x1 y2 x2] to [x1 y1 x2 y2]

% Subsample boxes through kmeans clustering,
if exist('numbox','var')
    [~,boxes,~] = kmeans(boxes, numbox, 'Distance', 'sqeuclid');
end
% Subsample by random selection
% rind = randperm(length(boxes),min(numbox, length(boxes)));
% boxes = boxes(rind,:);

fprintf(' done (in %.3fs)\n', toc(th));
end