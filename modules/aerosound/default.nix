{ config, lib, ... }:
let
  cfg = config.services.aerosound;
in
{
  imports = [
    ./pipewire.nix
    ./shairport.nix
    ./mqtt.nix
  ];

  options.services.aerosound = {
    enable = lib.mkEnableOption "aerosound";
  };

  config = lib.mkIf cfg.enable {
    hardware.raspberry-pi."4".digi-amp-plus.enable = true;

    # disable on pi audio jack
    boot.extraModprobeConfig = ''
      blacklist snd_bcm2835
    '';

    systemd.targets.aerosound = {
      description = "Common target for all Aerosound services.";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
