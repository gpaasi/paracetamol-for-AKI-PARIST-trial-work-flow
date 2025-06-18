#!/usr/bin/env Rscript
# -------------------------------------------------------------------------
# 01_data-cleaning.R
# Purpose : Import raw trial data, de‑identify, engineer analysis variables,
#           and export a clean dataset for downstream use.
# Author  : <Your Name>
# Updated : 2025-06-18
# -------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(here)
})

RAW_PATH   <- here('data/raw/PARIST_raw.csv')        # never tracked
DERIV_PATH <- here('data/derived/parist_analysis_set.csv')
LOG_PATH   <- here('data/derived/cleaning_log.txt')
dir.create(dirname(DERIV_PATH), recursive = TRUE, showWarnings = FALSE)

# 1 · Import ----
raw <- read_csv(RAW_PATH, na = c('', 'NA', '.', 'NULL')) |> clean_names()

cat(sprintf('[%s] Imported %d rows × %d cols\n',
            Sys.time(), nrow(raw), ncol(raw)), file = LOG_PATH)

# 2 · Checks ----
stopifnot(anyDuplicated(raw$participant_id) == 0)
capture.output(skimr::skim(raw), file = LOG_PATH, append = TRUE)

# 3 · Derive ----
deriv <- raw |>
  mutate(
    id          = factor(participant_id),
    treatment   = factor(treatment_arm, levels = c(0,1),
                         labels = c('control','paracetamol')),
    sex         = factor(sex, levels = c(0,1), labels = c('female','male')),
    age_years   = as.numeric(age_years),
    weight_kg   = as.numeric(weight_kg),
    visit_date  = as.Date(sample_date)
  ) |>
  group_by(id) |>
  arrange(visit_date, .by_group = TRUE) |>
  mutate(time_hr = as.numeric(difftime(visit_date, first(visit_date), units = 'hours'))) |>
  ungroup() |>
  mutate(censor = as.integer(event_status)) |>
  select(id, treatment, sex, age_years, weight_kg, time_hr, censor,
         bun, creatinine, everything())

# fill missing weights within participant
deriv <- deriv |> group_by(id) |> fill(weight_kg, .direction = 'downup') |> ungroup()

write_csv(deriv, DERIV_PATH)
cat(sprintf('[%s] Wrote clean dataset → %s\n', Sys.time(), DERIV_PATH),
    file = LOG_PATH, append = TRUE)
message('✅ Data‑cleaning finished.')
