{ config, lib, ... }:
let
  cfg = config.entropia.vaporsound;
in
{
  imports = [
    ./pipewire.nix
    ./spotifyd.nix
    ./uxplay.nix
  ];

  options.entropia.vaporsound = {
    enable = lib.mkEnableOption "vaporsound";
  };

  config = lib.mkIf cfg.enable {
    hardware.raspberry-pi."4".digi-amp-plus.enable = true;

    # disable on pi audio jack
    boot.extraModprobeConfig = ''
      blacklist snd_bcm2835
    '';

    systemd.targets.vaporsound = {
      description = "Common target for all Vaporsound services.";
      wantedBy = [ "multi-user.target" ];
    };

  };
}
