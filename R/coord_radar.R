# coord_radar() — straight-edged (not curved-arc) polar coordinate for radar
# charts. ggplot2 has no native version of this. Originally defined inline in
# 05_player_archetypes.Rmd (and copy-pasted into 07_survival_analysis.Rmd);
# extracted here once a 3rd/4th notebook needed it too.
coord_radar <- function(theta = "x", start = 0, direction = 1) {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggplot2::ggproto("CordRadar", ggplot2::CoordPolar, theta = theta, r = r,
                    start = start, direction = sign(direction),
                    is_linear = function(coord) TRUE)
}
