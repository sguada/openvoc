function examples = extract_examples(gloss)
    if length(gloss) > 1        
        examples = gloss(2:end-1);
    else
        examples = {};
    end