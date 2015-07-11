function visualize_crops(crops, names, confidences)
h = gcf;
axis image;
axis off;
set(h, 'Color', 'white');
num_crops = numel(crops);
if exist('confidences','var') && ~isempty(confidences)
	[~,order] = sort(confidences,'descend');
else
	order = 1:num_crops;
end

if nargin < 2
    names = num2cell((1:num_crops)');
end
for i=1:num_crops
    subplot(ceil(num_crops/4),4,i)
    ind = order(i);
    imshow(crops{ind})
    if exist('confidences','var') && ~isempty(confidences)
        if isnumeric(names{ind})
            names{ind} = num2str(names{ind});
        end
        title(sprintf('%s: %.2f',names{ind}(1:min(20,end)),confidences(ind)));
    else
        title(names{ind});
    end
end