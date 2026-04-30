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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    peon-ping.url = "github:PeonPing/peon-ping";
    peon-ping.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, darwin, determinate, home-manager, nixpkgs, nix-homebrew, nixCats, nix-index-database, peon-ping }:
  let
    mkDarwinSystem = { hostname, username, system ? "aarch64-darwin" }:
      darwin.lib.darwinSystem {
        modules = [
          ./hosts/${hostname}
          ./modules/darwin
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nixpkgs.hostPlatform = system;
            networking.hostName = hostname;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [
              inputs.nixCats.homeModule
              inputs.nix-index-database.homeModules.nix-index
              inputs.peon-ping.homeManagerModules.default
            ];
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
        specialArgs = { inherit inputs nixpkgs username; };
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

      "Work-MBP" = mkDarwinSystem {
        hostname = "Work-MBP";
        username = "onoya";
      };
    };
  };
}
