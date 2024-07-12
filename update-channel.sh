# Update nixpkgs & home-manager channels to the specified version
version=24.05

nix-channel --add https://nixos.org/channels/nixpkgs-$version-darwin nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-$version.tar.gz home-manager

nix-channel --update
nix-channel --list
