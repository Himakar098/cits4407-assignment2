#!/bin/bash

# Function to check if file exists and is readable
check_file() {
    if [ ! -r "$1" ]; then
        echo "Error: File '$1' not found or not readable." >&2
        exit 1
    fi
}

# Function to check if the file is tab-separated
check_tab_separated() {
    if ! head -n 1 "$1" | awk -F'\t' '{if(NF>1) exit 0; else exit 1}'; then
        echo "Error: File '$1' is not tab-separated." >&2
        exit 1
    fi
}

# Function to identify the type of the file based on headers
identify_file_type() {
    header=$(head -n 1 "$1")
    if [[ "$header" == *"GDP per capita, PPP (constant 2017 international \$)"* ]]; then
        echo "gdp"
    elif [[ "$header" == *"Homicide rate per 100,000 population - Both sexes - All ages"* ]]; then
        echo "homicide"
    elif [[ "$header" == *"Life expectancy - Sex: all - Age: at birth - Variant: estimates"* ]]; then
        echo "life_satisfaction"
    else
        echo "Error: Unrecognized file format in '$1'." >&2
        exit 1
    fi
}

# Function to check if each line has the same number of cells as the header
check_number_of_cells() {
    local file="$1"
    local header=$(head -n 1 "$file")
    local num_columns=$(echo "$header" | awk -F'\t' '{print NF}')
    awk -v num_columns="$num_columns" -F'\t' '
    NR > 1 {
        if (NF != num_columns) {
            print "File:", FILENAME, "Line:", NR, "does not have", num_columns, "columns."
        }
    }' "$file"
}

# Function to remove the "Continent" column and ignore rows with empty country code or out of year range
process_file() {
    local file="$1"
    local header=$(head -n 1 "$file")
    local num_columns=$(echo "$header" | awk -F'\t' '{print NF}')
    local header_line=""
    awk -v num_columns="$num_columns" -F'\t' '
    BEGIN { OFS = FS }
    NR == 1 {
        for (i = 1; i <= NF; i++) {
            if ($i != "Continent") {
                col[i] = 1
                header_line = header_line (header_line ? OFS : "") $i
            }
        }
        print header_line
    }
    NR > 1 && $2 >= 2011 && $2 <= 2021 && $1 != "" {
        line = ""
        for (i = 1; i <= NF; i++) {
            if (col[i]) {
                line = line (line ? OFS : "") $i
            }
        }
        print line
    }' "$file"
}

# Check if exactly three arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 file1.tsv file2.tsv file3.tsv" >&2
    exit 1
fi

# Check if input files exist, are readable, and are tab-separated
for file in "$@"; do
    check_file "$file"
    check_tab_separated "$file"
done

# Identify the type of each file
gdp_file=""
homicide_file=""
life_satisfaction_file=""

for file in "$@"; do
    file_type=$(identify_file_type "$file")
    case "$file_type" in
        gdp)
            gdp_file="$file"
            ;;
        homicide)
            homicide_file="$file"
            ;;
        life_satisfaction)
            life_satisfaction_file="$file"
            ;;
        *)
            echo "Error: Unrecognized file type." >&2
            exit 1
            ;;
    esac
done

# Ensure all required files are identified
if [ -z "$gdp_file" ] || [ -z "$homicide_file" ] || [ -z "$life_satisfaction_file" ]; then
    echo "Error: Missing one or more required files." >&2
    exit 1
fi

# Check each file for consistent number of cells per line
for file in "$@"; do
    check_number_of_cells "$file"
done

# Process files to remove the "Continent" column, ignore rows with empty country code, and filter by year range
cleaned_gdp_file=$(mktemp)
cleaned_homicide_file=$(mktemp)
cleaned_life_satisfaction_file=$(mktemp)

process_file "$gdp_file" > "$cleaned_gdp_file"
process_file "$homicide_file" > "$cleaned_homicide_file"
process_file "$life_satisfaction_file" > "$cleaned_life_satisfaction_file"

# Check temporary files
echo "Cleaned GDP file:"
cat "$cleaned_gdp_file"
echo "Cleaned Homicide file:"
cat "$cleaned_homicide_file"
echo "Cleaned Life Satisfaction file:"
cat "$cleaned_life_satisfaction_file"

# Combine and clean data
output_file="combined_output.tsv"
awk -F'\t' 'BEGIN {
    OFS = "\t"
    print "Entity/Country", "Code", "Year", "GDP per capita", "Population", "Homicide Rate", "Life Expectancy", "Cantril Ladder score"
}
NR == FNR {
    if (NR > 1) {
        gdp[$2][$3] = $5
        population[$2][$3] = $6
        cantril[$2][$3] = $4
    }
    next
}
FNR == NR && NR != FNR {
    if (FNR > 1) {
        homicide[$2][$3] = $4
    }
    next
}
FNR != NR {
    if (FNR > 1) {
        country = $1
        code = $2
        year = $3
        gdp_value = (code in gdp && year in gdp[code]) ? gdp[code][year] : "NA"
        population_value = (code in population && year in population[code]) ? population[code][year] : "NA"
        homicide_value = (code in homicide && year in homicide[code]) ? homicide[code][year] : "NA"
        life_expectancy_value = (code in cantril && year in cantril[code]) ? cantril[code][year] : "NA"
        cantril_value = (code in cantril && year in cantril[code]) ? cantril[code][year] : "NA"
        print country, code, year, gdp_value, population_value, homicide_value, life_expectancy_value, cantril_value
    }
}' "$cleaned_gdp_file" "$cleaned_homicide_file" "$cleaned_life_satisfaction_file" > "$output_file"

# Check combined output
echo "Combined Output File:"
cat "$output_file"

# Clean up temporary files
rm "$cleaned_gdp_file" "$cleaned_homicide_file" "$cleaned_life_satisfaction_file"
