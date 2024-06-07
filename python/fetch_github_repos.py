import os
import sys
import requests
import argparse

def fetch_repos(username):
    api_url = f'https://api.github.com/users/{username}/repos'
    response = requests.get(api_url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f'Failed to retrieve repositories: {response.status_code}')
        return []

def determine_repo_type(repo):
    if repo.get('fork'):
        return 'Fork'
    elif repo.get('mirror_url'):
        return 'Mirror'
    elif repo.get('is_template'):
        return 'Template'
    elif repo.get('archived'):
        return 'Archived'
    else:
        return 'Source'

def main():
    parser = argparse.ArgumentParser(description='Fetch GitHub repositories for a user.')
    parser.add_argument('-u', '--username', type=str, help='GitHub username')
    
    args = parser.parse_args()
    
    username = args.username or os.getenv('GITHUB_USERNAME')
    
    if not username:
        print('Error: GitHub username must be provided either as an argument or in the GITHUB_USERNAME environment variable.')
        sys.exit(1)
    
    repos = fetch_repos(username)
    
    if repos:
        for repo in repos:
            name = repo['name']
            description = repo['description'] or 'No description provided'
            repo_type = determine_repo_type(repo)
            
            print(f'Repo: {name}')
            print(f'Description: {description}')
            print(f'Type: {repo_type}')
            
            if repo.get('has_sponsors_listing'):
                print(f'Can be sponsored: Yes')
            
            if repo.get('language'):
                print(f'Language: {repo["language"]}')
                
            print()
    else:
        print('No repositories found or unable to fetch repositories.')

if __name__ == "__main__":
    main()
