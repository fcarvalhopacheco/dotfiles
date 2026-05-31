#!/usr/bin/env zsh
setopt errexit nounset pipefail

# Define upstream and local branch names
UPSTREAM_REPO="upstream"
UPSTREAM_BRANCH="master"
TEMP_BRANCH="update-upstream"
LOCAL_BRANCH="master"

# Fetch the latest changes from upstream
echo "🔄 Fetching latest changes from $UPSTREAM_REPO..."
git fetch "$UPSTREAM_REPO"

# Check if there are updates
UPDATES=$(git log --oneline "HEAD..$UPSTREAM_REPO/$UPSTREAM_BRANCH")

if [ -z "$UPDATES" ]; then
    echo "✅ No new updates from upstream. You're already up to date!"
    exit 0
else
    echo "🚀 New updates detected from upstream!"
fi

# Create a temporary branch to review updates safely
if git rev-parse --verify "$TEMP_BRANCH" >/dev/null 2>&1; then
    echo "Temporary branch already exists: $TEMP_BRANCH"
    echo "Delete it or inspect it before running this script again."
    exit 1
fi
git checkout -b "$TEMP_BRANCH" "$LOCAL_BRANCH"
# git reset --hard $UPSTREAM_REPO/$UPSTREAM_BRANCH
# echo "🛠️  Merged upstream changes into $TEMP_BRANCH"

# Show the changes
echo "🔍 Reviewing changes..."
git difftool "$LOCAL_BRANCH..$TEMP_BRANCH"

# # Ask the user to manually apply changes
# echo "💡 Do you want to apply specific changes? (y/n)"
# read -r APPLY_CHANGES
#
# if [[ "$APPLY_CHANGES" == "y" ]]; then
#     echo "📂 Enter the file paths you want to update (space-separated):"
#     read -r FILES_TO_APPLY
#
#     for FILE in $FILES_TO_APPLY; do
#         git checkout $TEMP_BRANCH -- "$FILE"
#     done
#
#     # Commit the selected changes
#     git add $FILES_TO_APPLY
#     git commit -m "Manually applied selected upstream updates"
# else
#     echo "⏩ Skipping changes. Exiting..."
#     git checkout $LOCAL_BRANCH
#     git branch -D $TEMP_BRANCH
#     exit 0
# fi
#
# # Merge selected changes into master
# git checkout $LOCAL_BRANCH
# git merge --no-ff $TEMP_BRANCH -m "Merged upstream updates"
# git push origin $LOCAL_BRANCH
#
# # Cleanup
# git branch -D $TEMP_BRANCH
#
# echo "🎉 Update complete! Your fork is now up to date with upstream while keeping your custom changes."
