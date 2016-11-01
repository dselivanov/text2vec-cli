#!/usr/bin/env Rscript --vanilla
#------------------------------------------------

source("common/common.R")
input_cmd_args = commandArgs(trailingOnly = TRUE)

DEFAULT_INPUT_COOCCURENCE_FILE_NAME = "tcm.rds"
DEFAULT_OUTPUT_FILE_NAME = "word_vectors.csv"
DEFAULT_WORD_VECTOR_SIZE = 50L
DEFAULT_N_ITER = 10L
# in most cases need to adjust this parameter
DEFAULT_X_MAX = 10L
# L1 regularization parameter
# setting to small values 1e-4 ... 1e-5 usually helps on word analogy task
# higly recommend to try different values and check how they improve dowstream tasks
DEFAULT_LAMBDA = 0
# check improvement of the cost cost function minimization between iterations for early stopping
DEFAULT_CONVERGENCE_TOLERANCE = 0.01
# number of digits to keep when writing word vectors to text file
DEFAULT_ROUND_DIGITS = 6
#------------------------------------------------
# don'r recomment to adjust these arguments
#------------------------------------------------
DEFAULT_CLIP_GRADIENT_COST = 10
DEFAULT_ALPHA = 0.75
DEFAULT_INITIAL_LEARNING_RATE = 0.2

args_list_template = list("cooccurences_file" = DEFAULT_INPUT_COOCCURENCE_FILE_NAME, 
                          "word_vectors_size" = DEFAULT_WORD_VECTOR_SIZE,
                          "iter" = DEFAULT_N_ITER, 
                          "x_max" = DEFAULT_X_MAX, 
                          "learning_rate" = DEFAULT_INITIAL_LEARNING_RATE, 
                          "lambda" = DEFAULT_LAMBDA, 
                          "clip_gradients" = DEFAULT_CLIP_GRADIENT_COST, 
                          "alpha" = DEFAULT_ALPHA, 
                          "convergence_tol" = DEFAULT_CONVERGENCE_TOLERANCE)
args_list = parse_cmd_args(input_cmd_args, args_list_template)
numeric_params = c("learning_rate", "iter", "x_max", "lambda", "clip_gradients", "alpha", "word_vectors_size")

for (param  in numeric_params)
  args_list[[param]] = as.numeric(args_list[[param]])

log_info(paste0("reading co-occurence matrix from ", args_list[["cooccurences_file"]]))
tcm = readRDS(args_list[['cooccurences_file']])
  
glove = GloVe$new(word_vectors_size = args_list[['word_vectors_size']], 
                  vocabulary = rownames(tcm),
                  x_max = args_list[['x_max']], 
                  learning_rate = args_list[['learning_rate']], 
                  max_cost = args_list[["clip_gradients"]],
                  alpha = args_list[["alpha"]],
                  lambda = args_list[["lambda"]])
glove$verbose = TRUE

glove_params_string = unlist(args_list)
glove_params_string = paste(names(glove_params_string), glove_params_string, collapse = "; ", sep = "=")
log_info(paste0("training GloVe algorithm with following parameters:\n", glove_params_string))

glove$fit(tcm, args_list[['iter']], convergence_tol = args_list[["convergence_tol"]])
log_info("getting word vectors from model")
wv = glove$get_word_vectors()

log_info("saveing word vectors in binary form to 'word_vectors.rds'")
saveRDS(wv, file = "word_vectors.rds", compress = FALSE)

# disable writing in scientific notation
wv = round(wv, DEFAULT_ROUND_DIGITS)
options(scipen = 1000)

log_info(paste0("writing word vectors to ", DEFAULT_OUTPUT_FILE_NAME))
write.table(x = wv, 
            file = DEFAULT_OUTPUT_FILE_NAME, 
            append = FALSE, quote = FALSE, 
            sep = " ", col.names = FALSE)
log_info("successfully saved")