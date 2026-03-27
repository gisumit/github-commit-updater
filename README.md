# GitHub Contribution Graph Filler

Make your GitHub contribution graph solid green. Creates backdated commits to fill every day in your history.

## Quick Start

```bash
# Fill the last 365 days with 1-5 random commits per day
./contribute.sh

# Push to GitHub
git push -u origin main
```

## Options

```bash
./contribute.sh [DAYS_BACK] [MIN_COMMITS] [MAX_COMMITS]
```

| Argument | Default | Description |
|---|---|---|
| `DAYS_BACK` | 365 | Number of days to go back |
| `MIN_COMMITS` | 1 | Minimum commits per day |
| `MAX_COMMITS` | 5 | Maximum commits per day |

### Examples

```bash
# Light green everywhere (subtle)
./contribute.sh 365 1 2

# Medium intensity
./contribute.sh 365 2 5

# Full dark green (go big or go home)
./contribute.sh 365 5 10
```

## How It Works

The script creates real git commits with backdated timestamps (`GIT_AUTHOR_DATE` / `GIT_COMMITTER_DATE`). GitHub uses the author date to place commits on the contribution graph. Each commit updates a `contributions.json` file with a unique entry.

## Requirements

- Git
- Bash
- Python 3 (for JSON file updates)

## Reset

To start fresh, delete the repo and re-clone, or:

```bash
git checkout --orphan fresh
git add -A
git commit -m "reset"
git branch -D main
git branch -m main
git push -f origin main
```
