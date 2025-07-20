{ config, lib, pkgs, ... }:

{
  home.file.".claude/settings.json".text = builtins.toJSON {
    includeCoAuthoredBy = false;
  };
}