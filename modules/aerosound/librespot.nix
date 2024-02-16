{ pkgs, lib, ... }:
let
  package = pkgs.librespot.overrideAttrs (old: rec {
    version = "0.5.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "librespot-org";
      repo = "librespot";
      rev = "5a322e70e15d4e442a2d681609bb38eec8b31dc8";
      hash = "sha256-NHburKiaWmcW+HhbmIklwGBVu++kjI0nCeli9WXcUHs=";
    };

    cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
      name = "${old.pname}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-otFsv0eoAYIqqtydUOx/WDu4+zi23jeRakaFphvyZJM=";
    });

  });
in
{
  environment.systemPackages = [
    package
  ];
  # systemd.services.librespot = {
  #   wantedBy = [ "aerosound.target" ];
  #   requires = [ "pipewire.service" "network-online.target" ];
  #   after = [ "pipewire.service" "network-online.target" ];
  #
  #   script = "${package}/bin/librespot";
  # };
}
