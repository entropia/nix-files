{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  filterSystem = system: lib.filterAttrs (_: nixos: nixos.pkgs.hostPlatform.system == system);
in
{
  perSystem = { system, ... }: {
    checks = builtins.mapAttrs (_: nixos: nixos.config.system.build.toplevel) (filterSystem system self.nixosConfigurations);
  };
}
