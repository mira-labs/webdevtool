#!/bin/bash
# Author: Radical Rad
# Email: rad@radicalrad.co.uk
# Date: 2023-11-24
# Description: This script generates favicons of various sizes from an input image,
#               creates a head.html file with link tags, and generates a manifest.json file
#               for a web application. It allows customization of app name, description,
#               package name, and output folder. The input image must be at least 128x128 pixels in size.
#               If the app description is not provided as an argument, the script will prompt the user to enter it.

# Function to generate a random 6-character string
generate_random_string() {
  echo "$(cat /dev/urandom | env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)"
}

# Function to check if the input image has a minimum size of 128x128
check_input_size() {
  local minimum_size=128
  local dimensions=$(identify -format "%wx%h" "$1")
  IFS='x' read -r width height <<< "$dimensions"

  if [ "$width" -lt "$minimum_size" ] || [ "$height" -lt "$minimum_size" ]; then
    echo "Error: The input image must be at least 128x128 pixels in size for scaling quality."
    exit 1
  fi
}

# Function to get the file size on disk
get_file_size() {
  local file_size=$(du -h "$1" | awk '{print $1}')
  echo "$file_size"
}

# Default values
input_file=""
output_folder=""
app_name="YourAppName"
app_description="Your app description"
package_name="your.app.package.name"

# Function to prompt user for app description
prompt_for_description() {
  read -p "Enter your app description: " app_description
}

# Display usage instructions
display_instructions() {
  echo "Usage: $0 <-i 'file name'> [-o folder_name] [-n 'app name'] [-d] [-p 'package name']"
  echo "-i 'file name': Specify the input image file. Must be at least 128x128 pixels in size."
  echo "-o folder_name: Specify the output folder. If not provided, a random folder name will be generated."
  echo "-n 'app name': Specify the app name. Defaults to 'YourAppName'."
  echo "-d: Specify the app description. If not provided, the script will prompt you to enter the app description."
  echo "-p 'package name': Specify the package name for related applications. Defaults to 'your.app.package.name'."
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -i)
      input_file="$2"
      check_input_size "$input_file"
      echo "Input file: $input_file, Size on disk: $(get_file_size "$input_file"), Dimensions: $(identify -format "%wx%h" "$input_file")"
      shift
      shift
      ;;
    -o)
      output_folder="$2"
      echo "Output folder: $output_folder"
      shift
      shift
      ;;
    -n)
      app_name="$2"
      echo "App name: $app_name"
      shift
      shift
      ;;
    -d)
      prompt_for_description
      echo "App description: $app_description"
      shift
      ;;
    -p)
      package_name="$2"
      echo "Package name: $package_name"
      shift
      shift
      ;;
    -h)
      display_instructions
      ;;
    *)
      echo "Unknown option: $1"
      display_instructions
      ;;
  esac
done

# Check if the required parameter -i is provided
if [ -z "$input_file" ]; then
  echo "Error: No input file specified."
  display_instructions
fi

# Check if the output folder is provided; if not, generate a random folder name
if [ -z "$output_folder" ]; then
  output_folder="favicon-$(generate_random_string)"
fi

# Create the output folder
mkdir -p "$output_folder"
echo "Output folder created: $output_folder"

# Array of favicon sizes
sizes=("48x48" "72x72" "96x96" "144x144" "168x168" "192x192")

# Generate favicons of different sizes
for size in "${sizes[@]}"; do
  output_file="$output_folder/icon-${size}.png"
  convert "$input_file" -resize "$size" "$output_file"
  echo "Favicon generated: $output_file"
done

# Create head.html file with link tags
head_file="$output_folder/head.html"
echo "<head>" > "$head_file"
for size in "${sizes[@]}"; do
  echo "  <link rel=\"icon\" type=\"image/png\" sizes=\"$size\" href=\"icon-${size}.png\">" >> "$head_file"
done
echo "  <link rel=\"manifest\" href=\"manifest.json\">" >> "$head_file"
echo "</head>" >> "$head_file"
echo "Head.html file created: $head_file"

# Create manifest.json file
manifest_file="$output_folder/manifest.json"
echo "{" > "$manifest_file"
echo "  \"name\": \"$app_name\"," >> "$manifest_file"
echo "  \"short_name\": \"$app_name\"," >> "$manifest_file"
echo "  \"start_url\": \".\"," >> "$manifest_file"
echo "  \"display\": \"standalone\"," >> "$manifest_file"
echo "  \"background_color\": \"#fff\"," >> "$manifest_file"
echo "  \"description\": \"$app_description\"," >> "$manifest_file"
echo "  \"icons\": [" >> "$manifest_file"
for size in "${sizes[@]}"; do
  echo "    {\"src\": \"icon-${size}.png\", \"sizes\": \"$size\", \"type\": \"image/png\"}," >> "$manifest_file"
done
echo "  ]," >> "$manifest_file"
echo "  \"related_applications\": [" >> "$manifest_file"
echo "    {" >> "$manifest_file"
echo "      \"platform\": \"play\"," >> "$manifest_file"
echo "      \"url\": \"https://play.google.com/store/apps/details?id=$package_name\"" >> "$manifest_file"
echo "    }" >> "$manifest_file"
echo "  ]" >> "$manifest_file"
echo "}" >> "$manifest_file"

echo "Favicons and related files generated in: $output_folder"
