#!/usr/bin/env Rscript
#------------------------------------------------
source("common/common.R")
questions_path = "data/questions-words.txt"

# read word vectors in binary form
wv = readRDS("word_vectors.rds")
# parse questions
questions = prepare_analogy_questions(questions_path, vocab_terms = rownames(wv), verbose = T)
check_analogy_accuracy(questions_list = questions, m_word_vectors = wv, verbose = T)
