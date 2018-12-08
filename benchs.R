PATH <- 'worldcitiespop.txt'

system.time(lines <- readLines(PATH))
#    user  system elapsed
#   5.535   0.052   5.585


system.time(df1 <- read.csv(PATH, stringsAsFactors = FALSE))
#    user  system elapsed
#  12.761   0.112  12.867


dim(df1)
# [1] 3173958       7


library(data.table)
system.time(df2 <- fread(PATH, stringsAsFactors = FALSE))

# Read 95.5% of 3173958 rows
# Read 3173958 rows and 7 (of 7) columns from 0.141 GB file in 00:00:03
#    user  system elapsed
#   2.071   0.020   2.090


dim(df2)
# [1] 3173958       7


library(readr)
cols <-  cols(
  Country = col_character(),
  City = col_character(),
  AccentCity = col_character(),
  Region = col_character(),
  Population = col_character(),
  Latitude = col_double(),
  Longitude = col_double()
)
system.time(df3 <- read_csv(PATH, progress = FALSE, guess_max = 10, col_types = cols))
#    user  system elapsed
#   4.106   0.032   4.136



# time cat worldcitiespop.txt >/dev/null
# real	0m0.043s

# time wc -l worldcitiespop.txt
# 0m0.074s

# time xsv count worldcitiespop.txt
# real	0m0.283s

# time xsv stats worldcitiespop.txt
# real	0m2.470s
