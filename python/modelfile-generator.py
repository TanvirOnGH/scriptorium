import os
import re


def generate_modelfile(
    model_name,
    tags,
    description=None,
    prompt_template=None,
    repo=None,
    from_path=None,
    template=None,
    system=None,
    parameters=None,
    project_path="/path/to/your/modelfiles",
):
    """Generates an Ollama modelfile based on provided information.

    Args:
        model_name (str): Name of the model, including size (e.g., "MyModel:7B").
        tags (list): List of tags for the model (e.g., ["General", "Chat"]).
        description (str, optional): Description of the model. Defaults to None.
        prompt_template (str, optional): Name of the prompt template. Defaults to None.
        repo (str, optional): URL of the model repository. Defaults to None.
        from_path (str, optional): Path to the model file within the Ollama directory. Defaults to None. Required.
        template (str, optional): Ollama template string. Defaults to None. Required.
        system (str, optional): System prompt for the model. Defaults to None.
        parameters (dict, optional): Dictionary of Ollama parameters. Defaults to None.
        project_path (str, optional): Path to save the modelfile. Defaults to "/path/to/your/modelfiles".

    Returns:
        str: Path to the generated modelfile.

    Raises:
        ValueError: If `from_path` or `template` are not provided.
    """

    if not from_path or not template:
        raise ValueError("`from_path` and `template` are required arguments.")

    modelfile_content = f"# {model_name}\n"
    if tags:
        modelfile_content += f"# TAGS: {', '.join(tags)}\n"
    if description:
        modelfile_content += f"# DESCRIPTION: {description}\n"
    if prompt_template:
        modelfile_content += f"# Prompt Template: {prompt_template}\n"
    if repo:
        modelfile_content += f"# REPO: {repo}\n"
    modelfile_content += f"\n"

    modelfile_content += f"FROM {from_path}\n\n"

    modelfile_content += f'TEMPLATE """{template}"""\n\n'

    if system:
        modelfile_content += f'SYSTEM """{system}"""\n\n'

    if parameters:
        for key, value in parameters.items():
            modelfile_content += f"PARAMETER {key} {value}\n"

    filename = model_name.replace(":", "-") + ".modelfile"
    filepath = os.path.join(project_path, filename)
    with open(filepath, "w") as f:
        f.write(modelfile_content)

    return filepath


# Example Usage (replace with your paths and model info):
model_info = {
    "model_name": "MyOtherModel:7B",
    "tags": ["Coding", "Python"],
    "from_path": "/mnt/another/drive/models/myothermodel-7b.gguf",
    "template": """{{ .Prompt }}""",
    "project_path": "/home/me/my_models",
    "parameters": {
        "temperature": 0.2,
        "seed": 42,
    },
}

created_file_path = generate_modelfile(**model_info)
print(f"Modelfile created at: {created_file_path}")
