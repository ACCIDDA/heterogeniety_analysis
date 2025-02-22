
library(data.table)

.args <- if (interactive()) c(
  "NC_raw.csv",
  "NC.rds"
) else commandArgs(trailingOnly = TRUE)

raw_dt <- fread(.args[1])[Year == 2023][, 2:22]

melt_dt <- raw_dt |> melt(id.vars = c("Race", "Sex"), variable.name = "age")

res_dt <- melt_dt[, race := fcase(
  Race == "White", "WHITE",
  Race == "Asian", "ASIAN",
  Race == "Black", "BLACK",
  default = "OTHER"
)][, .(population = sum(value)), by = .(race, age)]

res_dt[,
  c("age_start", "age_end") := tstrsplit(gsub("Age ", "", age), " to ") |> lapply(as.integer)
]

saveRDS(res_dt[, .(race, age_start, age_end, population)], tail(.args, 1))
