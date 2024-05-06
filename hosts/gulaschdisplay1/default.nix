{ pkgs, ... }: {

  imports = [
    ../../profiles/raspberry_pi/4.nix
  ];

  config = {
    entropia.users = [ "paule" ];

    hardware.raspberry-pi."4" = {
      poe-plus-hat.enable = true;
    };

    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
      # initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      chromium
      libraspberrypi
      raspberrypi-eeprom
      wdisplays
      killall
      htop
      git
    ];

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

    nix.settings.experimental-features = "nix-command flakes";

    networking.hostName = "gulaschdisplay1";

    deployment.targetHost = "10.214.227.106";

    networking.useNetworkd = true;
    systemd.network.wait-online.anyInterface = true;

    systemd.network.networks."10-lan" = {
      enable = true;
      name = "en*";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
        DNSOverTLS = "opportunistic";
        IPv6AcceptRA = "yes";
        IPv6PrivacyExtensions = "yes";
      };
    };
    system.stateVersion = "23.11";
  };
}
