{ pkgs, nixpkgs, nixos-hardware, ... }: {
  imports = [
    (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    # Workaround for https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    nixpkgs.config.packageOverrides = pkgs: {
      makeModulesClosure = x:
        pkgs.makeModulesClosure (x // { allowMissing = true; });
    };

    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };

    environment.systemPackages = with pkgs; [
      libraspberrypi
    ];

    hardware = {
      raspberry-pi."4" = {
        apply-overlays-dtmerge.enable = true;
        fkms-3d.enable = true;
      };
    };

    boot = {
      tmp.cleanOnBoot = true;
      kernelParams = [
        "cma=320M"
      ];
    };

    systemd.enableEmergencyMode = false;

    services.udisks2.enable = false;
    documentation.enable = false;
    powerManagement.enable = false;
    programs.command-not-found.enable = false;

    sdImage.compressImage = false;
  };
}
