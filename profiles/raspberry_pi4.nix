{ pkgs, nixos-hardware, ... }: {
  imports = [
    ./raspberry_pi_common.nix
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  config = {
    # Workaround for https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    nixpkgs.config.packageOverrides = pkgs: {
      makeModulesClosure = x:
        pkgs.makeModulesClosure (x // { allowMissing = true; });
    };

    hardware = {
      raspberry-pi."4" = {
        apply-overlays-dtmerge.enable = true;
        fkms-3d.enable = true;
      };
    };

    boot.kernelParams = [
      "cma=320M"
    ];
  };
}
