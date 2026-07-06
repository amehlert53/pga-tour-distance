# PGA Tour Distance & Speed Analytics — Project Context

## Purpose of This Document
This file provides full context for Claude Code (and any collaborator) about the goals,
data, analytical plan, and conventions of this project. Reference it when prompting
Claude Code for any task in this repository.

---

## Project Goals
1. **Portfolio:** Demonstrate applied data science skills (distributional analysis,
   quasi-experimental design, mixed-effects modeling, survival analysis) using a
   real, publicly available sports dataset.
2. **Content:** Produce blog posts and social media visuals from each analysis module.
3. **Publication:** Package the complete analysis into a peer-reviewed manuscript on
   driving distance and speed trends in professional golf.

---

## Overarching Narrative
> Professional golf has undergone a fundamental physical transformation. Driving distance
> and ball speed have risen substantially, the competitive floor has risen with them, and
> the advantage of being a long hitter has grown — yet repeated regulatory interventions
> have had limited or counterproductive effects. This transformation has reshaped who
> competes, who succeeds, and how long careers last.

---

## Datasets

### df_complete.csv (`data/raw/`)
The strokes-gained-era dataset: richer per-season stats (speed, strokes
gained), but only available from 2004 onward. A player's first row here is
**not** necessarily their true PGA Tour debut — see `entry_year` below.
- **Coverage:** 2004–2025, PGA Tour season-level player records
- **Unit:** One row per player-season
- **Key columns:**
  - `player_name`, `year`, `age`, `birth_year`, `turned_pro`, `rookie year`
  - `distance` — driving distance (yards)
  - `accuracy` — fairways hit %
  - `ball_speed` — ball speed (mph); NAs exist for 2004–2006
  - `chs` — clubhead speed (mph); NAs exist for 2004–2006
  - `carry_distance` — carry distance (yards); NAs exist for 2004–2006
  - `sg_ott` — strokes gained: off the tee
  - `sg_apr` — strokes gained: approach
  - `sg_arg` — strokes gained: around the green
  - `sg_putt` — strokes gained: putting
  - `sg_ttg` — strokes gained: tee to green
  - `sg_total` — strokes gained: total

### trends_acc_dist_1987_to_2025.csv (`data/raw/`)
The long-history dataset: only distance/accuracy (no speed or strokes
gained), but goes back to 1987. Used in `00_data_engineering.Rmd` to
cross-reference `df_complete`'s players and recover a true tour-entry year
for the ~25% of players whose first `df_complete` row is 2004 but who were
actually already active beforehand.
- **Coverage:** 1987–2025, PGA Tour season-level player records
- **Unit:** One row per player-season
- **Key columns:**
  - `player`, `year`, `distance`, `accuracy`
  - `distance_season_avg`, `accuracy_season_avg`
  - `relative_distance` — player distance minus season mean
  - `relative_accuracy` — player accuracy minus season mean

---

## Engineered Variables (created in `notebooks/00_data_engineering.Rmd`)
All outputs written to `data/processed/`.

| Variable | Description |
|---|---|
| `entry_year` | True tour-entry year — `min(year)` across `df_complete` **and** the trends file, by player name |
| `left_truncated` | `TRUE` if `entry_year` equals the trends file's own start (1987) — true entry may predate the data window |
| `years_on_tour` | `year - entry_year` |
| `entry_cohort` | Decade of `entry_year`: pre-2000, 2000–2009, 2010–2019, 2020+. Career-stage lens — use for tenure/survival questions |
| `birth_cohort` | Decade of `birth_year`: Pre-1970, 1970s, 1980s, 1990s, 2000s+. Generational lens — use for "did the player population change" questions |
| `dist_vs_field` | `distance - mean(distance)` within each year |
| `speed_vs_field` | `ball_speed - mean(ball_speed)` within each year |
| `chs_vs_field` | `chs - mean(chs)` within each year |
| `dist_player_mean` | Career-average distance for each player (Mundlak between-effect) |
| `dist_within` | `distance - dist_player_mean` (Mundlak within-effect) |
| `sg_entry_year` | First strokes-gained-era observed season (first row in `df_complete`) — distinct from `entry_year`, only used to pull `dist_entry`/`speed_entry`/`chs_entry` since those stats don't exist before 2004 |
| `dist_entry` | Distance in player's first strokes-gained-era season (`sg_entry_year`) |
| `dist_entry_quartile` | Distance quartile within `sg_entry_year`'s field |
| `dist_quintile` | Distance quintile within each year (1=shortest, 5=longest) |
| `archetype` | Quadrant: Long/Accurate, Long/Inaccurate, Short/Accurate, Short/Inaccurate |

