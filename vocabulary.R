#!/usr/bin/env Rscript --vanilla
#------------------------------------------------
source("common/common.R")
input_cmd_args = commandArgs(trailingOnly = TRUE)
DEFAULT_OUT_VOCABULARY_FILENAME = "vocab.rds"

#------------------------------------------------
# parse commandline arguments
args_list_template = list("files" = NULL, 
                          "dir" = NULL, 
                          # "stopwords" = character(0), 
                          "vocab_file" = DEFAULT_OUT_VOCABULARY_FILENAME)
args_list = parse_cmd_args(input_cmd_args, args_list_template)
#------------------------------------------------

# add files from files argument
fls = parse_files(args_list[["files"]])
# add files from directory argument
fls = c(fls, parse_dir(args_list[["dir"]]))
# check that we have data
if(is.null(fls)) stop("please provide input data as 'files=' or 'dir=' argument")

# create iterator over files
it_files = ifiles(fls, reader = readr::read_lines)
# create iterator over tokens
it_token = itoken(it_files, progressbar = TRUE)
# create vocabulary
log_info("starting creation of vocabulary")
# v = create_vocabulary(it_token, stopwords = readLines(parse_files(args_list[["files"]])))
v = create_vocabulary(it_token)
cat("\n")
log_info(paste0("vocabulary created - ", nrow(v$vocab), " unique terms"))
log_info(paste0("saving vocabulary to ", args_list[["vocab_file"]]))
saveRDS(v, file = args_list[["vocab_file"]], compress = FALSE)
log_info("successfully saved")