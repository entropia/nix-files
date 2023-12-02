{
  perSystem = { pkgs, self', ... }: {
    overlayAttrs = self'.packages; 
    packages = {
      wg-access-server = pkgs.callPackage ./wg-access-server { };
    };
  };
}
