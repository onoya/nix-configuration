{ config, lib, pkgs, ... }:

let
  peonHookCmd = "${config.home.homeDirectory}/.openpeon/peon.sh";

  mkPeonHookEntry = { async ? true, matcher ? "" }: {
    inherit matcher;
    hooks = [
      ({
        type = "command";
        command = peonHookCmd;
        timeout = 10;
      } // lib.optionalAttrs async { "async" = true; })
    ];
  };
in
{
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      includeCoAuthoredBy = false;
      effortLevel = "high";
      statusLine = {
        type = "command";
        command = "/bin/bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
      };
      hooks = {
        SessionStart       = [ (mkPeonHookEntry { async = false; }) ];
        SessionEnd         = [ (mkPeonHookEntry {}) ];
        SubagentStart      = [ (mkPeonHookEntry {}) ];
        UserPromptSubmit   = [ (mkPeonHookEntry {}) ];
        Stop               = [ (mkPeonHookEntry {}) ];
        Notification       = [ (mkPeonHookEntry {}) ];
        PermissionRequest  = [ (mkPeonHookEntry {}) ];
        PostToolUseFailure = [ (mkPeonHookEntry { matcher = "Bash"; }) ];
        PreCompact         = [ (mkPeonHookEntry {}) ];
      };
      enabledPlugins = {
        "superpowers@claude-plugins-official" = true;
      };
      permissions.allow = [
        # MCP servers — Context7
        "mcp__context7__get-library-docs"
        "mcp__context7__query-docs"
        "mcp__context7__resolve-library-id"
        "mcp__sequential-thinking__sequentialthinking"

        # MCP servers — Playwright
        "mcp__playwright__*"

        # MCP servers — GitHub (read-only / non-destructive)
        # Note: github-mcp-server unified per-resource reads into `*_read` tools that
        # dispatch on a `method` parameter. Individual `get_issue`/`get_pull_request_*`
        # entries no longer match anything.
        "mcp__github__add_comment_to_pending_review"
        "mcp__github__get_file_contents"
        "mcp__github__get_me"
        "mcp__github__issue_read"
        "mcp__github__list_commits"
        "mcp__github__list_issues"
        "mcp__github__list_pull_requests"
        "mcp__github__pull_request_read"
        "mcp__github__search_issues"
        "mcp__github__search_pull_requests"

        # Safe Bash commands — read-only / non-destructive
        "Bash(git status*)"
        "Bash(git diff*)"
        "Bash(git log*)"
        "Bash(git branch*)"
        "Bash(git show*)"
        "Bash(nix flake check*)"
        "Bash(nix flake show*)"
        "Bash(darwin-rebuild build*)"
        "Bash(nh darwin switch*)"
        "Bash(which *)"
        "Bash(cat *)"
        "Bash(ls *)"
        "Bash(head *)"
        "Bash(tail *)"
        "Bash(wc *)"
        "Bash(echo *)"
        "Bash(pwd)"
        "Bash(env)"
        "Bash(printenv*)"
        "Bash(man *)"
        "Bash(gh pr view*)"
        "Bash(gh pr list*)"
        "Bash(gh pr status*)"
        "Bash(gh pr checks*)"
        "Bash(gh pr diff*)"
        "Bash(gh issue view*)"
        "Bash(gh issue list*)"
        "Bash(gh issue status*)"
        "Bash(gh repo view*)"
        "Bash(gh repo list*)"
        "Bash(jq *)"
        "Bash(fastfetch*)"
      ];
    };

    ".claude/statusline-command.sh" = {
      text = ''
        #!/usr/bin/env bash

        # Read JSON input from stdin
        input=$(cat)

        # Extract Claude Code context
        model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
        output_style=$(echo "$input" | jq -r '.output_style.name // ""')
        cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

        # Get git branch (skip optional locks to avoid blocking)
        git_branch=""
        if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
          git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "")
          if [[ -z "$git_branch" ]]; then
            # Detached HEAD state - show short commit hash
            git_branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo "detached")
          fi
        fi

        # Get directory name
        dir_name=$(basename "$cwd")

        # Build status line with colors
        status_line=""

        # Add user@host
        status_line+="$(printf '\033[36m')$(whoami)@$(hostname -s)$(printf '\033[0m')"

        # Add directory
        status_line+=" $(printf '\033[32m')''${dir_name}$(printf '\033[0m')"

        # Add git branch if available
        if [[ -n "$git_branch" ]]; then
          status_line+=" $(printf '\033[35m')(''${git_branch})$(printf '\033[0m')"
        fi

        # Add model name
        status_line+=" $(printf '\033[33m')[''${model_name}]$(printf '\033[0m')"

        # Add output style if set
        if [[ -n "$output_style" && "$output_style" != "null" ]]; then
          status_line+=" $(printf '\033[34m')<''${output_style}>$(printf '\033[0m')"
        fi

        echo "$status_line"
      '';
      executable = true;
    };

    ".claude/CLAUDE.md".text = ''
      # Developer Profile & Preferences

      ## Persona
      You are a veteran software engineer with 15+ years of experience. You take pride in writing
      clean, elegant, and maintainable code. You naturally follow industry best practices and design
      patterns, and you're not afraid to push back when something feels architecturally wrong.

      ## Core Philosophy
      - Clean, readable code over clever code
      - Explicit over implicit
      - Fail fast, fail loudly
      - SOLID principles and composition over inheritance
      - If it's hard to test, it's probably a design problem

      ## Tech Stack & Preferences
      - **Language**: TypeScript (strict mode, never use `any` — use `unknown` + type guards instead)
      - **Validation**: Zod for all schema validation and type inference
      - **State**: Zustand for client-side state management
      - **Data fetching**: React Query (TanStack Query) for all async data
      - **Packages**: Always use the latest stable versions

      ## Code Style
      - Prefer `const` over `let`, never use `var`
      - Descriptive variable/function names — no abbreviations unless universally understood
      - Small, single-responsibility functions
      - Avoid deep nesting — use early returns
      - Prefer `async/await` over raw `.then()` chains
      - Errors should be handled explicitly, never swallowed silently

      ## TypeScript Specifics
      - Strict mode always on
      - Never use `any` — use `unknown`, proper generics, or Zod-inferred types
      - Prefer `type` over `interface` for object shapes unless extending is needed
      - Use discriminated unions for modeling state

      ## Communication Style
      - Be direct and concise
      - Call out code smells or anti-patterns proactively
      - Suggest refactors when you spot opportunities
      - Explain the *why* behind architectural decisions
    '';

    ".claude/skills/upgrade-deps/SKILL.md".text = builtins.readFile ./claude/skills/upgrade-deps.md;
    ".claude/skills/e2e/SKILL.md".text = builtins.readFile ./claude/skills/e2e.md;
    ".claude/skills/address-review/SKILL.md".text = builtins.readFile ./claude/skills/address-review.md;
    ".claude/skills/review-pr-friendly/SKILL.md".text = builtins.readFile ./claude/skills/review-pr-friendly.md;
    ".claude/skills/review-pr/SKILL.md".text = builtins.readFile ./claude/skills/review-pr.md;
    ".claude/skills/improve-architecture/SKILL.md".text = builtins.readFile ./claude/skills/improve-architecture.md;
    ".claude/skills/work/SKILL.md".text = builtins.readFile ./claude/skills/work.md;
    ".claude/skills/ship/SKILL.md".text = builtins.readFile ./claude/skills/ship.md;
  };

  home.activation.claudeMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Add user-scoped MCP servers
    /opt/homebrew/bin/claude mcp add context7 -s user "${pkgs.nodejs_24}/bin/npx" -- -y @upstash/context7-mcp || true
    /opt/homebrew/bin/claude mcp add sequential-thinking -s user "${pkgs.nodejs_24}/bin/npx" -- -y @modelcontextprotocol/server-sequential-thinking || true
    # Re-register playwright so env vars (TMPDIR) stay in sync; npx writes to TMPDIR and the macOS per-user temp dir breaks the MCP server.
    /opt/homebrew/bin/claude mcp remove playwright -s user 2>/dev/null || true
    /opt/homebrew/bin/claude mcp add playwright -s user -e TMPDIR=/tmp -- "${pkgs.nodejs_24}/bin/npx" -y @playwright/mcp@latest || true
  '';
}
