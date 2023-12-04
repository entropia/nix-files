{ nixpkgs, ... }:
{
  nixpkgs = import nixpkgs {
    system = "aarch64-linux";
  };
}
