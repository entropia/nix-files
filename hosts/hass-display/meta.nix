{ ... }:
{
  nixpkgs = import (builtins.getFlake "github:nixos/nixpkgs/e35dcc04a3853da485a396bdd332217d0ac9054f") {
    system = "aarch64-linux";
  };
}
