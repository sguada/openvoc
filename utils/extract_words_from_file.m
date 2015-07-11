function words = extract_words_from_file(filename)
lines = read_cell(filename);
words = tokenize(lines);
words = [words{:}];
end