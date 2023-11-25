#!/bin/zsh

# Function to display help menu
show_help() {
    echo "Usage: heic2png [FILE]..."
    echo
    echo "Converts one or more HEIC files to PNG format."
    echo "Example: heic2png image.heic"
    echo "Example: heic2png *.heic"
}

# Function to convert a single HEIC file to PNG
convert_heic_to_png() {
    local input_file=$1
    local output_file="${input_file%.*}.png"

    if [[ -f "$input_file" ]]; then
        convert "$input_file" "$output_file"
        echo "Converted $input_file to $output_file"
    else
        echo "File not found: $input_file"
    fi
}

# Check if help is requested or no arguments provided
if [[ "$1" == "--help" || "$1" == "-h" || $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Main loop to process each file
for file in "$@"; do
    convert_heic_to_png "$file"
done

