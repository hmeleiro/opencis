\donttest{
# Save the ZIP file to a temporary directory
path <- download_study("3328", destdir = tempdir())
cat("Saved to:", path, "\n")
}
