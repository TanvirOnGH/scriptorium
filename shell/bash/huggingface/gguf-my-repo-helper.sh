#!/bin/bash

# Script to fetch public and private models from a Hugging Face user and check for specific quantization methods

# Obtain Token from: <https://huggingface.co/settings/tokens>
# Need a token with read permission to access private models
# can be obtained from: <https://huggingface.co/settings/tokens/new?tokenType=read>

# Usage
# ./script.sh <USERNAME> <TOKEN> <MODEL_NAME> --show-url --download firefox
# `--show-url` and `--download firefox` are optional arguments

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required but not installed."
  exit 1
fi

# Default hardcoded Hugging Face user and API
DEFAULT_HF_USER="your_username_here"
DEFAULT_HF_TOKEN="your_token_here"

# Define quantization methods
Q_METHODS=("Q2_K" "Q3_K_S" "Q3_K_M" "Q3_K_L" "Q4_0" "Q4_K_S" "Q4_K_M" "Q5_0" "Q5_K_S" "Q5_K_M" "Q6_K" "Q8_0")
IMATRIX_Q_METHODS=("IQ3_M" "IQ3_XXS" "Q4_K_M" "Q4_K_S" "IQ4_NL" "IQ4_XS" "Q5_K_M" "Q5_K_S")

# Check if the user provided a username, token, and model name
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
  HF_USER="$1"
  HF_TOKEN="$2"
  MODEL_NAME="$3"
else
  HF_USER="$DEFAULT_HF_USER"
  HF_TOKEN="$DEFAULT_HF_TOKEN"
  MODEL_NAME="$1"
fi

# Check if the username, token, and model name are set
if [ -z "$HF_USER" ] || [ -z "$HF_TOKEN" ] || [ -z "$MODEL_NAME" ]; then
  echo "Error: No Hugging Face username, token, or model name provided."
  exit 1
fi

# Check if the fourth argument is provided and is --show-url
SHOW_URL=false
if [ "$4" = "--show-url" ]; then
  SHOW_URL=true
fi

# Check if the --download argument is provided
DOWNLOAD=false
BROWSER="xdg-open"
if [ "$4" = "--download" ]; then
  DOWNLOAD=true
  if [ -n "$5" ]; then
    BROWSER="$5"
  fi
elif [ "$5" = "--download" ]; then
  DOWNLOAD=true
  if [ -n "$6" ]; then
    BROWSER="$6"
  fi
fi

# Function to check if a file exists on Hugging Face
check_file_exists() {
  local url="$1"
  if curl --head --silent --fail -H "Authorization: Bearer $HF_TOKEN" "$url" > /dev/null; then
    echo "exists"
  else
    echo "does not exist"
  fi
}

# Function to download a file using the specified browser
download_file() {
  local url="$1"
  $BROWSER "$url"
}

# Check for quantization methods in the filtered models
echo "Quantization methods found for user $HF_USER models matching \"$MODEL_NAME\":"

for method in "${Q_METHODS[@]}"; do
  file_url="https://huggingface.co/${HF_USER}/${MODEL_NAME}-${method}-GGUF/resolve/main/${MODEL_NAME,,}-${method,,}.gguf"
  result=$(check_file_exists "$file_url")
  if [ "$SHOW_URL" = true ]; then
    echo "Quantization Method: $method $result ($file_url)"
  else
    echo "Quantization Method: $method $result"
  fi
  if [ "$DOWNLOAD" = true ] && [ "$result" = "exists" ]; then
    download_url="${file_url}?download=true"
    download_file "$download_url"
  fi
done

for method in "${IMATRIX_Q_METHODS[@]}"; do
  file_url="https://huggingface.co/${HF_USER}/${MODEL_NAME}-${method}-GGUF/resolve/main/${MODEL_NAME,,}-${method,,}-imat.gguf"
  result=$(check_file_exists "$file_url")
  if [ "$SHOW_URL" = true ]; then
    echo "Imatrix Quantization Method: $method $result ($file_url)"
  else
    echo "Imatrix Quantization Method: $method $result"
  fi
  if [ "$DOWNLOAD" = true ] && [ "$result" = "exists" ]; then
    download_url="${file_url}?download=true"
    download_file "$download_url"
  fi
done
