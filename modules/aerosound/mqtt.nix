{ self, config, lib, pkgs, ... }: {
  options.services.aerosound.mqtt = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
    };
  };

  config = {
    systemd.services.mqtt-hass-discovery = {
      wantedBy = [ "aerosound.target" ];
      requires = [ "shairport-sync.service" ];
      after = [ "shairport-sync.service" ];
      environment = {
        INSTANCE_PREFIX = config.networking.hostName; 
        MQTT_HOSTNAME = config.services.aerosound.mqtt.hostname; 
      };
      script = "${lib.getExe self.packages.${pkgs.system}.mqtt-publisher}";
    };
  };
}
