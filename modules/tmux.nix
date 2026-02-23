{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    historyLimit = 100000;
    baseIndex = 1;

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
    ];

    extraConfig = ''
      set-option -g default-shell ${pkgs.zsh}/bin/zsh
      set-option -g default-command ${pkgs.zsh}/bin/zsh

      set -g @continuum-restore 'on'
      set -g @continuum-boot 'on'
      set -g status-right 'Continuum status: #{continuum_status}'

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
    '';
  };
}
