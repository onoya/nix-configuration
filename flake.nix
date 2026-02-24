{
  description = "onoya's Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, nix-homebrew, nixCats }:
  let
    mkDarwinSystem = { hostname, username, system ? "aarch64-darwin" }:
      darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./hosts/${hostname}
          ./modules/darwin
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            networking.hostName = hostname;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [ inputs.nixCats.homeModule ];
            home-manager.users.${username} = import ./modules/home;

            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
            };

            nix-homebrew = {
              enable = true;
              user = username;
              enableRosetta = true;
              autoMigrate = true;
            };
          }
        ];
        specialArgs = { inherit inputs nixpkgs username system; };
      };
  in {
    darwinConfigurations = {
      "Main-MacBook-Pro" = mkDarwinSystem {
        hostname = "Main-MacBook-Pro";
        username = "onoya";
      };

      "Work-MacBook-Pro" = mkDarwinSystem {
        hostname = "Work-MacBook-Pro";
        username = "onoya";
      };
    };
  };
}
