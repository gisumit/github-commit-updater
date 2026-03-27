#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_FILE="$REPO_DIR/contributions.json"
DAYS_BACK="${1:-365}"
MIN_COMMITS="${2:-1}"
MAX_COMMITS="${3:-5}"

echo "🟩 GitHub Contribution Graph Filler"
echo "===================================="
echo "Filling $DAYS_BACK days with $MIN_COMMITS-$MAX_COMMITS commits per day"
echo ""

if [[ "$(uname)" == "Darwin" ]]; then
    date_cmd() { date -v-"${1}"d +%Y-%m-%d; }
else
    date_cmd() { date -d "$1 days ago" +%Y-%m-%d; }
fi

total_commits=0

for ((i = DAYS_BACK; i >= 0; i--)); do
    commit_date=$(date_cmd "$i")
    num_commits=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))

    for ((j = 1; j <= num_commits; j++)); do
        hour=$(( RANDOM % 14 + 8 ))
        minute=$(( RANDOM % 60 ))
        second=$(( RANDOM % 60 ))
        timestamp="${commit_date}T$(printf '%02d:%02d:%02d' $hour $minute $second)"

        python3 -c "
import json, os, random, string
path = '$DATA_FILE'
data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
entry = {
    'date': '$commit_date',
    'seq': $j,
    'id': ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
}
data.setdefault('contributions', []).append(entry)
data['last_updated'] = '$timestamp'
data['total'] = len(data['contributions'])
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"

        export GIT_AUTHOR_DATE="$timestamp"
        export GIT_COMMITTER_DATE="$timestamp"
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "contrib: $commit_date #$j" --quiet
        unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE

        total_commits=$((total_commits + 1))
    done

    printf "\r  Progress: day %d/%d (%s) — %d commits so far" \
        $((DAYS_BACK - i + 1)) $((DAYS_BACK + 1)) "$commit_date" "$total_commits"
done

echo ""
echo ""
echo "Done! Created $total_commits commits over $((DAYS_BACK + 1)) days."
echo ""
echo "Now push to GitHub:"
echo "  git push -u origin main"