`rookie_year`/`turned_pro` are kept as raw columns but are **not** the basis
for any engineered variable above — `turned_pro` has a median 7-year (62%
>5-year) gap to actual PGA Tour entry, and `rookie_year` is NA for 79
rows/28 players. See `00_data_engineering.Rmd` section 3.2b/3.4 for the
full reasoning.

`00b_survival_prep.Rmd` engineers a further set of spell/gap variables
(`spell_id`, `gap_before`, `gap_after`, `is_final_spell`,
`final_gap_length`) — see Project 7 below.

---

## Analysis Modules

### 00 — Data Engineering (`notebooks/00_data_engineering.Rmd`)
**Goal:** Clean raw data, engineer all derived variables, write processed outputs.
**Outputs:** `data/processed/df_main.rds`, `data/processed/df_trends.rds`

**Note:** `data/processed/df_survival.rds` is produced separately by
`notebooks/00b_survival_prep.Rmd` (not yet created), once there's sufficient
familiarity with career gap patterns to make defensible censoring decisions.

---

### Project 1 — Distribution Shifts (`notebooks/01_distribution_shifts.Rmd`)
**Question:** Has driving distance increased because the elite pulled away, the bottom
was pushed up, or the entire distribution shifted uniformly? Has the field become more
or less homogeneous?

**Data:** Both datasets. Full player-year records (not aggregated).

**Key analyses:**
- Descriptive distributional stats by year: mean, SD, CV, IQR, skewness, kurtosis
- Percentile trajectory: track 10th/25th/50th/75th/90th over time
- Quantile regression over time: separate OLS trend lines per quantile; compare slopes
- Wasserstein distance from reference year (1990 or 2000)
- Distance-accuracy trade-off: Spearman correlation by year; scatter triptych

**Key visuals:**
- Percentile fan/ribbon chart (signature visual)
- Ridgeline plot (every 5th year)
- CV over time
- Distance-accuracy scatter triptych

---

### Project 2 — Regulatory Inflection Points (`notebooks/02_regulatory_inflection.Rmd`)
**Question:** Did equipment and rule changes produce statistically detectable changes
in distance and accuracy trends?

**Regulatory events:** Stored in `config.R` as `regulatory_events`.

**Data:** Season-mean time series (aggregate `trends_acc_dist` by year).

**Key analyses:**
- Segmented regression with known breakpoints (`segmented` package)
- Data-driven breakpoint detection: PELT via `changepoint` package; Bai-Perron via
  `strucchange` package
- ITS for each major regulation: pre/post 5-year windows
- Counterfactual projection: project pre-2003 trend forward, compare to actual

**Key visuals:**
- Annotated trend with fitted segmented regression lines
- Forest plot of level/slope changes per regulation
- CUSUM / changepoint plot
- Counterfactual projection with shaded uncertainty band

---

### Project 3 — The Distance Premium (`notebooks/03_distance_premium.Rmd`)
**Question:** Has the relationship between driving distance and competitive success
(SG_total) strengthened over time?

**Data:** `df_complete` (2004–2025).

