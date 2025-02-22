
library(data.table)

.args <- if (interactive()) c(
  "CA_raw.csv", # from https://dof.ca.gov/Forecasting/Demographics/Projections/ => https://dof.ca.gov/wp-content/uploads/sites/352/2023/08/P3_California-and-Counties.xlsx
  "CA.rds"
) else commandArgs(trailingOnly = TRUE)

raw_dt <- fread(.args[1], select = c(2,3,4,8)) |>
  setnames(c("Age", "Race/ethnicity"), c("age", "race"))
raw_dt[, race := gsub(" NH$", "", race)]
raw_dt[!(race %in% c("WHITE", "ASIAN", "BLACK", "HISPANIC")), race := "OTHER"]

res_dt <- raw_dt[,
  .(population = sum(`2023`)),
  keyby = .(race, age_start = age)
]
res_dt[, age_end := c(tail(age_start, -1), NA_integer_), by = race]

saveRDS(res_dt[, .(race, age_start, age_end, population)], tail(.args, 1))
