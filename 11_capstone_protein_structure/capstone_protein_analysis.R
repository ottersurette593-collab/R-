# Capstone: Protein structure analysis in R
# Recommended run path: project root

required_pkgs <- c("bio3d", "dplyr", "tidyr", "ggplot2")
missing_pkgs <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs)
}
invisible(lapply(required_pkgs, library, character.only = TRUE))

pdb_id <- "1ubq"
output_dir <- file.path("11_capstone_protein_structure", "output")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# 1) Read protein structure
pdb <- read.pdb(pdb_id)

# Basic summary
n_atoms <- nrow(pdb$atom)
chains <- unique(pdb$atom$chain)
residues <- unique(paste(pdb$atom$chain, pdb$atom$resno, pdb$atom$resid, sep = ":"))

summary_lines <- c(
  paste0("PDB ID: ", toupper(pdb_id)),
  paste0("Total atoms: ", n_atoms),
  paste0("Chains: ", paste(chains, collapse = ", ")),
  paste0("Unique residues: ", length(residues))
)

# 2) Extract C-alpha coordinates and compute distance matrix
ca_sel <- atom.select(pdb, elety = "CA")
ca_xyz <- pdb$xyz[ca_sel$xyz]
ca_mat <- matrix(ca_xyz, ncol = 3, byrow = TRUE)
colnames(ca_mat) <- c("x", "y", "z")

ca_dist <- as.matrix(dist(ca_mat))

# 3) Build B-factor profile
ca_atoms <- pdb$atom[ca_sel$atom, c("resno", "resid", "b")]
ca_atoms <- ca_atoms %>%
  distinct(resno, .keep_all = TRUE) %>%
  arrange(resno)

p_b <- ggplot(ca_atoms, aes(x = resno, y = b)) +
  geom_line(color = "#1B5E20", linewidth = 0.8) +
  geom_point(color = "#2E7D32", size = 1.2) +
  labs(
    title = paste("B-factor Profile:", toupper(pdb_id)),
    x = "Residue Number",
    y = "B-factor"
  ) +
  theme_minimal(base_size = 12)

bfactor_path <- file.path(output_dir, "bfactor_profile.png")
ggsave(filename = bfactor_path, plot = p_b, width = 8, height = 4.5, dpi = 300)

# 4) Create distance heatmap
dist_df <- as.data.frame(as.table(ca_dist))
colnames(dist_df) <- c("i", "j", "distance")
dist_df <- dist_df %>%
  mutate(
    i = as.integer(i),
    j = as.integer(j)
  )

p_h <- ggplot(dist_df, aes(x = i, y = j, fill = distance)) +
  geom_tile() +
  scale_fill_viridis_c(option = "C", direction = -1) +
  coord_equal() +
  labs(
    title = paste("C-alpha Distance Heatmap:", toupper(pdb_id)),
    x = "Residue Index (i)",
    y = "Residue Index (j)",
    fill = "Distance\n(Angstrom)"
  ) +
  theme_minimal(base_size = 11)

heatmap_path <- file.path(output_dir, "ca_distance_heatmap.png")
ggsave(filename = heatmap_path, plot = p_h, width = 7, height = 6.5, dpi = 300)

# 5) Contact summary under threshold (e.g., 8A) excluding diagonal
threshold <- 8
contact_pairs <- dist_df %>%
  filter(i < j, distance <= threshold)

summary_lines <- c(
  summary_lines,
  paste0("C-alpha count: ", nrow(ca_mat)),
  paste0("Contact threshold: ", threshold, " Angstrom"),
  paste0("Contact pairs (i < j): ", nrow(contact_pairs)),
  paste0("Output plots: ", bfactor_path, " ; ", heatmap_path)
)

writeLines(summary_lines, con = file.path(output_dir, "summary.txt"))
message("Capstone completed. Outputs are saved to: ", normalizePath(output_dir))
