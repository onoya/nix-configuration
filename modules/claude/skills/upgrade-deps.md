---
name: upgrade-deps
description: Upgrades 3rd party dependencies across a project. Detects the package manager (pnpm, npm, yarn, nix flake), identifies outdated packages, skips pinned versions, groups related packages, and upgrades them in batches with verification. Use when the user says "upgrade dependencies", "update packages", "upgrade libs", "update deps", or wants to bring dependencies up to date.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, Agent
argument-hint: "[package-filter] e.g. 'aws' or 'react' or leave blank for all"
---

<objective>
Upgrade 3rd party dependencies in the current project. Detect the package manager, skip pinned packages, group related packages together, verify each batch, and commit each batch separately for easy rollback.
</objective>

<quick_start>
Usage:
- `/upgrade-deps` — scan and upgrade all outdated dependencies
- `/upgrade-deps aws` — only upgrade packages matching "aws"
- `/upgrade-deps react` — only upgrade React-related packages
</quick_start>

<workflow>

<step_1>
**Detect the project type and package manager**

Check the current working directory for:
- `flake.nix` → **Nix flake** project (use `nix flake update` / `nix flake lock --update-input`)
- `pnpm-lock.yaml` or `pnpm-workspace.yaml` → **pnpm** (use `pnpm outdated`, `pnpm update`)
- `yarn.lock` → **Yarn** (use `yarn outdated`, `yarn upgrade`)
- `package-lock.json` → **npm** (use `npm outdated`, `npm update`)
- `package.json` alone → **npm** (fallback)

If multiple signals exist, prefer: pnpm > yarn > npm (lock file wins).

For monorepos (pnpm workspaces, yarn workspaces, or nx), discover all workspace `package.json` files.
</step_1>

<step_2>
**Identify pinned packages to skip**

**For Node.js projects (npm/pnpm/yarn):**

A package is **pinned** if its version string is an exact version with NO range prefix — i.e., it does NOT start with `^`, `~`, `>=`, `>`, `<`, or `*`. Examples:
- `"1.2.3"` → pinned (exact version, skip it)
- `"^1.2.3"` → NOT pinned (has caret range, eligible for upgrade)
- `"~1.2.3"` → NOT pinned (has tilde range, eligible for upgrade)

**For Nix flakes:**
- All inputs are eligible for update unless the user specifies otherwise
- Inputs pinned to a specific rev/tag in `flake.nix` should be flagged but still included (they update within their constraints)

Additionally, **always check Claude's memory** for packages that should be skipped (e.g., packages that caused production issues after previous upgrades).

When skipping pinned packages, report them to the user so they know what was excluded and why.
</step_2>

<step_3>
**Check for outdated packages**

**For pnpm**: `pnpm outdated -r`
**For npm**: `npm outdated`
**For yarn**: `yarn outdated`
**For Nix flakes**: `nix flake lock --update-input <input> --dry-run` for each input, or compare `flake.lock` dates to identify stale inputs

If `$ARGUMENTS` was provided, filter the results to only packages/inputs whose names match the filter string (case-insensitive partial match).
</step_3>

<step_4>
**Group related packages into upgrade batches**

Organize outdated packages into logical groups. Packages in the same group should be upgraded together because they often have interdependencies or coordinated releases.

**For Node.js projects, use these grouping rules:**

