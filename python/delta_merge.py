import argparse
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import numpy as np

# Code from: <https://github.com/StableFluffy/EasyLLMFeaturePorter/blob/main/1-Click.ipynb>
# Converted into CLI by Jioh L. Jung <https://gist.github.com/ziozzang>
# Gist: <https://gist.github.com/ziozzang/45bd1f600472204101c00f0a3d9efa60>

# Usage: python convert.py [informative_model_path] [base_model_path] [target_model_path] [output_path]


def calculate_weight_diff(a, b):
    return a - b


def calculate_model_diffs(model_a, model_b):
    model_a_dict = model_a.state_dict()
    model_b_dict = model_b.state_dict()
    model_diffs = {}
    for key in model_a_dict.keys():
        if key in model_b_dict:
            model_diffs[key] = calculate_weight_diff(
                model_a_dict[key], model_b_dict[key]
            )
            print(f"Diff calculated for {key}")
    return model_diffs


def calculate_sigmoid_ratios(base_model, target_model, epsilon=1e-6):
    sigmoid_ratios = {}
    target_diff = calculate_model_diffs(target_model, base_model)
    for key in target_diff.keys():
        diff_tensor = abs(target_diff[key])
        diff_min = diff_tensor.min().item()
        diff_max = diff_tensor.max().item()
        print(f"Key: {key}")
        print(f"  Diff Min: {diff_min}")
        print(f"  Diff Max: {diff_max}")

        if abs(diff_max - diff_min) < epsilon:
            print(f"  All values are the same. Setting sigmoid_diff to 0.")
            sigmoid_diff = torch.zeros_like(diff_tensor)
        else:
            normalized_diff = (diff_tensor - diff_min) / (diff_max - diff_min)
            sigmoid_diff = torch.sigmoid(normalized_diff * 12 - 6)
        sigmoid_ratios[key] = sigmoid_diff
        print(f"  Sigmoid Diff Min: {sigmoid_diff.min().item()}")
        print(f"  Sigmoid Diff Max: {sigmoid_diff.max().item()}")
    return sigmoid_ratios


def apply_model_diffs(target_model, model_diffs, sigmoid_ratios):
    target_state_dict = target_model.state_dict()
    for key in model_diffs.keys():
        print(key)
        print(model_diffs[key])
        ratio = sigmoid_ratios[key]
        print(ratio)
        scaled_diff = model_diffs[key] * (1 - ratio)
        target_state_dict[key] += scaled_diff
        print(f"Diff applied for {key}")
    target_model.load_state_dict(target_state_dict)


def main(informative_model_path, base_model_path, target_model_path, output_path):
    # Load Models
    informative_model = AutoModelForCausalLM.from_pretrained(informative_model_path)
    base_model = AutoModelForCausalLM.from_pretrained(base_model_path)
    target_model = AutoModelForCausalLM.from_pretrained(target_model_path)

    # Load Tokenizer
    tokenizer = AutoTokenizer.from_pretrained(target_model_path)

    print("Calculating model diffs...")
    model_diffs = calculate_model_diffs(informative_model, base_model)
    print("Model diffs calculated.")

    print("Calculating sigmoid ratios...")
    sigmoid_ratios = calculate_sigmoid_ratios(base_model, target_model)
    print("Sigmoid ratios calculated.")

    print("Applying model diffs...")
    apply_model_diffs(target_model, model_diffs, sigmoid_ratios)
    print("Model diffs applied.")

    print("Saving target model and tokenizer...")
    target_model.save_pretrained(output_path)
    tokenizer.save_pretrained(output_path)
    print("Target model and tokenizer saved.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert model weights")
    parser.add_argument(
        "informative_model_path", type=str, help="Path to the informative model"
    )
    parser.add_argument("base_model_path", type=str, help="Path to the base model")
    parser.add_argument("target_model_path", type=str, help="Path to the target model")
    parser.add_argument(
        "output_path", type=str, help="Path to save the converted model"
    )
    args = parser.parse_args()

    main(
        args.informative_model_path,
        args.base_model_path,
        args.target_model_path,
        args.output_path,
    )
