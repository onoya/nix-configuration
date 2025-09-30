{ config, lib, pkgs, ... }:

{
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      includeCoAuthoredBy = false;
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
