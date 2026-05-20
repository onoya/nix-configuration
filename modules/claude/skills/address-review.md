---
name: address-review
description: Read GitHub PR review comments and apply the suggested fixes — or push back with a valid technical reason. Accepts a PR URL, a single comment permalink, an `owner/repo#N` reference, or no argument (uses the current branch's PR). Use when the user says "address the review", "apply the PR feedback", "go through the review comments", or pastes a github.com PR / review-comment link asking you to act on it.
allowed-tools: mcp__github__get_pull_request, mcp__github__get_pull_request_comments, mcp__github__get_pull_request_reviews, mcp__github__get_pull_request_diff, mcp__github__get_pull_request_files, mcp__github__get_file_contents, Read, Edit, Write, Grep, Glob, Bash, Agent
argument-hint: <pr-url | comment-permalink | owner/repo#N | blank> e.g. 'https://github.com/org/repo/pull/42' or 'https://github.com/org/repo/pull/42#discussion_r1234567890' or just blank to use the current branch's PR
---

<objective>
Read one or more open review comments on a GitHub PR and act on each one: apply the fix, extend it to nearby issues when that genuinely improves the code, or push back with a valid technical reason. Bundle everything into a single commit at the end. Never push, never resolve threads.
</objective>

<quick_start>
Usage:
- `/address-review` — use the PR associated with the current branch
- `/address-review https://github.com/org/repo/pull/42` — address all open comments on that PR
- `/address-review https://github.com/org/repo/pull/42#discussion_r1234567890` — focus on a single review-comment thread
- `/address-review https://github.com/org/repo/pull/42#issuecomment-1234567890` — focus on a single top-level PR comment
- `/address-review org/repo#42` — short form for a full PR
</quick_start>

<workflow>

<step_1>
**Parse `$ARGUMENTS` and determine input mode**

Detect which shape the argument has. Extract `owner`, `repo`, `pr_number`, and optionally `comment_id` / `comment_kind` (`review` for `#discussion_r…`, `issue` for `#issuecomment-…`).

**Mode A — No argument**: derive the PR from the current branch.
1. Run `gh pr view --json number,headRefName,baseRefName,title,url,headRepositoryOwner,headRepository` via Bash.
2. If no PR exists for the current branch, stop and tell the user there's nothing to address — ask whether they meant to pass a URL.
3. Set `comment_id = null` (address all open comments).

**Mode B — Full PR URL or `owner/repo#N`**: address every open, in-range comment on the PR. Set `comment_id = null`.

**Mode C — Review-comment permalink** (`…/pull/N#discussion_rXXXX`): address that single thread (the root comment + its replies) only. Set `comment_kind = "review"`.

**Mode D — Top-level PR comment permalink** (`…/pull/N#issuecomment-XXXX`): address that single comment only. Set `comment_kind = "issue"`.

State the detected mode back to the user in one short sentence before proceeding (e.g. _"Addressing all open review comments on org/repo#42."_).
</step_1>

<step_2>
**Branch sync (only if a PR URL was provided)**

If you derived the PR from the current branch (Mode A), skip this step — you're already on the right branch.

Otherwise:
1. Run `git status --porcelain` via Bash. If there is **any** uncommitted change (staged, unstaged, or untracked that isn't ignored), STOP and tell the user:
   > _"Working tree has uncommitted changes. Commit or stash them before I switch to the PR branch."_
   Do **not** stash automatically.
2. Determine the PR's head branch and head repo (from the `gh pr view` JSON or the GitHub MCP `get_pull_request` response).
3. If the PR is from a fork, run `gh pr checkout <pr_number>` — `gh` handles the fork remote setup correctly.
4. If the PR is from the same repo, `git fetch origin <branch> && git checkout <branch> && git pull --ff-only`.
5. Confirm the branch in one line (e.g. _"Checked out `feat/login-validation` (PR #42)."_).
</step_2>

<step_3>
**Fetch PR context and comments — GitHub MCP first, fall back to `gh`**

Try GitHub MCP first. If any MCP call errors (server not running, tool not available, permission denied), silently fall back to the equivalent `gh` command and continue. Mention the fallback once to the user.

Fetch in parallel:
- PR metadata — `mcp__github__get_pull_request` → fallback `gh pr view <n> --json title,body,state,headRefName,baseRefName,isDraft,author,url`
- Review comments (inline) — `mcp__github__get_pull_request_comments` → fallback `gh api repos/{owner}/{repo}/pulls/{n}/comments --paginate`
- Reviews (summary bodies + state) — `mcp__github__get_pull_request_reviews` → fallback `gh api repos/{owner}/{repo}/pulls/{n}/reviews --paginate`
- Top-level PR comments — `gh api repos/{owner}/{repo}/issues/{n}/comments --paginate` (these are issue comments on the PR)
- Files + patches — `mcp__github__get_pull_request_files` → fallback `gh pr diff <n>`

**Filter the comments to act on:**

- **Skip resolved threads.** A review thread is resolved when GraphQL `pullRequest.reviewThreads.nodes[].isResolved == true`. With `gh`, query:
  ```
  gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{isResolved comments(first:50){nodes{databaseId}}}}}}}' -F o=<owner> -F r=<repo> -F n=<pr_number>
  ```
  Map each `databaseId` → resolution state, then drop any inline comment whose thread is resolved.
- **Skip outdated comments.** A review comment is outdated when its `position` field is `null` (GitHub nulls it once the diff hunk no longer exists). Drop these.
- **Skip bot noise.** Drop comments whose author type is `Bot` unless the user explicitly said to address them.
- **Single-comment modes (C/D):** filter down to just that comment plus any replies in the same thread (for review comments) or just that comment (for issue comments).
- **De-duplicate:** if multiple reviewers said the same thing in the same spot, treat as one item.

If after filtering there is **nothing to address**, stop and tell the user — don't fabricate work.
</step_3>

<step_4>
**Triage each comment — Apply, Extend, or Push back**

For each remaining comment, build a small dossier before deciding:
1. Read the file at the commented line range. Read enough surrounding context to understand the local logic (not just the exact lines).
2. Read the original change in the PR diff for that file so you understand what the reviewer was reacting to.
3. If the comment references other files/symbols (e.g. "we already have a helper for this in X"), `Grep`/`Read` those too.

Then classify the comment into exactly one of three decisions:

- **APPLY** — the suggestion is correct or clearly an improvement. Make the change.
- **EXTEND** — the suggestion is correct, AND while reading the surrounding code you spot related issues the reviewer didn't mention that fixing alongside genuinely improves quality (e.g. the same anti-pattern repeats two lines down, an obvious dead branch, a missing null-check on the same path). Fix those too, but stay scoped to the immediate vicinity — do not start a refactor tour.
- **PUSH BACK** — apply ONLY when there is a real technical reason the suggestion is wrong or worse than the current code. Valid reasons include: the suggestion would introduce a bug, race, regression, or security issue; it conflicts with a documented project convention (CLAUDE.md, lint rules, ADRs); it misreads the code (the "issue" doesn't actually exist); it contradicts a different reviewer's accepted suggestion; the cost/benefit is clearly wrong for this codebase. **Not valid reasons:** personal taste, "I think mine is cleaner", "it's just a nit anyway", laziness, or wanting to avoid the work.

If you're uncertain whether to apply or push back, default to **APPLY** — the reviewer has context you don't.
</step_4>

<step_5>
**Apply the fixes**

For every APPLY and EXTEND item:
- Use `Edit` (or `Write` for new files) to make the change.
- Match existing code style — indentation, naming, import order — by reading the file first.
- If a comment includes a GitHub _suggestion block_ (```` ```suggestion ````), use it as the literal replacement for the commented lines unless it's syntactically wrong for the surrounding context.
- After editing a file, re-read the edited region to confirm the change looks right in context.
- If the project has obvious lint/typecheck commands you can see in `package.json`, `Makefile`, `flake.nix`, etc., run them at the end across the touched files and fix anything you broke. Do NOT run the full test suite unless the user asks — that's their call.

Do **not** commit yet — one commit at the end covers everything.
</step_5>

<step_6>
**Handle push-backs — user approval gate, then post**

Collect all PUSH BACK items. Present them to the user **before** posting anything:

```
Push-back drafts (your approval required before posting):

[1] org/repo#42 — src/auth/login.ts:88 — @reviewer
    Reviewer said: "Wrap this in a try/catch so the request never throws."
    My push-back: The caller already wraps this in a request-scoped error
    boundary (src/middleware/error.ts:14) which converts thrown errors into
    structured 5xx responses. Adding a try/catch here would swallow the
    error before that boundary sees it and break the existing observability
    pipeline that depends on those thrown errors.
    → Post / Skip / Edit?
```

Wait for the user's call on each. For any they approve:

- **For review (inline) comments** — reply in the same thread so it threads correctly:
  ```
  gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
    -f body="<reply text>"
  ```
- **For top-level PR (issue) comments**:
  ```
  gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
    -f body="<reply text>"
  ```

Write replies as the PR author — first person, technical, no apologies for disagreeing, no footer identifying this as automated. If the user edits the wording, use their version verbatim.

**Do not resolve any threads.** Resolution is the reviewer's call.
</step_6>

<step_7>
**Commit (one commit, no push)**

If any files were changed in step 5:
1. `git status` to confirm what changed.
2. `git add` only the files you modified — do not blanket-add untracked files.
3. Commit with a single message of the form:
   ```
   address review feedback on <PR title>

   - <short description of fix 1> (file:line)
   - <short description of fix 2> (file:line)
   - …
   ```
   Keep bullets terse — file paths and one-line summaries. Use `git commit -m` with a HEREDOC for multi-line.
4. **Do not push.** Tell the user it's committed locally and they can push or run `/ship` when ready.

If no files were changed (everything was a push-back or skip), don't make an empty commit.
</step_7>

<step_8>
**Final report**

Print a compact summary so the user can verify at a glance:

```
Address-review summary — org/repo#42
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

APPLIED   (3)
  • src/auth/login.ts:88 — replaced manual JWT decode with verifyToken() helper
  • src/auth/login.ts:104 — early-return on missing session (extended: same pattern at :119)
  • src/api/users.ts:42 — typo in error message

PUSHED BACK   (1, 1 posted)
  • src/middleware/cache.ts:22 — kept TTL at 60s; explained interaction with edge cache

SKIPPED   (2)
  • src/db/query.ts:88 — thread resolved
  • src/utils/format.ts:14 — comment is outdated (position null)

Commit: 7f3a91c "address review feedback on Add login validation"
Not pushed. Run `git push` or `/ship` when ready.
```
</step_8>

</workflow>

<anti_patterns>
- NEVER push to the remote — committing is the end of this skill's job.
- NEVER resolve a review thread on GitHub. The reviewer resolves; you don't.
- NEVER auto-stash uncommitted changes when switching branches — refuse and let the user decide.
- NEVER push back on style preferences, taste, or "I'd have done it differently." Push-back requires a real technical reason.
- NEVER post a push-back reply without showing the draft to the user first.
- NEVER mark a comment as addressed in the report unless you actually changed the code or posted a reply.
- NEVER create one commit per comment. One commit at the end, with a bullet list.
- NEVER use `git add -A` or `git add .` — stage only the files you touched.
- NEVER add a footer like "— sent by Claude" or otherwise mark replies as automated. Write as the PR author.
- NEVER include a `Co-Authored-By: Claude` trailer or any other tool attribution in the commit message.
- NEVER edit code in a file you haven't read first.
- DO NOT run the full test suite or open a dev server — out of scope.
- DO NOT touch comments on PRs you don't own without asking the user first.
</anti_patterns>

<tips>
**Resolving the GraphQL `databaseId` → REST `id`:** the `databaseId` returned by the GraphQL `reviewThreads` query matches the `id` field on REST review comments. Build a `Set<number>` of resolved comment IDs once, then filter in O(1).

**Distinguishing comment kinds from a permalink:**
- `#discussion_rXXXX` → REST review comment, endpoint `/pulls/{n}/comments/{id}`, replies via `/pulls/{n}/comments/{id}/replies`.
- `#issuecomment-XXXX` → REST issue comment on the PR, endpoint `/issues/{n}/comments/{id}`, no threaded replies (post a new issue comment).
- `#pullrequestreview-XXXX` → top-level review body; treat the review body as a single comment, reply with an issue comment.

**Single-thread mode and replies:** when the user passed a `#discussion_r…` link, also fetch the thread's existing replies (`gh api repos/{o}/{r}/pulls/comments/{id}` returns the root; replies are fetched via `gh api repos/{o}/{r}/pulls/{n}/comments` then filter by `in_reply_to_id`). Read replies before deciding — sometimes the reviewer already walked back their own suggestion.

**Fork PRs:** `mcp__github__get_pull_request` returns `head.repo` info; if the head repo owner differs from the base repo owner, `gh pr checkout <n>` is the only sane way to land on the right branch with the right remote.

**Suggestion blocks:** if a comment body contains ```` ```suggestion ```` blocks, GitHub's UI applies them by replacing lines `original_start_line..original_line` in the commented file. Mirror that mapping exactly.

**Avoid double work:** when you finish applying fixes, re-read each touched file region once to confirm — cheaper than running the test suite and catches the obvious "I edited the wrong line" mistakes.
</tips>

<edge_cases>
- **PR already merged or closed:** stop and tell the user. Don't apply changes to a merged PR's branch.
- **PR is a draft:** proceed as normal, but mention it in the final report so the user remembers.
- **Comments include code suggestions that span removed lines:** the suggestion block won't apply cleanly — read the current file, understand the intent, and write the equivalent change manually.
- **Two reviewers contradict each other on the same line:** don't pick a winner silently. Surface the conflict to the user and ask which to follow.
- **Comment references a file not in this PR's diff** (e.g. "while you're here, also fix X over in module Y"): treat as out of scope by default; mention in the SKIPPED section with reason "out of PR scope — open a follow-up?".
- **Empty comment body / emoji-only / "lgtm" / "👍":** skip, no action needed.
- **Comment is a question, not a suggestion** (e.g. "why did you do it this way?"): default to push-back mode — draft a short answer, get user approval, post it. Don't change code.
- **No `gh` auth and no MCP available:** stop and tell the user to run `gh auth login`.
- **Branch switch would lose detached-HEAD work:** the `git status --porcelain` check in step 2 catches uncommitted changes, but detached HEAD with committed-but-unreferenced work is its own trap. If `git symbolic-ref HEAD` fails, refuse and tell the user.
</edge_cases>
