function crop_names=save_crops(crops, basename, dirname, recompute)
random_name = false;
if nargin < 4
    recompute = 0;
end
num_crops = numel(crops);
if nargin < 3
    dirname = 'crops';
end
if ~exist(dirname,'dir')
    mkdir(dirname);
end
if nargin < 2
    basename = 'crop';
end
parfor i=1:num_crops
    if random_name
        crop_names{i} = sprintf('%s_%d_%d.png',basename,i,randi(1e6));
    else
        crop_names{i} = sprintf('%s_%d.png',basename,i);
    end
    if ~exist(fullfile(dirname,crop_names{i}),'file') || recompute
        imwrite(crops{i},fullfile(dirname,crop_names{i}),'PNG');
    end
end