{ self, ... }: {

  flake.overlays.default = final: prev: {
    inherit (self.packages.${final.system}) berechenbarkeit wg-access-server;
  };

  perSystem = { pkgs, ... }: {
    packages = {
      berechenbarkeit = pkgs.callPackage ./berechenbarkeit { };
      wg-access-server = pkgs.callPackage ./wg-access-server { };
    };
  };
}
