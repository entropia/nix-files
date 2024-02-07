{ pkgs, config, ... }:
{
  config = {
    networking.firewall = {
      allowedTCPPorts = [
        # airplay 1 
        3689
        5000
        # airplay 2
        7000
      ];
      allowedUDPPorts = [
        # AirPlay 2
        319
        320
      ];
      allowedTCPPortRanges = [
        # AirPlay 2 
        { from = 32768; to = 60999; }
      ];
      allowedUDPPortRanges = [
        # AirPlay 1
        { from = 6000; to = 6009; }

        # AirPlay 2
        { from = 32768; to = 60999; }
      ];
    };

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    systemd.services.nqptp = {
      wantedBy = [ "aerosound.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.nqptp}/bin/nqptp";
        Restart = "always";
        RestartSec = 10;
      };
    };

    systemd.services.shairport-sync = {
      wantedBy = [ "aerosound.target" ];
      wants = [ "avahi-daemon.service" ];
      requires = [ "nqptp.service" "pipewire.service" "network-online.target" ];
      after = [ "network-online.target" "avahi-daemon.service" "nqptp.service" "pipewire.service" ];
      serviceConfig =
        let
          shairport =
            (pkgs.shairport-sync.override {
              enableMetadata = true;
              enableAirplay2 = true;
            }).overrideAttrs (old: {
              configureFlags = old.configureFlags ++ [ "--with-mqtt-client" ];
              buildInputs = old.buildInputs ++ [ pkgs.mosquitto.lib pkgs.mosquitto.dev ];
            });

          shairportConfigFile = pkgs.writeText "shairport.conf" ''
            general = {
            	name = "${config.networking.hostName}";
            	output_backend = "pw";
            	mdns_backend = "avahi";
            };

            metadata = {
            	enabled = "yes"; 
            	include_cover_art = "yes";
            	cover_art_cache_directory = "/tmp/shairport-sync/.cache/coverart";
            	pipe_name = "/tmp/shairport-sync-metadata";
            	pipe_timeout = 5000;
            };

            pw = {
            	application_name = "Shairport Sync";
            	node_name = "Shairport Sync";
            };

            mqtt = {
            	enabled = "yes";
            	hostname = "${config.services.aerosound.mqtt.hostname}";
            	port = ${toString config.services.aerosound.mqtt.port};
            	topic = "aerosound/${config.networking.hostName}/shairport";
            	publish_parsed = "yes";
            	publish_cover = "yes";
            	enable_remote = "yes";
            };
          '';
        in
        {
          ExecStart = "${shairport}/bin/shairport-sync -c ${shairportConfigFile}";
          Restart = "always";
          RestartSec = 10;
        };
    };
  };
}
