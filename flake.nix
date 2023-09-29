{
  description = "Entropia nix files";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs."nixpkgs".follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    imports = [
      ./hosts
      ./modules
    ];

    perSystem = { pkgs, ... }: {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          colmena
        ];
      };
    };
  };
}
