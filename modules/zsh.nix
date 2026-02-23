{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      sail = "./vendor/bin/sail";
      cat = "bat";
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --icons";
      find = "fd";
      lg = "lazygit";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
      ];
    };

    initContent = ''
      # Source secrets file (API keys, tokens, etc.)
      # This file is not tracked in git - create manually with 'export' statements
      [ -f ~/.secrets ] && source ~/.secrets

      # Enable command timing for commands taking 3+ seconds
      export REPORTTIME=3

      # Fix conflicting color environment variables set by Claude Code
      # Keep NO_COLOR for consistent behavior, but remove FORCE_COLOR to avoid Node.js warnings
      if [[ -n "$NO_COLOR" && -n "$FORCE_COLOR" ]]; then
        unset FORCE_COLOR
      fi

      # Change to ~/codes directory when opening new terminal (if starting from home)
      if [[ "$PWD" == "$HOME" ]]; then
        cd ~/codes 2>/dev/null || true
      fi

      # Auto-start tmux session (attach to restored/existing session, or create "main")
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        exec tmux attach || exec tmux new-session -s main
      fi

      # Rebuild system config — works from anywhere, not just inside the repo
      rebuild() {
        nh darwin switch ${config.home.homeDirectory}/codes/nix-configuration
      }
    '';
  };
}