1. **Scoped packages**: Group by npm scope (e.g., all `@aws-sdk/*` together, all `@tanstack/*` together, all `@mui/*` together)
2. **Known ecosystems**: Group packages from the same ecosystem even if unscoped:
   - React ecosystem: `react`, `react-dom`, `@types/react`, `@types/react-dom`
   - Next.js ecosystem: `next`, `@next/*`, `eslint-config-next`
   - SST/AWS: `sst`, `aws-cdk-*`, `constructs`, `@aws-sdk/*`
   - Testing: `vitest`, `@vitest/*`, `jest`, `@jest/*`, `@testing-library/*`
   - ESLint: `eslint`, `@eslint/*`, `eslint-*`, `@typescript-eslint/*`
   - TypeScript: `typescript`, `@types/*` (that aren't part of another group)
   - Mongoose/MongoDB: `mongoose`, `mongodb`, `@typegoose/*`
   - Zod ecosystem: `zod`, `zod-*`, `@hookform/resolvers` (if zod is used)
3. **Standalone packages**: Packages that don't fit a group become individual upgrade items, but batch them together as "Miscellaneous standalone packages" to avoid too many tiny commits

**For Nix flakes:**
- Group by relatedness (e.g., `nixpkgs` and `nixpkgs-unstable` together, home-manager with its nixpkgs input)
- Individual flake inputs that are independent can be updated together as a single batch

Present the grouped batches to the user as a numbered list with package names and version changes (current → latest). Example:

```
Batch 1: @aws-sdk/* (5 packages)
  - @aws-sdk/client-s3: 3.500.0 → 3.525.0
  - @aws-sdk/client-sqs: 3.500.0 → 3.525.0
  ...

Batch 2: @tanstack/* (3 packages)
  - @tanstack/react-query: 5.20.0 → 5.28.0
  ...

Skipped (pinned):
  - serwist@9.5.3 (pinned — production bug from 9.5.7)
  - some-lib@2.0.0 (exact version, likely pinned intentionally)
```

**Ask the user which batches to proceed with** (e.g., "all", specific batch numbers, or "skip batch 3").
</step_4>

<step_5>
**Upgrade each approved batch**

For each approved batch, in order:

**For Node.js projects (pnpm/npm/yarn):**

1. **Update versions** using the appropriate package manager command (e.g., `pnpm update <package-names> --latest -r`)
2. **Install** dependencies (e.g., `pnpm install -r`)
3. **Verify** — run the project's typecheck or build command if available:
   - Check for `typecheck` script in package.json: `pnpm -r typecheck` or `npm run typecheck`
   - If no typecheck script, try `npx tsc --noEmit` if TypeScript is present
   - If not a TypeScript project, skip verification or run `npm test` if tests exist
4. **If verification fails**:
   - Analyze the errors
   - If errors are clearly caused by the upgrade (breaking API changes), report them and ask how to proceed:
     - Fix the type errors (if straightforward)
     - Revert this batch and continue with others
     - Stop entirely
   - If errors appear to be pre-existing or stale-build related, attempt a clean rebuild before declaring failure
5. **If verification passes**, report success for this batch and ask the user if they want to commit before moving to the next

**For Nix flakes:**

1. **Update inputs** with `nix flake lock --update-input <input-name>` for each input in the batch
2. **Verify** with `nix flake check` or a build command if applicable (e.g., `darwin-rebuild build --flake .` for nix-darwin)
3. Handle failures the same way — report and ask how to proceed

**Important**: Process batches sequentially so failures in one batch don't cascade.
</step_5>

<step_6>
**Summary report**

After all batches are processed, provide a final summary:

```
Upgrade Summary
───────────────
✓ Batch 1: @aws-sdk/* (5 packages) — upgraded successfully
✓ Batch 2: @tanstack/* (3 packages) — upgraded successfully
✗ Batch 3: @mui/* (4 packages) — reverted (breaking changes in Joy UI)
⊘ Skipped: serwist, some-pinned-lib

Total: X packages upgraded, Y reverted, Z skipped
```
</step_6>

</workflow>

<anti_patterns>
- NEVER upgrade pinned (exact version) packages without explicit user approval
- NEVER upgrade packages that memory says to skip (check memory for the latest skip list)
- NEVER run `npm run dev` or start development servers
- NEVER upgrade all packages in a single batch — always group and verify incrementally
- NEVER force-install or use `--force` flags without user approval
- NEVER modify lock files manually — let the package manager handle them
- NEVER skip the verification step after upgrading a batch
- DO NOT upgrade `@types/*` packages separately from their corresponding library if both are outdated — upgrade them together
</anti_patterns>

<edge_cases>
- **Monorepo version alignment**: If multiple workspaces use the same package at different versions, prefer aligning them to the same latest version unless a workspace has a specific reason for pinning
- **Major version bumps**: Flag major version changes (e.g., 4.x → 5.x) prominently — these are more likely to have breaking changes and may need migration guides. Check package changelogs if the user wants more info
- **Peer dependency conflicts**: If the package manager reports peer dependency warnings after an upgrade, report them to the user
- **Workspace protocol**: Packages using `workspace:*` or `workspace:^` protocol are internal — do not attempt to upgrade these
- **Nix input follows**: Some nix flake inputs use `inputs.nixpkgs.follows` — updating the followed input automatically updates followers, so don't double-update
</edge_cases>