**Key analyses:**
- Year-by-year Spearman correlation: distance rank vs. SG_total
- Annual R²: SG_total ~ SG_OTT by year
- SG component importance: annual regressions, standardized betas, 4 components over time
- Distance quintile SG_total trajectories
- Interaction model: `SG_total ~ dist_vs_field * year + age + (1|player)` via lme4
- Distance premium metric: SG_total per 10 yards above average, estimated by year

**Key visuals:**
- Year-by-year correlation time series
- SG component beta trajectories (4 lines)
- Distance quintile SG_total trajectories (5 lines)
- Scatter triptych: 2005 / 2013 / 2025
- Distance premium line chart

---

### Project 4 — The Rising Floor (`notebooks/04_rising_floor.Rmd`)
**Question:** Has the minimum distance/speed required to compete on tour risen?

**Data:** `df_complete` (2004–2025).

**Key analyses:**
- Bottom percentile trends: 10th and 25th percentile distance, ball speed, CHS over time
- Competitive threshold curves: speed/distance of the player at SG_total median and
  25th percentile each year
- Minimum viable analysis: extended Image 3 — avg and min ball speed/CHS/distance for
  top 50 SG performers by year; extend to multiple tier cuts
- Time-to-obsolescence: years until a player's entry distance is below field 25th percentile

**Key visuals:**
- Extended Image 3 (3 panels: distance, ball speed, CHS)
- Competitive threshold curves
- Time-to-obsolescence violin by `entry_cohort` (career-stage lens, not birth_cohort)

---

### Project 5 — Player Archetypes (`notebooks/05_player_archetypes.Rmd`)
**Question:** Has the physical and statistical profile of a successful PGA Tour player
changed? Are bombers more represented among top performers now?

**Data:** `df_complete` (2004–2025).

**Key analyses:**
- Quadrant classification: dist_vs_field × accuracy_vs_field
- K-means clustering on [dist_vs_field, accuracy_vs_field, sg_ott, sg_putt]; run at
  3 eras separately
- Archetype share among top-25% SG_total players by year
- Era comparison: 2004–2010 vs. 2018–2025 top-performer profiles (MANOVA + radar chart)

**Key visuals:**
- Archetype stacked proportion chart over time
- Radar chart: early vs. late era top performer
- Quadrant scatter faceted by era

---

### Project 6 — Age and Cohorts (`notebooks/06_age_cohorts.Rmd`)
**Question:** When do players peak in distance? Are newer cohorts entering with more
speed? Is the age of peak distance changing?

**Data:** `df_complete` (2004–2025); minimum 3 seasons required.

**Note on cohort choice:** this project's questions are about generational
change (did golfers who grew up with different equipment/training enter
differently), which `birth_cohort` isolates — `entry_cohort` would mix a
22-year-old rookie with a late-blooming 35-year-old debut in the same
bucket. Use `birth_cohort` for the analyses below unless a specific question
is actually about career stage.

**Key analyses:**
- Age-distance polynomial curve: `distance ~ age + age² + (1 + age | player)` via lme4
- Cohort trajectory: entry-year-aligned distance by `birth_cohort`
- Rookie entry speed over time: first-season distance/speed by `entry_year`
  (already available as `dist_entry`/`speed_entry`/`entry_year`, no rebuild needed)
- Mundlak decomposition: `distance ~ year + dist_player_mean + dist_within + age + age²`
- Peak age estimation by `birth_cohort`: `-β_age / (2 × β_age²)`

**Key visuals:**
- Age-distance curve with CI ribbon, faceted by `birth_cohort`
- Cohort trajectory overlaid lines
- Rookie entry speed scatter with trend
- Mundlak decomposition bar chart

---

### Project 7 — Career Survival (`notebooks/07_survival_analysis.Rmd`)
**Question:** What physical and competitive characteristics predict career longevity?
Has being short off the tee become a stronger predictor of career exit?

**Data:** `df_survival.rds` — constructed in `00b_survival_prep.Rmd`.

