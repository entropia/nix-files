{ inputs, config, ... }: {

  imports = [
    ./disko.nix
    inputs.disko.nixosModules.disko
    ../../profiles/entropia-cluster-vm
  ];

  networking.hostName = "web01";
  networking.domain = "entropia.de";
  deployment.targetHost = config.networking.fqdn;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "24.11";

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks."10-eth" = {
    enable = true;
    name = "en*";
    dns = [ "1.1.1.1" ];
    address = [
      "45.140.180.57/27"
      "2a0e:c5c0:0:201::18/64"
    ];
    routes = [
      { routeConfig = { Destination = "0.0.0.0/0"; Gateway = "45.140.180.33"; }; }
      { routeConfig = { Destination = "::/0"; Gateway = "2a0e:c5c0:0:201::1"; }; }
    ];
  };
  services.resolved.enable = true;
}
