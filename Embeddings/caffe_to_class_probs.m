function class_probs = caffe_to_class_probs(caffe_probs)
persistent synsets
if ~exist('synsets','var')||isempty(synsets)
    load('meta10K.mat','synsets')
end
class_probs = get_all_probs(caffe_probs,synsets);