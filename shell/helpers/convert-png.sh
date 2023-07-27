#!/bin/sh

# Converts all images of any format to png ensuring each converted image has a unique name.
# Required: ImageMagick

convert *.* output-%d.png
