{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  perSystem = { system, ... }: {
    checks = lib.optionalAttrs (system == "x86_64-linux") 
      (lib.mapAttrs' (name: value: lib.nameValuePair "cloudInitImage-${name}" value) self.cloudInitImages.${system});
  };
}
