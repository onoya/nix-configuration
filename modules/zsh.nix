{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };

      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };
    };
  };

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
      theme = "";
      plugins = [
        "git"
      ];
    };

    initContent = ''
      # Initialize Homebrew environment (required on Apple Silicon)
      eval "$(/opt/homebrew/bin/brew shellenv)"

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

      # Change to ~/dev when shell starts in a non-meaningful default location.
      # Covers tmux sessions auto-started by continuum-boot (cwd "/") as well as
      # plain terminal launches (cwd "$HOME").
      if [[ "$PWD" == "$HOME" || "$PWD" == "/" ]]; then
        cd ~/dev 2>/dev/null || true
      fi

      # Auto-start tmux session (attach to restored/existing session, or create "main")
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        tmux attach 2>/dev/null || exec tmux new-session -s main
      fi

      # Show system info on new shell (runs inside tmux panes/windows)
      fastfetch

      # Rebuild system config — works from anywhere, not just inside the repo
      rebuild() {
        nh darwin switch ${config.home.homeDirectory}/dev/nix-configuration
      }
    '';
  };
}
