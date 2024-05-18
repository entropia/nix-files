{ inputs, config, ... }: {

  imports = [
    ./disko.nix
    inputs.disko.nixosModules.disko
    ../../profiles/entropia-cluster-vm
  ];

  networking.hostName = "trollqr";
  networking.domain = "gulas.ch";
  deployment.targetHost = config.networking.fqdn;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "24.05";

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks."10-eth" = {
    enable = true;
    name = "en*";
    dns = [ "1.1.1.1" ];
    address = [
      "151.216.64.54/28"
      "2a0e:c5c1:0:10::6/64"
    ];
    routes = [
      { routeConfig = { Destination = "0.0.0.0/0"; Gateway = "151.216.64.49"; }; }
      { routeConfig = { Destination = "::/0"; Gateway = "2a0e:c5c1:0:10::1"; }; }
    ];
  };
  services.resolved.enable = true;
}
