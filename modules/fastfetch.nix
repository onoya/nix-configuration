{ ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo.padding = {
        top = 1;
        right = 2;
      };

      display = {
        separator = " ";
        key = {
          type = "icon";
          width = 5;
        };
      };

      modules = [
        "title"
        "separator"
        "break"

        # Software
        { type = "os"; keyColor = "blue"; }
        { type = "host"; keyColor = "blue"; }
        { type = "kernel"; keyColor = "blue"; }
        { type = "uptime"; keyColor = "blue"; }
        { type = "packages"; keyColor = "blue"; }
        { type = "shell"; keyColor = "blue"; }
        { type = "terminal"; keyColor = "blue"; }

        "break"

        # Hardware
        { type = "cpu"; keyColor = "magenta"; }
        { type = "gpu"; keyColor = "magenta"; }
        { type = "memory"; keyColor = "magenta"; }
        { type = "disk"; keyColor = "magenta"; }
        { type = "battery"; keyColor = "magenta"; }
        { type = "display"; keyColor = "magenta"; }

        "break"
        { type = "colors"; symbol = "circle"; }
      ];
    };
  };
}
