function crops=create_crops(im,bboxes,padding)
if nargin < 3 
    padding = 0.05;
end
crops = cell(size(bboxes,1),1);
for i = 1:size(bboxes,1)
    width = bboxes(i,3)-bboxes(i,1);
    height = bboxes(i,4)-bboxes(i,2);
    x = bboxes(i,1)-width*padding;
    y = bboxes(i,2)-height*padding;
    crops{i} = imcrop(im,[x y ...
        width*(1+padding) height*(1+padding)]);
end