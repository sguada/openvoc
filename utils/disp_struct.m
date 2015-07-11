function disp_struct(var)
%% It display the content of a struct.

assert(isstruct(var),'It needs to be a struct');

fields = fieldnames(var);

for f=1:numel(fields)
    fprintf('  %s: ',fields{f});
    fprintf('%s\n',sprint_var(var.(fields{f})));
end

function r=sprint_var(var)
if isnumeric(var)
    if isinteger(var)
        r = sprintf('%d',var);
    end
    if isfloat(var)
        r = sprintf('%f',var);
    end
elseif islogical(var)
    r = sprintf('%d',var);
elseif ischar(var)
    r = sprintf('''%s''',var);
elseif isstruct(var)
    r = sprintf('(struct)');
end