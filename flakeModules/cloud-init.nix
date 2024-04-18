{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types ;
  inherit (flake-parts-lib) mkTransposedPerSystemModule ;
in
mkTransposedPerSystemModule {
  name = "cloudInitImages";
  option = mkOption {
    type = types.lazyAttrsOf types.package;
    default = { };
  };
  file = ./cloud-init.nix;
}
