#!/bin/sh

# Variables
FILE_PATH="path/to/your/file"                    # Replace with the path to your file
CHANGE_CONTENT="Your change content"             # Replace with the content or changes to be applied
COMMIT_MESSAGE="Update file across all branches" # Commit message

# Function to apply changes to the file
apply_changes() {
	echo "$CHANGE_CONTENT" >"$FILE_PATH"
}

# Fetch all branches
git fetch --all

# Loop through all branches
for branch in $(git branch -r | grep -v '\->'); do
	branch_name=$(echo "$branch" | sed 's/origin\///')
	git checkout "$branch_name"
	apply_changes
	git add "$FILE_PATH"
	git commit -m "$COMMIT_MESSAGE"
	git push origin "$branch_name"
done

# Checkout back to the main branch
git checkout main
