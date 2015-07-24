function open_vocab_demo(test_case)
persistent rcnn_model
if isempty(rcnn_model)
    load('models/caffe_dda_imagenet7k_200.model.mat');
end

crops_dir = 'crops';
recompute = false;
if nargin < 1
    test_case = listdlg('PromptString','Select an image:','SelectionMode',...
        'single','ListString',...
        {'pr2.jpg','table_top1.png','IMG_20131031_130838.jpg'})
end
switch test_case
    case 1
        image_name = 'pr2.jpg';
    case 2
        image_name = 'table_top1.png';
    case 3
        image_name = 'IMG_20131031_130838.jpg';
end
image_file = fullfile('scenes',image_name);
[~,imname,~] = fileparts(image_name);
[bbox, cats_names, top_scores] = detect10k_demo(rcnn_model,image_file,recompute);
top_probs = softmax(double(top_scores));
im = imread(image_file);
ti = tic;
fprintf('Croppig Windows... ')
im_crops = create_crops(im,bbox);
print_crops(imname,im_crops);
if feature('ShowFigureWindows')
    figure(3)
    visualize_crops(im_crops,cats_names, bbox(:,end));
    print(gcf,'-dpdf',['figures/' imname '_category']);
    drawnow
    pause(1)
end
crops_names = save_crops(im_crops,image_name,crops_dir,recompute);
fprintf('done (in %.3fs)\n',toc(ti))
%%

ti = tic;
fprintf('Google Image Search... ')
map_crops_giss=giss_wrap(crops_names,crops_dir,recompute);
insts_names = extract_field_giss(map_crops_giss,crops_names,'bestguess');
fprintf('done (in %.3fs)\n',toc(ti))

if feature('ShowFigureWindows')
    figure(4)
    visualize_crops(im_crops,insts_names);
    print(gcf,'-dpdf',['figures/' imname '_instance']);
    %print_crops([imname '_instance'],im_crops,insts_names);
    drawnow
    pause(1)
end

for iter=1:3
    if feature('ShowFigureWindows')
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        query = inputdlg('Please, bring me the ... ','Query',1,{''},options);
        if isempty(query)
            break;
        else
            query = query{1};
        end
    else
        query = input('Please, bring me the ... ','s');
    end
    
    % Rank candidates using Category Recognition
    embedder = Synset_Embedding.instance();
    emb_classes = embedder.words_embedding(rcnn_model.classes);
    
    synsets_probs = top_probs*emb_classes;
    
    category_kernel = eval_embedding(query, synsets_probs);
    figure(5)
    title(['Please bring me the ' query],'FontSize',14)
    visualize_crops(im_crops,cats_names,category_kernel)
    print(gcf,'-dpdf',['figures/' imname '_' query '_category_ranking']);
    %print_crops([imname '_' query '_category_ranking'],im_crops,cats_names,category_kernel);
    pause(1)
    
    % Rank candidates using Instance Matching
    instance_responses = extract_field_giss(map_crops_giss,crops_names,'bestguess');
    instance_kernel = sentence_tolist_similarity(query,instance_responses)';
    figure(6)
    visualize_crops(im_crops,insts_names,instance_kernel)
    print(gcf,'-dpdf',['figures/' imname '_' query '_instance_ranking']);
    %print_crops([imname '_' query '_instance_ranking'],im_crops,insts_names,instance_kernel);
    drawnow
    pause(1)
    
    
    % Rank candidates using Cascade
    alpha = 0.9;
    combined_kernels = instance_kernel*alpha+category_kernel*(1-alpha);
    figure(7)
    comb_names = cats_names;
    for i=1:length(comb_names)
        if instance_kernel(i)*alpha > category_kernel(i)*(1-alpha)
           comb_names{i} = insts_names{i};
        else
           comb_names{i} = cats_names{i};
        end
    end
    visualize_crops(im_crops,comb_names,combined_kernels)
    print(gcf,'-dpdf',['figures/' imname '_' query '_combined_ranking']);
%    print_crops([imname '_' query '_combined_ranking'],im_crops,comb_names,combined_kernels);

    pause(2)
    % Freebase expansion
    % map_query_fqe = fqe_wrap(image_name,{query});
    % sentence_tolist_similarity(map_query_fqe(image_name),instance_responses)';
    %
    % map_insts_names_fqe = fqe_wrap(image_name,insts_names);
    %
    % instance_responses_fqe = map_insts_names_fqe(image_name);
    % sentence_tolist_similarity(map_query_fqe(image_name),instance_responses_fqe)';
    
    
end


