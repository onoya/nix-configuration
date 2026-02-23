{ ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.email = "ono.naoyaa@gmail.com";
      user.name = "Naoya Ono";
      init.defaultBranch = "main";

      core.editor = "vim";

      push.autoSetupRemote = true;
    };
  };
}
