{ config, lib, pkgs, ... }:

{
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      includeCoAuthoredBy = false;
      statusLine = {
        type = "command";
        command = "/bin/bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
      };
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
