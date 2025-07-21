{ config, lib, pkgs, ... }:

{
  home.file.".claude/settings.json".text = builtins.toJSON {
    includeCoAuthoredBy = false;
  };

  home.activation.claudeMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Add user-scoped MCP servers
    ${pkgs.claude-code}/bin/claude mcp add context7 -s user "${pkgs.nodejs_20}/bin/npx" -- -y @upstash/context7-mcp || true
    ${pkgs.claude-code}/bin/claude mcp add sequential-thinking -s user "${pkgs.nodejs_20}/bin/npx" -- -y @modelcontextprotocol/server-sequential-thinking || true
  '';
}