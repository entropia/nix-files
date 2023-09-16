{ pkgs, ... }: {

  imports = [
    ../../modules/raspberry_pi4.nix
    ../../modules/kiosk.nix
  ];

  entropia.kiosk = {
    enable = true;
    url = "https://hass.club.entropia.de?BrowserID=hass-display";
    flip180 = true;
  };

  system.stateVersion = "23.05";

  deployment.targetHost = "10.214.227.219";

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;

  services.avahi = {
    enable = true;
    publish.enable = true;
  };

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

  networking.hostName = "hass-display";

  services.resolved.enable = true;

  environment.systemPackages = [
    pkgs.libinput
    pkgs.seatd
    pkgs.htop
    pkgs.wlr-randr
    pkgs.ddcutil
  ];
}