**Survival dataset structure:**
- One row per player-year (start-stop format for time-varying Cox)
- `time_start`, `time_stop`: calendar tenure, `year - entry_year`
- `spell_id`, `spell_start_year`, `spell_end_year`: a player's distinct runs
  of consecutive observed seasons (players frequently have gap seasons —
  35% of players miss at least one season, and in 165 cases a player missed
  2+ *consecutive* seasons and later returned)
- `gap_before`, `gap_after`: seasons missed before/after a given spell
- `is_final_spell`, `final_gap_length`: flags a player's last observed spell
  and how many years since it ended (as of 2025)
- `left_truncated`: carried from `df_main` — `entry_year` may understate
  true tenure for this subgroup
- `dist_entry_quartile`: distance quartile at strokes-gained-era entry
- Time-varying: `dist_vs_field`, `sg_total`, `age` — updated each year

**Censoring rule:** deliberately **not** fixed upstream. `00b_survival_prep.Rmd`
computes the spell/gap primitives above but does not hard-code a single
`event`/"career ended" rule — an earlier fixed rule ("absent 2+ consecutive
seasons = career end") was checked against the data and found to
misclassify 165+ still-active careers, since gap-then-return is common
(conditional status, injury, etc.). Build `event` from `final_gap_length` in
**this** notebook instead, under a couple of candidate thresholds (e.g. ≥2,
≥3, ≥4 years) as an explicit, named sensitivity check — don't silently pick
one. Also compare full-sample vs. `left_truncated`-excluded results as a
secondary robustness check.

**Key analyses:**
- Kaplan-Meier curves stratified by distance quartile at entry; log-rank test
- Cox PH (time-fixed): `Surv(time, event) ~ dist_entry_quartile + entry_cohort + sg_ott_avg + sg_putt_avg`
- Cox PH (time-varying): start-stop format; `dist_vs_field` and `sg_total` as annual predictors
- Era-stratified Cox: 2004–2012 vs. 2013–2025; compare distance HR across eras
- Late-career survivor profile: 38+ vs. earlier-exit comparison

**Key visuals:**
- Kaplan-Meier curves (4 distance quartile lines)
- Forest plot of Cox hazard ratios
- Late-career survivor radar chart

---

## R Packages Used

```r
# Core
library(tidyverse)
library(here)

# Modeling
library(lme4)        # Mixed-effects models
library(survival)    # Kaplan-Meier, Cox PH
library(quantreg)    # Quantile regression
library(lqmm)        # Quantile mixed-effects models
library(segmented)   # Segmented regression with known breakpoints
library(strucchange) # Bai-Perron structural break detection
library(changepoint) # PELT changepoint detection

# Visualization
library(ggplot2)
library(ggridges)    # Ridgeline plots
library(ggsurvfit)   # Clean survival curve plots
library(patchwork)   # Multi-panel figures
library(scales)

# Utilities
library(broom)       # Tidy model outputs
library(broom.mixed) # Tidy lme4 outputs
```

---

## Conventions

- **File paths:** Always use `here::here()` — never hardcode absolute paths
- **Processed data:** Written as `.rds` (R native, fast, type-safe); raw data stays as `.csv`
- **Figures:** Saved at 300 DPI to `figures/publication/`; 150 DPI to `figures/social/`
- **Notebook structure:** Each `.Rmd` follows: Setup → Data → Analysis → Visuals → Summary
- **config.R:** Source at the top of every notebook — contains all shared constants
- **Randomness:** Set `set.seed(2025)` at the top of any notebook involving clustering
  or resampling

---

## Prompting Claude Code

When asking Claude Code to help with a specific notebook, reference this document:

> "Using the project context in `docs/project_context.md`, help me build the analysis
> in `notebooks/03_distance_premium.Rmd`. Start with the year-by-year Spearman
> correlation between distance rank and SG_total."

Claude Code can read all files in this repo. Keep `config.R` sourced and use `here()`
for all paths so code is portable.