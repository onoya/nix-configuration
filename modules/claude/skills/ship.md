---
description: Analyze staged git changes, create a feature branch, commit with conventional commit format, and open a Pull Request following the repository's PR template. Use when the user says "ship it", "/ship", "open a PR for these changes", or wants to bundle staged work into a branch + PR.
argument-hint: <branch-name | feature-description>
---

# Ship Command

Analyze staged git changes, create a feature branch, commit with conventional commit format, and create a Pull Request following the repository's PR template.

## Usage
/ship [optional branch name or feature description]

## What it does
1. Reviews all staged git changes
2. Creates a new feature branch (auto-generated or custom name)
3. Commits changes using conventional commit format
4. Creates a Pull Request following .github/pull_request_template.md
5. Assigns the PR to self

## Examples
- `/ship`
- `/ship user-authentication`
- `/ship fix login validation`

## Requirements
- Must have staged changes in git
- GitHub CLI (gh) must be configured
- Repository must have a pull request template
