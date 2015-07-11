% Make sure caffe_dda_imagenet7k_200.model has been downloaded 
if ~exist('./models/caffe_dda_imagenet7k_200.model','file')
  fprintf('Warning: you will need the caffe_dda_imagenet7k_200.model .\n');
  fprintf('Press any key to download it (runs ./models/get_caffe_lsda_model.sh)> ');
  pause;
  cd('models')
  system('./get_caffe_lsda_model.sh');
  cd('..')
end
% Install Selective Search if needed
if exist('third_party/SelectiveSearchCodeIJCV','dir')
  addpath('third_party/SelectiveSearchCodeIJCV');
  addpath('third_party/SelectiveSearchCodeIJCV/Dependencies');
else
  fprintf('Warning: you will need the selective search IJCV code.\n');
  fprintf('Press any key to download it (runs ./third_party/fetch_selective_search.sh)> ');
  pause;
  system('./third_party/fetch_selective_search.sh');
  addpath('third_party/SelectiveSearchCodeIJCV');
  addpath('third_party/SelectiveSearchCodeIJCV/Dependencies');
end
if exist('./third_party/huang_wordemb/pwmetric','dir')
  addpath('./third_party/huang_wordemb/pwmetric');
  addpath('./third_party/huang_wordemb');
else
  fprintf('Warning: you will need the pwmetric code.\n');
  fprintf('Press any key to download it (runs ./third_party/fetch_huang_word_representation.sh)> ');
  pause;
  cd('third_party')
  system('./fetch_huang_word_representation.sh');
  cd('..')
  addpath('./third_party/huang_wordemb');
  addpath('./third_party/huang_wordemb/pwmetric');
end

% Check Caffe is installed
if exist('external/caffe/matlab/caffe','dir')
  addpath('external/caffe/matlab/caffe');
else
  warning('Please install Caffe in ./external/caffe');
end

% Adding folders to path
addpath('demo');
addpath('Embeddings');
addpath('Instances');
addpath('Maps');

addpath('utils');
addpath('third_party/jsonlab/')

if ~exist('./models/caffe_dda_imagenet7k_200.model.mat','file')
  fprintf('Warning: you will need the models/caffe_dda_imagenet7k_200.model.mat .\n');
  fprintf('Press any key to create it and save it> ');
  pause;
  rcnn_model = rcnn_get_model;
  save('./models/caffe_dda_imagenet7k_200.model.mat','rcnn_model','-v7.3');
end
