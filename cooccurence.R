#!/usr/bin/env Rscript
#------------------------------------------------
source("common/common.R")
DEFAULT_VOCAB_MIN_COUNT = 5L
DEFAULT_WINDOW_SIZE = 5L
DEFAULT_INPUT_VOCABULARY_FILE_NAME = "vocab.rds"
DEFAULT_OUTPUT_COOCCURENCE_FILE_NAME = "tcm.rds"

input_cmd_args = commandArgs(trailingOnly = TRUE)

args_list_template = list("files" = NULL, 
                          "dir" = NULL, 
                          "vocab_file" = DEFAULT_INPUT_VOCABULARY_FILE_NAME, 
                          "vocab_min_count" = DEFAULT_VOCAB_MIN_COUNT, 
                          "window_size" = DEFAULT_WINDOW_SIZE, 
                          "cooccurences_file" = DEFAULT_OUTPUT_COOCCURENCE_FILE_NAME)

args_list = parse_cmd_args(input_cmd_args, args_list_template)
# add files from files argument
fls = parse_files(args_list[["files"]])
# add files from directory argument
fls = c(fls, parse_dir(args_list[["dir"]]))
# check that we have data
if(is.null(fls)) stop("please provide input data as 'files=' or 'dir=' argument")

# read vocabulary
log_info(paste0("reading vocabulary from ", args_list[["vocab_file"]]))
vocab_original = readRDS(args_list[["vocab_file"]])
log_info(paste0("vocabulary read - ", nrow(vocab_original$vocab), " unique terms"))

args_list[["vocab_min_count"]] = as.integer(args_list[["vocab_min_count"]])
log_info(paste0("pruning vocabulary with vocab_min_count = ", args_list[["vocab_min_count"]]))
vocab = prune_vocabulary(vocab_original, term_count_min = args_list[["vocab_min_count"]])
log_info(paste0("pruned vocabulary contains ", nrow(vocab$vocab), " unique terms"))
# create iterator over files
it_files = ifiles(fls, reader = readr::read_lines)
# create iterator over tokens
it_token = itoken(it_files, progressbar = TRUE)
# create tcm
args_list[["window_size"]] = as.integer(args_list[["window_size"]])
vectorizer = vocab_vectorizer(vocab, grow_dtm = FALSE, skip_grams_window = args_list[["window_size"]])
log_info(paste0("creating co-occurence matrix with window = ", args_list[["window_size"]]))
tcm = create_tcm(it_token, vectorizer)
cat("\n")
log_info(paste0("symmetric co-occurence matrix created: ", 2 * length(tcm@x), " non zero elements" ))
log_info(paste0("saving co-occurence matrix to ", args_list[["cooccurences_file"]]))
saveRDS(tcm, file = args_list[["cooccurences_file"]])
log_info("successfully saved")
