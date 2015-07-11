function words = tokenize(sentence,lowercase,keep_punctuation)
if nargin < 3
    keep_punctuation = true;
end
if nargin < 2
    lowercase = true;
end
if lowercase
    % Lower case of sentence
    sentence = lower(sentence);
end
% Separate ,.";()[]?! from words
if keep_punctuation
    sentence = regexprep(sentence,'[\.,;:@#$%&"\(\)\[\]?!{}<>-\/]',' $0 ');
else
    sentence = regexprep(sentence,'[\.,;:@#$%&"\(\)\[\]?!{}<>-\/]',' ');
end
% Separate cannot to can not
sentence = regexprep(sentence,'cannot', 'can not');
% Fix can't to can not
sentence = regexprep(sentence,'can''t', 'can not');
% Separate 'somthing from word'something
sentence = regexprep(sentence,'''\w+', ' $0');
% Join fix don 't to do n't
sentence = regexprep(sentence,'n ''t', ' n''t');
% Remove extra spaces
sentence = regexprep(sentence,'\s+',' ');
% Remove spaces at the begining or end
sentence = strtrim(sentence);
% Split it words
words = regexp(sentence,'\s+','split');
end