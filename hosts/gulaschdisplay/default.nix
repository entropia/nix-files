{ pkgs, lib, ... }: {

  imports = [
    ../../profiles/raspberry_pi/4.nix
  ];

  config = {
    entropia.users = [ "paule" ];

    hardware.raspberry-pi."4" = {
      poe-plus-hat.enable = true;
    };

    services.gulaschdisplay.enable = true;

    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
      initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
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
      gulaschdisplay-client
    ];

    nix.settings.experimental-features = "nix-command flakes";

    networking.useNetworkd = true;
    systemd.network.wait-online.anyInterface = true;

    nixpkgs.config = {
      allowUnfree = true;
    };

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

    sdImage.populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          [pi3]
          kernel=u-boot-rpi3.bin

          [pi02]
          kernel=u-boot-rpi3.bin

          [pi4]
          kernel=u-boot-rpi4.bin
          enable_gic=1
          armstub=armstub8-gic.bin

          # Otherwise the resolution will be weird in most cases, compared to
          # what the pi3 firmware does by default.
          disable_overscan=1

          # Supported in newer board revisions
          arm_boost=1

          [cm4]
          # Enable host mode on the 2711 built-in XHCI USB controller.
          # This line should be removed if the legacy DWC2 controller is required
          # (e.g. for USB device mode) or if USB support is not required.
          otg_mode=1

          [all]
          # Boot in 64-bit mode.
          arm_64bit=1

          # U-Boot needs this to work, regardless of whether UART is actually used or not.
          # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
          # a requirement in the future.
          enable_uart=1

          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1

          hdmi_force_hotplug:0=1
          hdmi_force_hotplug:1=1
          hdmi_drive=2
          max_framebuffers=2

          dtoverlay=vc4-fkms-v3d
        '';

      in
      lib.mkForce ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

        # Add the config
        cp ${configTxt} firmware/config.txt

        # Add pi3 specific files
        cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin

        # Add pi4 specific files
        cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
        cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb firmware/
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb firmware/
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb firmware/
      '';
  };
}
