library(magrittr)
suppressMessages(library(text2vec))

parse_cmd_args = function(cmd_args, args_list) {
  args_allowed = names(args_list)
  for (arg in cmd_args) {
    kv = strsplit(arg, "=", T)[[1]]
    key = kv[[1]]
    if( !(key %in% args_allowed)) {
      msg = paste0("can't recognize '", key, "' argument\n") 
      msg = paste0(msg, 'Only "', paste(args_allowed, collapse = '" "'), '" allowed\n')
      # msg = paste0(msg, 'Example: \n./vocabulary.R files=./data/file1,./data/file2 stopwords=stopwords_file.txt')
      stop(msg)
    }
    
    if(length(kv) != 2)
      stop(paste("can't parse", kv, "to key-value pairs"))
    
    value = kv[[2]]
    # print(paste0("key=", key, ", value=", value))
    args_list[[key]] = value
  }
  args_list
}

parse_files = function(x) {
  fls = NULL
  if(!is.null(x)) {
    # parse file names
    fls = x %>% 
      strsplit(",", TRUE) %>% 
      unlist(use.names = FALSE)
    if(!all(file.exists(fls))) {
      stop("one or more input files don't exist")
    }
  }
  fls
}

parse_dir = function(x) {
  fls = NULL
  if(!is.null(x)) {
    stopifnot(dir.exists(x))
    fls = c(fls, list.files(x, full.names = TRUE))
  }
  fls
}

log_info = function(msg) {
  message(paste(Sys.time(), msg))
}