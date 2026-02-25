{ pkgs, ... }:

{
  # Catppuccin tmux theme is managed by catppuccin/nix (flavor set globally)
  catppuccin.tmux.extraConfig = ''
    set -g @catppuccin_window_status_style "rounded"
    set -g @catppuccin_window_default_text "#W"
    set -g @catppuccin_window_current_text "#{?window_zoomed_flag, 󰊓 ,}#W"
    set -g status-right-length 100
    set -g status-left-length 100
    set -g status-left ""
    set -g status-right "#{E:@catppuccin_status_application}"
    set -ag status-right "#{E:@catppuccin_status_session}"
    set -ag status-right "#{E:@catppuccin_status_date_time}"
  '';

  programs.tmux = {
    enable = true;
    shortcut = "a";
    historyLimit = 100000;
    baseIndex = 1;
    terminal = "tmux-256color";

    plugins = [
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      pkgs.tmuxPlugins.continuum
      pkgs.tmuxPlugins.better-mouse-mode
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.tmux-fzf
      pkgs.tmuxPlugins.yank
    ];

    extraConfig = ''
      set-option -g default-shell ${pkgs.zsh}/bin/zsh
      set-option -g default-command ${pkgs.zsh}/bin/zsh

      # true color support
      set -sa terminal-overrides ",xterm-256color:RGB"
      set -g focus-events on

      set -g @continuum-restore 'on'
      set -g @continuum-boot 'on'

      # reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # change binding for split horizontally to - and set it to the current path
      unbind %
      bind | split-window -h -c "#{pane_current_path}"

      # change binding for split vertically to | and set it to the current path
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      # creates a new window in the current path
      bind c new-window -c "#{pane_current_path}"

      # resize panes
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      bind -r m resize-pane -Z

      set -g mouse on

      # active pane highlighting: dim inactive panes, bright active pane
      set -g window-style 'fg=colour245,bg=default'
      set -g window-active-style 'fg=colour255,bg=default'
      set -g pane-border-style 'fg=colour238,bg=default'
      set -g pane-active-border-style 'fg=colour39,bg=default'
    '';
  };
}
