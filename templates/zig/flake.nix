{
  description = "Zig project (toolchain + language server from one nixpkgs)";

  inputs.nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          zig
          zls
        ];
      };
    };
}
