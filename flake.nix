{
  description = "Entropia nix files";

  nixConfig = {
    extra-substituters = [ "https://entropia.cachix.org" ];
    extra-trusted-public-keys = [ "entropia.cachix.org-1:a3vy2scFVr0sQvtp2CPlOlzUKmPfbvs1/9VFsqqI5Sk=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs."nixpkgs".follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs."nixpkgs".follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs."nixpkgs".follows = "nixpkgs";
    nix-fast-build.url = "github:Mic92/nix-fast-build";
    nix-fast-build.inputs."nixpkgs".follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    imports = [
      ./hosts
      ./modules
      ./pkgs
      ./checks
      ./lib/cloud-init.nix
      ./flakeModules
    ];

    perSystem = { pkgs, inputs', ... }: {
      packages = {
        inherit (inputs'.nix-fast-build.packages) nix-fast-build;
      };
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
