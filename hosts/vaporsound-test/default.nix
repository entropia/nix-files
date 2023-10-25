{ pkgs, ... }: {

  imports = [
    ../../profiles/raspberry_pi/4.nix
  ];

  config = {
    networking.hostName = "vaporsound-test";

    deployment.targetHost = "10.214.227.9";

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
      publish = {
        enable = true;
        userServices = true;
      };
    };

    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [ 554 1024 1025 1026 ];
    networking.firewall.allowedUDPPorts = [ 554 1024 1025 1026 ];

    services.resolved.enable = true;

    entropia.vaporsound.enable = true;

    environment.systemPackages = with pkgs; [
      pulseaudio-ctl
      alsa-utils
    ];
  };
}
