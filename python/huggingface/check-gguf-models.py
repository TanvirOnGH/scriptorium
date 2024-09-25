import sys
import requests

Q_METHODS = ["Q2_K", "Q3_K_S", "Q3_K_M", "Q3_K_L", "Q4_0", "Q4_K_S", "Q4_K_M", "Q5_0", "Q5_K_S", "Q5_K_M", "Q6_K", "Q8_0"]
IMATRIX_Q_METHODS = ["IQ3_M", "IQ3_XXS", "Q4_K_M", "Q4_K_S", "IQ4_NL", "IQ4_XS", "Q5_K_M", "Q5_K_S"]

def check_model_files(username, model_repo):
    base_url = f"https://huggingface.co/{username}/{model_repo}/blob/main/"
    model_repo_base = model_repo.lower().replace('-gguf', '')
    
    urls = []
    for method in Q_METHODS:
        urls.append((f"{base_url}{model_repo_base}-{method.lower()}.gguf", method))
    for method in IMATRIX_Q_METHODS:
        urls.append((f"{base_url}{model_repo_base}-{method.lower()}-imat.gguf", method))
    
    for url, method in urls:
        response = requests.head(url)
        if response.status_code == 200:
            print(f"[{method}] Exists: {url}")
        else:
            print(f"[{method}] Not found: {url}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python app.py <username>/<model-repo>")
        sys.exit(1)
    
    arg = sys.argv[1]
    if '/' not in arg:
        print("Invalid argument format. Use <username>/<model-repo>")
        sys.exit(1)
    
    username, model_repo = arg.split('/')
    check_model_files(username, model_repo)
