{ config, lib, pkgs, ... }:

{
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      includeCoAuthoredBy = false;
      statusLine = {
        type = "command";
        command = "/bin/bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
      };
      hooks = {
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'";
              }
            ];
          }
        ];
      };
      allowTools = [
        # MCP servers — Context7
        "mcp__context7__get-library-docs"
        "mcp__context7__query-docs"
        "mcp__context7__resolve-library-id"
        "mcp__sequential-thinking__sequentialthinking"

        # MCP servers — GitHub (read-only / non-destructive)
        "mcp__github__add_comment_to_pending_review"
        "mcp__github__get_file_contents"
        "mcp__github__get_issue"
        "mcp__github__get_issue_comments"
        "mcp__github__get_me"
        "mcp__github__get_pull_request"
        "mcp__github__get_pull_request_comments"
        "mcp__github__get_pull_request_diff"
        "mcp__github__get_pull_request_files"
        "mcp__github__get_pull_request_reviews"
        "mcp__github__get_pull_request_status"
        "mcp__github__list_commits"
        "mcp__github__list_issues"
        "mcp__github__list_pull_requests"

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

    ".claude/commands/ship.md".text = ''
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
    '';
  };

  home.activation.claudeMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Add user-scoped MCP servers
    ${pkgs.claude-code}/bin/claude mcp add context7 -s user "${pkgs.nodejs_20}/bin/npx" -- -y @upstash/context7-mcp || true
    ${pkgs.claude-code}/bin/claude mcp add sequential-thinking -s user "${pkgs.nodejs_20}/bin/npx" -- -y @modelcontextprotocol/server-sequential-thinking || true
  '';
}
