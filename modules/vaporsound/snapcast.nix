{
  services.snapserver = {
    enable = true;
    codec = "flac";
    streams = {
      pipewire = {
        type = "pipe";
        location = "/run/snapserver/pipewire";
      };
    };
  };
}
