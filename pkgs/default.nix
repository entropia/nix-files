{ self, ... }: {

  flake.overlays.default = final: prev: {
    inherit (self.packages.${final.system}) wg-access-server gulaschdisplay-client;
  };

  perSystem = { pkgs, ... }: {
    packages = {
      wg-access-server = pkgs.callPackage ./wg-access-server { };
      gulaschdisplay-client = pkgs.callPackage ./gulaschdisplay-client { };
    };
  };
}
