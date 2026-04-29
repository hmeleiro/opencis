# Create a small labelled data frame
df <- data.frame(
  SEXO = haven::labelled(c(1, 2, 1), labels = c(Hombre = 1, Mujer = 2)),
  EDAD = c(34, 51, 29)
)
attr(df$SEXO, "label") <- "Sexo"
attr(df$EDAD, "label") <- "Edad"

# Inspect its variable dictionary
dict <- get_data_dictionary(df)
print(dict)

# Find variables with a specific keyword in their label
dict[grepl("sexo", dict$label, ignore.case = TRUE), ]

# Inspect value labels for a specific variable
sex_var <- match("SEXO", dict$variable)
if (!is.na(sex_var)) {
  dict$value_labels[[sex_var]]
}
