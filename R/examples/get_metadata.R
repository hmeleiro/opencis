\donttest{
# Get metadata for study 3328
meta <- get_metadata("3328")
print(meta)

# Access a specific field
meta$value[meta$field == "Tipo de estudio"]
}
