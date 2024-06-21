{ pkgs, config, lib, ... }:
let
  cfg = config.entropia.kiosk;
in
{
  options.entropia.kiosk = {
    enable = lib.mkEnableOption "kisok display";

    url = lib.mkOption {
      description = "URL to open";
      type = lib.types.str;
    };

    flip180 = lib.mkOption {
      default = false;
      description = "Flip the display by 180 degress";
      type = lib.types.bool;
    };

    output = lib.mkOption {
      default = "HDMI-A-1";
      type = lib.types.str;
    };
  };


  config = lib.mkIf cfg.enable {
    # Rotate the framebuffer to make boot log readable :)
    boot.kernelParams =
      if cfg.flip180 then
        [ "fbcon=rotate:1" ]
      else
        [ "fbcon=rotate:3" ];

    # WL_OUTPUT must be set otherwise touch input transformation is brocken
    services.udev.extraRules = ''
      ENV{ID_INPUT_TOUCHSCREEN}=="1",ENV{WL_OUTPUT}="HDMI1"
    '';

    services.dbus.enable = true;

    environment.variables = {
      NIXOS_OZONE_WL = 1;
    };

    programs.chromium = {
      enable = true;
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = false;
      };
    };

    programs.sway.enable = true;

    environment.etc."sway/config".text = ''
      xwayland disable

      input * {
        map_to_output ${cfg.output}
      }

      output ${cfg.output} {
        transform ${if cfg.flip180 then "90" else "270"}
      }

      exec ${lib.getExe pkgs.chromium} --kiosk ${cfg.url}
    '';

    # autologin and start sway
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "systemd-cat -t sway sway";
          user = "kiosk";
        };
        default_session = initial_session;
      };
    };

    users.users.kiosk = {
      isNormalUser = true;
      extraGroups = [ "input" ];
    };
  };
}
