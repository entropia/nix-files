{
  perSystem = { pkgs, self', ... }: {
    overlayAttrs.default = self'.packages; 
    packages = {
      wg-access-server = pkgs.callPackage ./wg-access-server { };
    };
  };
}
