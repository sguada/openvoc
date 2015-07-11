function fileLines=tokenize(filename)
[status,output] = system(['sed -f tokenizer.sed ' filename]);
if status
    error('Error tokenizing inputFile')
else
    fileLines = textscan(output, '%s', 'delimiter', '\n', 'bufsize', 100000);
end
fileLines = fileLines{1};
end