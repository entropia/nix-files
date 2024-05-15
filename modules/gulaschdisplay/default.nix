{ lib, config, pkgs, ... }:
let
  cfg = config.services.gulaschdisplay;
in
{
  options.services.gulaschdisplay = {
    enable = lib.mkEnableOption "gulaschdisplay";
  };

  config = lib.mkIf cfg.enable {

    environment.variables = {
      NIXOS_OZONE_WL = "1";
    };

    programs.sway.enable = true;
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "sway";
          user = "guest";
        };
        default_session = initial_session;
      };
    };
    users.users.guest = {
      isNormalUser = true;
      uid = 1001;
      password = "guest";
      extraGroups = [ "wheel" ];
    };

    systemd.services."gulaschdisplay-client" = {
      after = [ "greetd.service" ];
      partOf = [ "greetd.service" ];

      path = with pkgs; [
        chromium
        busybox
      ];

      script = ''
        while ! pgrep -f "sway$" > /dev/null; do
          # Set optional delay
          sleep 0.1
        done
        export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -f 'sway$').sock
        ${pkgs.gulaschdisplay-client}/bin/gulaschdisplay-client
      '';

      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
        User = "guest";
      };

    };
    systemd.targets.graphical.wants = [ "gulaschdisplay-client.service" ];
  };
}
