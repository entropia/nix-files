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