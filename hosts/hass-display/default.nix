{ pkgs, ... }: {

  imports = [
    ../../profiles/raspberry_pi/4.nix
  ];

  config = {
    entropia.users = [ "evlli" ];
    entropia.kiosk = {
      enable = true;
      url = "https://hass.club.entropia.de?BrowserID=hass-display";
      flip180 = true;
    };

    networking.hostName = "hass-display";

    deployment.targetHost = "10.214.227.29";

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
  };
}
