{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    systemWide = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
