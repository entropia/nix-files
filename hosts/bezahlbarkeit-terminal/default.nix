{ pkgs, ... }: {

  imports = [
    ../../profiles/raspberry_pi4.nix
    ../../modules/kiosk.nix
  ];

  entropia.kiosk = {
    enable = true;
    url = "http://bezahlbarkeit.club.entropia.de";
  };

  networking.hostName = "bezahlbarkeit-terminal";

  deployment.targetHost = "10.214.227.138";

  system.stateVersion = "23.05";

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;

  systemd.network.networks."10-lan" = {
    enable = true;
    name = "en*";
    networkConfig = {
      DHCP = "yes";
      MulticastDNS = "yes";
      DNSOverTLS = "opportunistic";
      IPv6AcceptRA = "yes";
      IPv6PrivacyExtensions = "yes";
    };
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
  };

  services.resolved.enable = true;

  environment.systemPackages = [
    pkgs.libinput
    pkgs.seatd
    pkgs.htop
    pkgs.wlr-randr
    pkgs.ddcutil
  ];
}
