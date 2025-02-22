
library(data.table)
library(paramix)

.args <- if (interactive()) c(
  list.files(pattern = "^\\w{2}\\.rds$", full.names = TRUE),
  "result.csv"
) else commandArgs(trailingOnly = TRUE)

state_fls <- head(.args, -1)
state_fls <- setNames(state_fls, gsub("^.*(\\w{2})\\..*$", "\\1", state_fls))

dt <- (
  state_fls |> lapply(\(x) readRDS(x)) |> rbindlist(idcol = "state")
)[,
  .(population), keyby = .(state, race, from = age_start)
]

# Levin et al; doi: 10.1007/s10654-020-00698-1
ifr_levin <- function(age_in_years) {
  (10^(-3.27 + 0.0524 * age_in_years))
}

pastmaxfrom <- dt[, max(from) + 1L]

ext_dt <- dt[,
  rbind(.SD, data.table(from = pastmaxfrom, population = 0)),
  by = .(state, race)
]

model_partition <- c(0L, 17L, 64L, pastmaxfrom)
output_partition <- 0L:pastmaxfrom

computed_dt <- ext_dt[, {
  blend(alembic(ifr_levin, .SD, model_partition, output_partition))
}, by = .(state, race)]

rel_dt <- computed_dt[,{
  ref <- .SD[race == "WHITE", value]
  .(race, model_partition, ifr = value, relvalue = value/ref)
}, by = state]

fwrite(rel_dt, tail(.args, 1))
