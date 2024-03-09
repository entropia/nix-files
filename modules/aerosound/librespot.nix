{ pkgs, lib, ... }:
let
  package = pkgs.spotifyd.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./spotifyd-dns-sd.patch ];
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
