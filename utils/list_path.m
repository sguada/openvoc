function res=list_path(root_to_path,filenames,outputfile)
options = ' -maxdepth 1 ';
name = [' -name ''' filenames ''''];
if nargin < 3
    [status,output] = system(['find ' root_to_path options name]);
    if status == 0
        if ~isempty(output)
            fileLines = textscan(output,'%s','delimiter','\n','BufSize',100000);
            res = fileLines{1};
        else
            res ={};
        end
    else
        warning(['Error reading the path:' output]);
        res = {};
    end
else    
    [status,output] = system(['find ' root_to_path options name ' > ' outputfile]);
    if status > 0
        error(['Error reading the path:' output]);
    end
end