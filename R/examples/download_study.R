\dontrun{
# Save the ZIP file to the current directory
path <- download_study("3328")
cat("Saved to:", path, "\n")

# Save to a specific folder
path <- download_study("3328", destdir = tempdir())
cat("Saved to:", path, "\n")
}
