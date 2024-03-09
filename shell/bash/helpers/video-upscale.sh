#!/bin/bash

# TODO: Implement resumable functionality to continue execution from the point of interruption

: '
Script to upscale a video using Real-ESRGAN-ncnn-vulkan w/wo TTA.
Requires ffmpeg and Real-ESRGAN-ncnn-vulkan.

It utilizes ffmpeg for extracting frames from the input video and reassembling the upscaled frames into the final output video.
With Real-ESRGAN-ncnn-vulkan each frame is upscaled to enhance its quality and sharpness.

References:
<https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan>
<https://ffmpeg.org>
'

# Configuration
input_video="input.mov"   # mp4, mov, mkv, avi, webm
output_video="output.mp4" # mp4, mov, mkv, avi, webm
frame_rate=30             # 24-60
model="realesrgan-x4plus" # realesrgan-x4plus, realesrgan-x2plus, realesrgan-x4, realesrgan-x2
upscale_factor=4          # 2-4
output_format="png"       # png, jpg, etc.

# NOTE: Test-Time Augmentation (TTA) Pros and Cons:
# - Pros: TTA can potentially improve the quality of the upscaled images by capturing different perspectives and variations,
#         resulting in reduced artifacts and increased sharpness.
# - Cons: Enabling TTA mode may significantly increase the processing time as it requires generating and processing multiple
#         augmented versions of the input image, which can be computationally intensive. Consider the available resources
#         and the desired trade-off between quality and processing time when deciding whether to enable TTA mode.
use_tta=true # Set to true to enable TTA, false otherwise

# Directory Paths
frames_dir="frames"
upscaled_frames_dir="upscaled_frames"

pre_checks() {
    command_exists "ffmpeg"
    command_exists "realesrgan-ncnn-vulkan"

    if [[ -d "$frames_dir" ]]; then
        printf "Warning: The frames directory already exists. Existing files may be overwritten.\n"
    else
        mkdir -p "$frames_dir"
    fi

    if [[ -d "$upscaled_frames_dir" ]]; then
        printf "Warning: The upscaled frames directory already exists. Existing files may be overwritten.\n"
    else
        mkdir -p "$upscaled_frames_dir"
    fi

    read -r -p "Do you want to proceed? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        exit
    fi
}

command_exists() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf "Error: '%s' command not found. Please install it and make sure it is in the system's PATH.\n" "$1" >&2
        exit 1
    fi
}

calculate_duration() {
    start_time=$1
    end_time=$2
    duration=$((end_time - start_time))
    printf "\nStep %s took %s seconds.\n\n" "$3" "$duration"
}

cleanup() {
    if [[ -d "$frames_dir" && -d "$upscaled_frames_dir" ]]; then
        read -r -p "Do you want to clean the temporary directories? (y/n): " confirm_cleanup
        if [[ $confirm_cleanup =~ ^[Yy]$ ]]; then
            rm -r "$frames_dir"
            rm -r "$upscaled_frames_dir"
            printf "Temporary directories cleaned.\n"
        else
            printf "Temporary directories not cleaned.\n"
        fi
    fi
}

extract_frames() {
    printf "\nExtracting frames from the original video...\n\n"
    ffmpeg -i "$input_video" -vf "fps=$frame_rate" "$frames_dir/frame_%04d.png"
}

upscale_frames() {
    tta_option=""
    if [[ "$use_tta" = true ]]; then
        tta_option="-x"
    fi

    printf "\nUpscaling frames using Real-ESRGAN-ncnn-vulkan...\n\n"
    total_frames=$(find "$frames_dir" -maxdepth 1 -type f -name "*.$output_format" | wc -l)
    current_frame=1

    for frame_path in "$frames_dir"/*."$output_format"; do
        upscaled_frame_path="$upscaled_frames_dir/$(basename "$frame_path")"

        realesrgan-ncnn-vulkan -i "$frame_path" -o "$upscaled_frame_path" -n "$model" -s "$upscale_factor" -f "$output_format" "$tta_option"

        progress=$((current_frame * 100 / total_frames))
        printf "Progress: [%-50s] %d%%\r" "$(printf '#%.0s' $(seq 1 $((progress / 2))))" "$progress"
        ((current_frame++))
    done
    printf "\n\n"
}

reassemble_video() {
    printf "\nReassembling the upscaled frames into a video...\n\n"
    ffmpeg -framerate "$frame_rate" -i "$upscaled_frames_dir/frame_%04d.$output_format" -i "$input_video" -c:v libx264 -c:a copy -crf 18 -preset slow "$output_video"
}

main() {
    pre_checks

    # Step 1: Extract frames from the original video
    start_time=$(date +%s)
    extract_frames
    end_time=$(date +%s)
    calculate_duration "$start_time" "$end_time" "1/3"

    # Step 2: Upscale each frame using Real-ESRGAN-ncnn-vulkan w/wo TTA
    start_time=$(date +%s)
    upscale_frames
    end_time=$(date +%s)
    calculate_duration "$start_time" "$end_time" "2/3"

    # Step 3: Reassemble the upscaled frames into an upscaled video
    start_time=$(date +%s)
    reassemble_video
    end_time=$(date +%s)
    calculate_duration "$start_time" "$end_time" "3/3"

    # Finalizing
    cleanup
}

main
