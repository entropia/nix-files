{config, ...}: {
  config = {
    networking.firewall = {
    allowedTCPPorts = [ 4444 5355 ];
    allowedUDPPorts = [ 5355 ];
    };
    services.spotifyd = {
      enable = true;
      settings = {
        bitrate = 320;

        device_name = config.networking.hostName;
        device_type = "speaker";

        dbus_type = "system";
        backend = "pulseaudio";

        volume_normalisation = true;
        initial_volume = 20;

        zeroconf-port = 4444;
      };
    };
  };
}
