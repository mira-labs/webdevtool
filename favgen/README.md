# Favicon Generator Script

Author: Radical Rad
Email: rad@radicalrad.co.uk
Date: $(date +%Y-%m-%d)

## Description

This script is designed to generate favicons of various sizes from an input image. It creates a `head.html` file with link tags and generates a `manifest.json` file for a web application. The script allows customization of the app name, description, package name, and output folder. The input image must be at least 128x128 pixels in size. If the app description is not provided as an argument, the script will prompt the user to enter it.

## Prerequisites

- **ImageMagick:** Ensure that ImageMagick is installed on your system. You can download it [here](https://imagemagick.org/script/download.php). Follow the installation instructions for your platform.

## Installation

After you have cloned the repo to e.g. `webdevtool` folder:
```bash
cd webdevtoo/favgen
sudo cp favgen.sh /usr/local/bin/favgen
sudo chmod +x /usr/local/bin/favgen
```
And viola!

## Usage

```bash
./favicon.sh -i 'input_image.png' [-o output_folder] [-n 'app_name'] [-d] [-p 'package_name']
