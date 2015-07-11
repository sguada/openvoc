function res=tag_text(input,outputfile)
current_dir = pwd;
if iscell(input)
    % Assume that input is a cell of strings
    print_cell(input,'temp/input.txt','.\n');
    input = 'temp/input.txt';
else
    % Assume that the input is the name of a file
    assert(exist(input,'file')>0,'The file should exist');
end
cd 'third_party/stanford-postagger/'
[status,output] = system(['./stanford-postagger.sh ' fullfile(current_dir,input)]);

if status>0
    cd(current_dir)
    error(['Problem with stanford-postagger' output]);
else
    cd(current_dir)
    output = textscan(output,'%s','delimiter','\n');
    if nargin == 2
        print_cell(output{1},outputfile);
    end
    res.text = output{1};
    pairs = regexp(res.text,'(\w+)_(\w+)','tokens');
    for i=1:length(pairs)
        res.pairs{i,1} = cell2matcell(pairs{i}')';
    end
end
