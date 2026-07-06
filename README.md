# PGA Tour Distance & Speed Analytics

Longitudinal analysis of driving distance, ball speed, and competitive trends 
on the PGA Tour (1987–2025).

## Overview

This project examines how driving distance, ball speed, and clubhead speed have 
evolved across professional golf's modern era, with a focus on distributional 
shifts, regulatory effects, competitive implications, and career dynamics.

The analysis is structured as a series of independent but interconnected modules, 
each addressing a distinct research question while contributing to a unified 
narrative about the physical transformation of professional golf.

## Project Structure

| Notebook | Question |
|---|---|
| `00_data_engineering` | Data cleaning, variable engineering, processed outputs |
| `01_distribution_shifts` | How has the full distribution of distance changed? |
| `02_regulatory_inflection` | Did rule changes produce detectable trend breaks? |
| `03_distance_premium` | Has being long become more valuable over time? |
| `04_rising_floor` | Has the minimum speed to compete risen? |
| `05_player_archetypes` | Has the profile of a successful player changed? |
| `06_age_cohorts` | When do players peak? Are newer cohorts faster at entry? |
| `07_survival_analysis` | What predicts career longevity on tour? |

## Data

Raw data files are not tracked in this repository. The analysis uses two 
publicly available PGA Tour season-level datasets:

- `df_complete.csv` — Player-season records, 2004–2025 (ShotLink era)
- `trends_acc_dist_1987_to_2025.csv` — Distance and accuracy records, 1987–2025

## Tech Stack

- **Language:** R
- **Environment:** VS Code with Jupyter / R Markdown
- **Key packages:** tidyverse, lme4, survival, quantreg, segmented, ggplot2

## Goals

1. **Portfolio** — Demonstrate applied data science skills across distributional 
   analysis, quasi-experimental design, mixed-effects modeling, and survival analysis
2. **Content** — Blog posts and social media visuals from each analysis module  
3. **Publication** — Peer-reviewed manuscript on distance and speed trends in 
   professional golf
