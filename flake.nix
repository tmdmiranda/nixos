{
  description = "NixOS Tigas Conf";

  inputs = {
      nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";

          home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      };

      codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let

    mkNixosSystem = { system, hostname, username, extraModules ? [] }:
      nixpkgs.lib.nixosSystem{
        inherit system;


        specialArgs = {inherit inputs; };

        modules = [
        ./hosts/${hostname}/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {
                inherit inputs;
                hostname = hostname;
              };

              users.${username} = import ./hosts/${hostname}/home.nix;
            };
          } 
        ] ++extraModules;
      };
    in {
      templates.zig = {
        path = ./templates/zig;
        description = "Zig project shell (zig + zls, matched versions)";
      };

      nixosConfigurations = {
        laptop = mkNixosSystem {
          system = "x86_64-linux";
          hostname = "laptop";
          username = "tiago"; 
        };
      };
  };
}
