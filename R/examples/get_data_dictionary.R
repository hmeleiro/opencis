\dontrun{
# Load a study and inspect its variable dictionary
df <- read_cis("3328")
dict <- get_data_dictionary(df)
print(dict)

# Find variables with a specific keyword in their label
dict[grepl("sexo", dict$label, ignore.case = TRUE), ]

# Inspect value labels for a specific variable
dict$value_labels[[which(dict$variable == "SEXO")]]
}
