{ pkgs, nixpkgs, ... }: {
  imports = [
    (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    hardware.enableRedistributableFirmware = true;

    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };

    boot = {
      tmp.cleanOnBoot = true;
      kernelParams = [
        "dwc_otg.lpm_enable=0"
        "cma=320M"
        "plymouth.ignore-serial-consoles"
      ];
      initrd = {
        includeDefaultModules = false;
        kernelModules = [ "vc4" ];
        availableKernelModules =
          [ "usbhid" "usb_storage" "vc4" "bcm2835_dma" "i2c_bcm2835" ];
      };
    };

    systemd.enableEmergencyMode = false;

    services.udisks2.enable = false;
    documentation.enable = false;
    powerManagement.enable = false;
    programs.command-not-found.enable = false;

    sdImage.compressImage = false;
  };
}
