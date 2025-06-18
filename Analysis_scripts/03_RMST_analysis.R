#!/usr/bin/env Rscript
# -------------------------------------------------------------------------
# 03_RMST_analysis.R
# Runs primary (48 h) and secondary (672 h) RMST analyses, unadjusted
# and adjusted for age & weight, and generates shaded RMST plot.
# -------------------------------------------------------------------------
library(tidyverse); library(survival); library(survRM2)
library(broom); library(ggsurvfit); library(ggplot2); library(stringr)

DERIV  <- 'data/derived/parist_analysis_set.csv'
OUTDIR <- 'analysis/results'
FIGDIR <- 'figures'
dir.create(OUTDIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGDIR, showWarnings = FALSE, recursive = TRUE)

dat <- read_csv(DERIV)

run_rmst <- function(d, tau, adjust = FALSE){
  if(adjust){
    rmst2(time = d$time_hr, status = d$censor, arm = d$treatment,
          tau = tau, covariates = d |> select(age_years, weight_kg))
  } else {
    rmst2(time = d$time_hr, status = d$censor, arm = d$treatment, tau = tau)
  }
}

# --- Fit models -----------------------------------------------------------
rmst48_u  <- run_rmst(dat,  48, adjust = FALSE)
rmst48_a  <- run_rmst(dat,  48, adjust = TRUE)
rmst672_u <- run_rmst(dat, 672, adjust = FALSE)
rmst672_a <- run_rmst(dat, 672, adjust = TRUE)

# --- Export tidy summaries -----------------------------------------------
bind_rows(
  broom::tidy(rmst48_u$model.t)  |> mutate(analysis = '48h_unadj'),
  broom::tidy(rmst48_a$model.t)  |> mutate(analysis = '48h_adj'),
  broom::tidy(rmst672_u$model.t) |> mutate(analysis = '672h_unadj'),
  broom::tidy(rmst672_a$model.t) |> mutate(analysis = '672h_adj')
) |> write_csv(file.path(OUTDIR, 'rmst_model_summaries.csv'))

# --- KM Plot (0‑48 h) -----------------------------------------------------
km <- survfit(Surv(time_hr, censor) ~ treatment, data = dat)
p_km <- ggsurvfit(km) + add_confidence_interval() +
        scale_x_continuous(limits = c(0,48), breaks = seq(0,48,12)) +
        theme_minimal() +
        labs(x='Hours', y='Renal‑recovery probability')
ggsave(file.path(FIGDIR,'Fig_KM_48h.pdf'), p_km, width=6, height=4)

# --- Shaded RMST plot -----------------------------------------------------
km_df <- broom::tidy(km) |> 
         mutate(strata = str_remove(strata, 'treatment=')) |> 
         select(time, surv, strata)

tau <- 48
rmst_tbl <- tibble(
  strata = levels(dat$treatment),
  rmst   = c(rmst48_u$RMST.arm0$Est[1], rmst48_u$RMST.arm1$Est[1])
)

p_rmst <- ggplot(km_df, aes(time, surv, colour = strata)) +
  geom_step(size = 1) +
  geom_area(data = subset(km_df, time <= tau),
            aes(fill = strata), alpha = .25, position = 'identity', colour = NA) +
  geom_vline(xintercept = tau, linetype = 'dashed') +
  geom_text(data = rmst_tbl,
            aes(x = tau * 0.35, y = c(.92,.82),
                label = paste0('RMST (', strata, '): ', round(rmst,1), ' h'),
                colour = strata),
            hjust = 0, size = 4, show.legend = FALSE) +
  scale_x_continuous(limits = c(0,tau), breaks = seq(0,tau,12)) +
  scale_colour_manual(values = c(control='red', paracetamol='blue')) +
  scale_fill_manual(values   = c(control='red', paracetamol='blue')) +
  theme_minimal(base_size = 14) +
  labs(title='Restricted Mean Survival Time (τ = 48 h)',
       x='Time since enrolment (hours)', y='Renal‑recovery probability',
       colour='Treatment', fill='Treatment') +
  theme(plot.title = element_text(face='bold', hjust=.5),
        legend.position='top')

ggsave(file.path(FIGDIR, 'Fig_RMST_Area48h.pdf'), p_rmst, width=6.5, height=4.5)

message('✅ RMST analyses & plots complete.')
