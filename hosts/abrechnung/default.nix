{ inputs, pkgs, ... }: {

  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];

  entropia.users = [ "leona" ];

  networking.hostName = "abrechnung";
  networking.domain = "entropia.de";
  deployment.targetHost = "abrechnung.entropia.de";

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
      "45.140.180.56/27"
      "2a0e:c5c0:0:201::15/64"
    ];
    routes = [
      { routeConfig = { Destination = "0.0.0.0/0"; Gateway = "45.140.180.33"; }; }
      { routeConfig = { Destination = "::/0"; Gateway = "2a0e:c5c0:0:201::"; }; }
    ];
  };
  services.resolved.enable = true;
}