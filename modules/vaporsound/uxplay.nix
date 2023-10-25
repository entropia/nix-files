{ lib, pkgs, config, ... }:
let
  port = 1024;
in
{
  config = {
    networking.firewall = {
      allowedTCPPorts = [
        554 #rtsp
      ];
      allowedUDPPorts = [
        554 #rtsp
      ];
      allowedTCPPortRanges = [{ from = port; to = port + 2; }];
      allowedUDPPortRanges = [{ from = port; to = port + 2; }];
    };

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    systemd.services.uxplay =
      let
        args = [
          "-n ${config.networking.hostName}" # network name of AirPlay server
          "-nh" # Do net add @hostname to end of AirPlay server name
          "-vs 0" # disable video mirroring
          "-async" # sync audio to client
          "-p ${toString port}" # Use TCP and UDP ports n,n+1,n+2.
        ];
      in
      {
        wantedBy = [ "vaporsound.target" ];
        after = [ "network-online.target" "sound.target" ];
        description = "UXPlay, a AirPlay mirroring server.";
        serviceConfig =
          {
            ExecStart = "${pkgs.uxplay}/bin/uxplay ${builtins.concatStringsSep " " args}";
            Restart = "always";
            RestartSec = 10;
            DynamicUser = true;
            SupplementaryGroups = [ "pipewire" ];
          };
      };
  };
}
