# =============================================================================
# config.R
# Shared constants, paths, and parameters for pga-tour-distance project
# Source this file at the top of every notebook: source(here::here("config.R"))
# =============================================================================

library(here)

# --- Paths -------------------------------------------------------------------
PATH_RAW        <- here("data", "raw")
PATH_PROCESSED  <- here("data", "processed")
PATH_EXTERNAL   <- here("data", "external")
PATH_FIGURES    <- here("figures")

# --- Regulatory / Equipment Events ------------------------------------------
regulatory_events <- tibble::tibble(
  year  = c(1992, 1996, 2000, 2003, 2004, 2010, 2022),
  label = c(
    "Oversized Drivers",
    "Titanium Drivers",
    "Pro V1",
    "COR Limits",
    "Club Size / MOI Limits",
    "Groove Rule",
    "Driver Length Limit"
  )
)

# --- Era Definitions ---------------------------------------------------------
ERA_BREAKS <- c(1987, 1996, 2003, 2010, 2018, 2025)
ERA_LABELS <- c("Pre-Titanium", "Titanium Era", "Ball Tech Era",
                "Modern Era", "Power Era")

# --- Analysis Parameters -----------------------------------------------------
MIN_SEASONS     <- 2     # Minimum seasons for longitudinal analyses
SPEED_ERA_START <- 2007  # First year with reliable ball speed / CHS data
SG_ERA_START    <- 2004  # First year with SG data

# --- Plot Theme --------------------------------------------------------------
THEME_BASE <- ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(
    plot.title       = ggplot2::element_text(face = "bold", size = 14),
    plot.subtitle    = ggplot2::element_text(colour = "grey40", size = 11),
    panel.grid.minor = ggplot2::element_blank(),
    legend.position  = "bottom"
  )

# --- Colours -----------------------------------------------------------------
COL_PRIMARY   <- "#1B3A6B"
COL_SECONDARY <- "#C8A951"
COL_NEUTRAL   <- "#888888"
COL_ACCENT    <- "#C0392B"

COL_QUINTILES <- c("#2C7BB6", "#ABD9E9", "#FFFFBF", "#FDAE61", "#D7191C")