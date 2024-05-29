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

    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];

    systemd.services.tailscale-autoconnect = {
        description = "Automatic connection to Tailscale";

        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";
        serviceConfig.User = "root";

        script = with pkgs; ''
          sleep 2

          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
          if [ $status = "Running" ]; then # if so, then do nothing
            exit 0
          fi

          ${tailscale}/bin/tailscale up -authkey tskey-auth-XXXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        '';
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
        Environment = [
          "WLR_LIBINPUT_NO_DEVICES = 1"
        ];
      };

    };
    systemd.targets.graphical.wants = [ "gulaschdisplay-client.service" ];
  };
}
