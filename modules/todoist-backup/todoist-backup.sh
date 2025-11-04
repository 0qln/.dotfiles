#!/usr/bin/env bash
set -euo pipefail

#
# Todoist API: https://developer.todoist.com/api/v1/#tag/Backups
#

auth_header="Authorization: Bearer $TODOIST_TOKEN"

mkdir -p "$DIR"
if [$DIR -eq "/" || $DIR -eq "" ]; then
  echo "You shouldn't use root dir..."
  exit -1
fi

tmp_dir="$DIR/tmp"
mkdir -p "$tmp_dir"
config_dir="$tmp_dir/git-config"

git_config="$config_dir/.git-credentials"
mkdir -p "$config_dir"

download_dir="$DIR/var/downloads"
mkdir -p "$download_dir"

data_dir="$DIR/repo/data"
mkdir -p "$data_dir"

# Todoist creates backups daily, so we can just fetch that.
echo "Searching backups..."
backups=$(curl -X GET -H "$auth_header" "https://api.todoist.com/api/v1/backups")

# Most recent url is the first
backup=$(echo $backups | jq -r '.[0].url')
version=$(echo $backups | jq -r '.[0].version')
echo "Backup $version URL: $backup"

file="${backup#*file=}"
file="${file%%&*}"
file_abs="$download_dir/$file"
echo "Backup file: $file"

# Download the backup
echo "Downloading most recent backup..."
curl -L -o "$file_abs" -X GET -H "$auth_header" "$backup"

echo "Replacing data in $data_dir"

# Clean data dir and unzip the backup
rm -fr "$data_dir"
unzip "$file_abs" -d "$data_dir"

# Versioning
# TODO: this is'nt pure yet. The repo has to be set up manually. Automate this!
echo "Backing up changes..."
(
  cd "$data_dir" &&
    # Git config
    git config user.email "$GIT_EMAIL" &&
    git config user.name "$GIT_NAME" &&
    git config credential.helper "store --file=$git_config" &&
    echo "https://$GITHUB_NAME:$GITHUB_TOKEN@github.com" >"$git_config" &&

    # Git backup
    git add . &&
    git commit --allow-empty -m "Backup $version" &&
    git push -u origin master
)

# Clean up
echo "Cleaning up..."
rm -fr "$download_dir/*"
rm -fr "$tmp_dir/*"
