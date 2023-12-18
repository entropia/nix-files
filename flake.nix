{
  description = "Entropia nix files";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs."nixpkgs".follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs."nixpkgs".follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    imports = [
      ./hosts
      ./modules
      ./pkgs
    ];

    perSystem = { pkgs, inputs', ... }: {
      devShells.default = pkgs.mkShellNoCC {
        sopsPGPKeyDirs = [
          "${toString ./.}/secrets/keys"
        ];
        sopsCreateGPGHome = "1";
        packages = with pkgs; [
          colmena
          sops
          inputs'.sops-nix.packages.sops-import-keys-hook
        ];
      };
    };
  };
}
