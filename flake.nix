{
  description = "onoya's Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs }: {
    darwinConfigurations = {
      "Main-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.onoya = import ./home.nix;
            users.users.onoya = {
              name = "onoya";
              home = "/Users/onoya";
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };

      "Work-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.onoya = import ./home.nix;
            users.users.onoya = {
              name = "onoya";
              home = "/Users/onoya";
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
