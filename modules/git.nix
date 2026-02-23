{ ... }:

{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };
    settings = {
      user.email = "ono.naoyaa@gmail.com";
      user.name = "Naoya Ono";
      init.defaultBranch = "main";

      core.editor = "vim";

      push.autoSetupRemote = true;
    };
  };
}
