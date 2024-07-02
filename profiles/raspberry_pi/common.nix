{ pkgs, lib, inputs, ... }: {
  imports = [
    (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    hardware.enableRedistributableFirmware = true;
    boot.supportedFilesystems = {
      zfs = lib.mkForce false;
    };

    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [
      libraspberrypi
    ];

    boot.tmp.cleanOnBoot = true;

    # reduce system closure size
    systemd.enableEmergencyMode = false;
    services.udisks2.enable = false;
    documentation.enable = false;
    powerManagement.enable = false;
    programs.command-not-found.enable = false;

    # Don't compress the image as this requires quite some CPU time during build.
    sdImage.compressImage = false;
  };
}
