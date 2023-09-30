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

    # UDev rule for rotating the Touch Input too
    services.udev.extraRules =
      "ENV{ID_VENDOR_ID}==\"04e7\",ENV{ID_MODEL_ID}==\"0022\",ENV{WL_OUTPUT}=\"HDMI1\",ENV{LIBINPUT_CALIBRATION_MATRIX}=\"${if cfg.flip180 then "0 1 0 -1 0 1" else "0 -1 1 1 0 0"}\"\n";

    nixpkgs.config.packageOverrides = pkgs: {
      cage = pkgs.cage.override { xwayland = null; };
      firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          DisableDeveloperTools = true;
          OfferToSaveLogins = false;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };

        extraPrefs = ''
          // "disable" the pinch to zoom by require a gesture that is large then the screen
          pref("browser.gesture.pinch.threshold", 5000);

          // disable the "insecure password" warning when using HTTP
          pref("security.insecure_password.ui.enabled", false);
        '';
      };
    };

    systemd.services."serial-getty@ttyS0".enable = false;
    systemd.services."serial-getty@hvc0".enable = false;
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@".enable = false;

    users.users.cage = {
      isNormalUser = true;
      uid = 1000;
      group = "cage";
    };

    users.groups.cage = { };

    services.dbus.enable = true;

    services.cage = {
      enable = true;
      user = "cage";
      program = "${lib.getExe pkgs.firefox} --kiosk ${cfg.url}";
      extraArguments = [ "-d" ];
      environment = {
        MOZ_ENABLE_WAYLAND = "1";
        LIBSEAT_BACKEND = "logind";
        # WAYLAND_DEBUG = "1"; # Enable for debugging purposes
      };
    };

    systemd.services."cage-tty1" = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "2s";
      };
    };

    systemd.services."wlr-randr" = {
      after = [ "cage-tty1.service" ];
      partOf = [ "cage-tty1.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.wlr-randr}/bin/wlr-randr --output ${cfg.output} --transform ${if cfg.flip180 then "270" else "90"}";

        Restart = "on-failure";
        RestartSec = "2s";
      };
      environment = {
        XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.cage.uid}/";
      };
    };

    systemd.targets.graphical.wants = [ "wlr-randr.service" ];
  };
}
