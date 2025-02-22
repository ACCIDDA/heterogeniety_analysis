
default: result.png

R = $(strip $(shell which Rscript) $^ ${1} $@)

%.rds: clean_%.R %_raw.csv
	$(call R)

ALLRDS := $(patsubst %_raw.csv,%.rds,$(wildcard *_raw.csv))

$(info ALLRDS: ${ALLRDS})

result.csv: analyze.R ${ALLRDS}
	$(call R)

result.png: visualize.R result.csv
	$(call R)