{

  imports = [
    ../../profiles/raspberry_pi/4.nix

    ./wg-access-server.nix
  ];

  config = {
    networking.hostName = "oob-vpn-gayway";

    deployment.targetHost = "192.168.72.20";
    deployment.tags = [ "club" ];

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

    services.resolved.enable = true;
  };
}
