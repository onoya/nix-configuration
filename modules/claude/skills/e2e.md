---
name: e2e
description: Run E2E tests using Playwright MCP. Navigates pages, interacts with elements, asserts outcomes, and reports results. Use when the user says "run e2e test", "test the UI", "browser test", "playwright test", "e2e test", "check the page", "test this flow", or wants to verify UI behavior in a browser.
allowed-tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_fill_form, mcp__playwright__browser_hover, mcp__playwright__browser_select_option, mcp__playwright__browser_press_key, mcp__playwright__browser_wait_for, mcp__playwright__browser_console_messages, mcp__playwright__browser_network_requests, mcp__playwright__browser_tabs, mcp__playwright__browser_navigate_back, mcp__playwright__browser_close, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_evaluate, mcp__playwright__browser_file_upload, mcp__playwright__browser_resize, mcp__playwright__browser_run_code, mcp__playwright__browser_drag, mcp__playwright__browser_drop, mcp__github__get_pull_request, mcp__github__get_pull_request_files, mcp__github__get_pull_request_diff, Read, Grep, Glob, Bash, Agent
argument-hint: <url | pr-url | blank> [test-scenario] e.g. 'http://localhost:3000 test login' or 'https://github.com/org/repo/pull/42' or just run with no args to test current branch changes
---

<objective>
Run interactive E2E tests against a web application using Playwright MCP. Navigate pages, interact with UI elements, verify expected behavior, catch errors, and report clear pass/fail results.
</objective>

<quick_start>
Usage:
- `/e2e` — auto-detect changes on current branch and test them
- `/e2e http://localhost:3000` — explore the page and run a general health check
- `/e2e http://localhost:3000 test the login flow` — run a specific test scenario
- `/e2e https://github.com/org/repo/pull/42` — derive test scenarios from PR description and changed files
- `/e2e https://github.com/org/repo/pull/42 http://localhost:3000` — PR-driven test against a specific URL
</quick_start>

<workflow>

<step_1>
**Parse arguments and determine input mode**

`$ARGUMENTS` can be one of four input modes. Detect which one:

**Mode A — PR URL** (e.g., `https://github.com/org/repo/pull/42` or `org/repo#42`):
If the argument matches a GitHub PR URL or `owner/repo#number` pattern:
1. Extract the PR using `gh pr view <url-or-number> --json title,body,files` via Bash
2. Read the PR **title and description** to understand what was changed and why
3. Read the **changed files list** to identify UI-affecting changes (components, pages, routes, styles, API endpoints)
4. From the PR context, generate a list of test scenarios — what user-facing behavior should be verified?
5. If a second argument is a URL (e.g., `https://github.com/org/repo/pull/42 http://localhost:3000`), use it as the target. Otherwise, ask the user for the dev server URL.

