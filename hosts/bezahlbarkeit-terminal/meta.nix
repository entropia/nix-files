{ ... }:
{
  # pin nixpkgs to version where cage isn't crashing on startup do to firefox being a great wayland fuzzer
  # we can maybe remove this after cage updates to wlroots 0.17
  nixpkgs = import (builtins.getFlake "github:nixos/nixpkgs/8a86b98f0ba1c405358f1b71ff8b5e1d317f5db2") {
    system = "aarch64-linux";
  };
}
