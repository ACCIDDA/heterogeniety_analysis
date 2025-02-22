
library(data.table)
library(ggplot2)

.args <- if (interactive()) c(
  "result.csv",
  "result.png"
) else commandArgs(trailingOnly = TRUE)

dt <- fread(.args[1])

p <- ggplot(dt) +
  aes(
    x = factor(model_partition),
    ymin = relvalue, ymax = relvalue,
    color = race
  ) +
  facet_grid(~state) +
  geom_errorbar(data = \(dt) dt[race != "WHITE"]) +
  geom_hline(aes(color = "WHITE", yintercept = 1), linetype = "dashed") +
  scale_y_continuous("Rel. IFR") +
  scale_color_discrete(name = NULL) +
  scale_x_discrete(name = NULL, labels = c("0 to 17", "18 to 64", "65+")) +
  theme_minimal()


ggsave(tail(.args, 1), p, width = 8, height = 4, dpi = 600, bg = "white")
