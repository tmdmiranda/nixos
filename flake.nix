{
  description = "NixOS Tigas Conf";

  inputs = {
      nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";

          home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      };

      # Hourly-auto-updated codex CLI ("always latest", pinned via flake.lock).
      # Refresh with: nix flake update codex-cli-nix
      # (opencode intentionally stays on nixpkgs-unstable: the dan-online
      # hourly flake is stale at 1.14.33 while nixpkgs already has 1.18.35.)
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
              # Auto-backup (instead of failing) when HM-managed files already exist
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
      nixosConfigurations = {
        # NOTE: no hosts/desktop/ yet — re-add by copying hosts/laptop to hosts/desktop
        # desktop = mkNixosSystem {
        #   system = "x86_64-linux";
        #   hostname = "desktop";
        #   username = "tiago";
        # };

        laptop = mkNixosSystem {
          system = "x86_64-linux";
          hostname = "laptop";
          username = "tiago"; 
        };
      };
  };
}
