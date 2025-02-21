
library(data.table)

.args <- if (interactive()) c(
  "NC_raw.csv",
  "NC.rds"
) else commandArgs(trailingOnly = TRUE)

raw_dt <- fread(.args[1])

res_dt <- raw_dt[Year == 2023]

saveRDS(res_dt, tail(.args, 1))
