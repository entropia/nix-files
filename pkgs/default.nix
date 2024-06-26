{ self, ... }: {

  flake.overlays.default = final: prev: {
    inherit (self.packages.${final.system}) berechenbarkeit;
  };

  perSystem = { pkgs, ... }: {
    packages = {
      berechenbarkeit = pkgs.callPackage ./berechenbarkeit { };
    };
  };
}