**Mode B — No arguments** (current branch changes):
If `$ARGUMENTS` is empty:
1. Run `git diff main...HEAD --name-only` (or `master` if `main` doesn't exist) via Bash to get all changed files on the current branch
2. If there are no changes vs the base branch, fall back to `git diff --name-only` for uncommitted changes
3. Read the changed files to understand what was modified — focus on UI components, pages, routes, styles, API endpoints
4. Run `git log main..HEAD --oneline` to understand the intent from commit messages
5. From the change context, generate test scenarios for the affected features
6. Ask the user for the dev server URL if not obvious from context

**Mode C — Direct URL** (e.g., `http://localhost:3000`):
If the argument starts with `http://`, `https://`, or `localhost` and is NOT a GitHub URL:
1. Use it as the target URL
2. Everything after the URL is the test scenario description
3. If no scenario is provided, run a **general health check** (page loads, no console errors, no failed network requests, interactive elements accessible)

**Mode D — Scenario only** (e.g., `test the login flow`):
If the argument is plain text with no URL:
1. Treat it as a test scenario description
2. Ask the user for the dev server URL, or check project context for common ports (3000, 5173, 4321, 8080)

**For Modes A and B — generating test scenarios from code changes:**

Analyze the changed files to determine what to test:
- **Component changes** (`.tsx`, `.jsx`, `.vue`, `.svelte`) → test the UI that renders that component
- **Route/page changes** → navigate to that route and verify it renders correctly
- **Form changes** → test form fill, validation, and submission
- **API endpoint changes** → test the UI that calls that endpoint, verify request/response
- **Style changes** → visual check that the page renders correctly (screenshot comparison)
- **State/store changes** → test the user flows that depend on that state
- **Auth changes** → test login/logout/protected routes

Present the generated test plan to the user before executing:
```
Test plan derived from [PR #42 / current branch changes]:
1. Test the updated login form validation (src/components/LoginForm.tsx changed)
2. Verify the new dashboard widget renders (src/pages/Dashboard.tsx added)
3. Check the API error handling in settings page (src/api/settings.ts changed)

Target URL: [ask if unknown]
Proceed? (or modify the plan)
```
</step_1>

<step_2>
**Pre-flight: Navigate and establish baseline**

1. **Navigate** to the target URL using `browser_navigate`
2. **Wait for stability** — use `browser_wait_for` with a short delay (1-2 seconds) to let async content render
3. **Take initial snapshot** using `browser_snapshot` to get the accessibility tree
4. **Check console** using `browser_console_messages` (level: "error") for any JS errors on load
5. **Check network** using `browser_network_requests` for failed requests (4xx/5xx status codes)

If the page fails to load or shows critical errors, report immediately and stop.

**Report baseline status:**
```
Pre-flight check:
- Page loaded: YES/NO
- Console errors: N found
- Failed network requests: N found
- Interactive elements discovered: N
```
</step_2>

<step_3>
**Discover page structure**

Use the `browser_snapshot` result to understand the page:
- Identify all interactive elements (buttons, links, inputs, forms)
- Note elements with `data-testid` attributes (these are test-friendly)
- Note elements that LACK `data-testid` but are key interaction targets
- Map out the page's navigation structure (nav bars, menus, tabs)

**IMPORTANT — Snapshot-first targeting:**
- ALWAYS use `browser_snapshot` to get exact element refs (`ref=` values) before interacting
- NEVER guess at selectors — the snapshot gives you the truth
- After ANY navigation or state change, take a NEW snapshot before the next interaction
- Prefer targeting by `ref=` from snapshot, then by `data-testid`, then by role+name
</step_3>

<step_4>
**Execute test scenario**

Based on the user's scenario description (or general health check), execute interactions:

**For each interaction:**
1. Take a `browser_snapshot` to get current element refs
2. Identify the target element from the snapshot
3. Perform the action (`browser_click`, `browser_type`, `browser_fill_form`, etc.)
4. Wait for the result — use `browser_wait_for` if expecting text to appear/disappear
5. Take a post-action `browser_snapshot` to verify the state changed
6. Check `browser_console_messages` (level: "error") for new errors after the action
7. Check `browser_network_requests` for failed API calls if the action triggers requests

**Common test patterns:**

*Navigation test:*
- Click each nav link
- Verify the correct page/content loads
- Verify the URL changed appropriately
- Check for console errors on each page

*Form test:*
- Fill form fields using `browser_fill_form` or `browser_type`
- Submit the form
- Verify success/error messages appear
- Check network requests for the form submission

*Authentication test:*
- Navigate to login page
- Fill credentials
- Submit and verify redirect to authenticated page
- Verify authenticated state (user menu, protected content visible)

*CRUD test:*
- Create: Fill form, submit, verify item appears in list
- Read: Navigate to list, verify items display correctly
- Update: Click edit, modify fields, save, verify changes
- Delete: Click delete, confirm dialog, verify item removed
</step_4>

<step_5>
**Assert and verify outcomes**

For each test step, verify:

1. **Visual state** — Use `browser_snapshot` to confirm expected elements/text are present
2. **Console health** — No new errors in `browser_console_messages`
3. **Network health** — No failed requests in `browser_network_requests`
4. **URL state** — Verify navigation changed the URL as expected (visible in snapshot)
5. **Element state** — Buttons disabled/enabled, inputs populated, modals open/closed

**When an assertion fails:**
- Take a `browser_screenshot` for visual evidence
- Capture console errors
- Capture relevant network requests (with response bodies if helpful)
- Note the exact step that failed and why
- Continue with remaining tests unless the failure is blocking
</step_5>

<step_6>
**Report results**

Provide a clear summary. Adapt the header based on input mode:

```
E2E Test Results: [scenario name]
Source: [PR #42: "Add login form validation" | branch: feat/login-validation | direct URL]
URL: [target URL]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PASS  Page loads without errors
PASS  Navigation to /dashboard works
FAIL  Login form submission — expected redirect to /dashboard, got error toast "Invalid credentials"
PASS  Sidebar links are all accessible
SKIP  Admin panel — requires admin role

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Results: 3 passed, 1 failed, 1 skipped

Issues found:
1. [FAIL] Login form: Error toast "Invalid credentials" appeared after submission
   - Console: POST /api/auth/login returned 401
   - Suggestion: Check if test credentials are correct or if the API is running

DX Improvements recommended:
1. Add data-testid="login-submit-btn" to the login submit button (src/components/LoginForm.tsx:42)
2. Add data-testid="nav-sidebar" to the sidebar container (src/layouts/MainLayout.tsx:18)
```

**For PR-driven tests**, also note which PR requirements were verified vs not:
```
PR Requirements Coverage:
- [x] "Form validates email format" — verified, validation error shown for invalid input
- [x] "Submit disabled until form valid" — verified, button disabled state confirmed
- [ ] "Error toast on server error" — could not test, API returned 200 for all attempts
```

**DX improvement suggestions:**
When elements are hard to target (no `data-testid`, generic class names, deeply nested), use `Grep` and `Glob` to find the source component and suggest adding `data-testid` attributes. Show the exact file, line, and suggested change.
</step_6>

<step_7>
**Cleanup**

After all tests are complete:
1. Close the browser using `browser_close`
2. Summarize any `data-testid` additions you recommend
3. If the user agrees, make the `data-testid` changes to the source code directly
</step_7>

</workflow>

<anti_patterns>
- NEVER guess at element selectors — always snapshot first, then use exact refs
- NEVER skip the post-action snapshot — state changes need verification
- NEVER ignore console errors — they often reveal the real issue behind a visual failure
- NEVER take screenshots as the primary way to understand the page — use `browser_snapshot` (accessibility tree) for element targeting, screenshots only for visual evidence of failures
- NEVER hard-code wait times longer than 5 seconds — if something takes that long, investigate why
- NEVER fill forms field-by-field when `browser_fill_form` can do it in one call
- NEVER continue a multi-step flow after a blocking failure (e.g., login failed → skip dashboard tests)
- DO NOT start a dev server — the user manages their own dev server
- DO NOT modify application code without asking — suggest `data-testid` additions but let the user approve
</anti_patterns>

<tips>
**Element targeting priority:**
1. `ref=` from `browser_snapshot` — most reliable, always fresh
2. `[data-testid="..."]` — stable across renders, test-friendly
3. Role + name (e.g., button "Submit") — semantic, resilient to refactors
4. Text content — fragile, breaks on copy changes

**Handling dynamic content:**
- Use `browser_wait_for` with expected text before asserting
- Use `browser_wait_for` with `textGone` for loading spinners/skeletons
- Take snapshot AFTER waits complete, not before

**Debugging failures:**
- `browser_console_messages` with level "debug" gives you everything
- `browser_network_requests` with `requestBody: true` shows what was sent
- `browser_evaluate` can inspect JavaScript state directly (localStorage, cookies, app state)
- `browser_take_screenshot` captures what the user would actually see

**Multi-page flows:**
- Use `browser_tabs` to manage multiple pages if needed (e.g., email verification links)
- Use `browser_navigate_back` for back-button behavior tests
- Always re-snapshot after navigation — refs from the old page are stale
</tips>

<edge_cases>
- **Auth-gated pages**: If a page redirects to login, test the login flow first, then continue to the protected page
- **Modals and dialogs**: After clicking a trigger, wait briefly then snapshot — modals may animate in
- **SPAs with client-side routing**: URL may not change immediately — wait for content, not URL
- **Infinite scroll / lazy loading**: Scroll to trigger loads using `browser_evaluate` with `window.scrollTo()`
- **Browser dialogs (alert/confirm/prompt)**: Use `browser_handle_dialog` — these block all other interactions until dismissed
- **File uploads**: Use `browser_file_upload` with absolute paths
- **Responsive layouts**: Use `browser_resize` before testing mobile vs desktop layouts
</edge_cases>
