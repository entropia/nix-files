{ inputs, ... }: {
  perSystem = { system, ... }: {
    cloudInitImages.default = (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ({ config, lib, pkgs, modulesPath, ... }: {
          imports = [
            ../profiles/base
            (modulesPath + "/profiles/minimal.nix")
            (modulesPath + "/profiles/qemu-guest.nix")
            (modulesPath + "/installer/cd-dvd/iso-image.nix")
            inputs.colmena.nixosModules.deploymentOptions
            inputs.sops-nix.nixosModules.default
          ];

          nixpkgs.hostPlatform = system;
          system.stateVersion = "24.05";

          isoImage = {
            makeEfiBootable = true;
            forceTextMode = true;
            isoBaseName = "nixos-cloudinit-entropia";
          };

          networking = {
            useDHCP = true;
            useNetworkd = true;
          };

          services.cloud-init = {
            enable = true;
            network.enable = true;
            settings = {
              cloud_init_modules = lib.mkForce [
                "seed_random"
                "bootcmd"
                "resolv_conf"
                "rsyslog"
                "users-groups"
                "ssh"
              ];

              cloud_config_modules = lib.mkForce [
                "set-passwords"
                "timezone"
                "disable_ec2_metadata"
              ];

              cloud_final_modules = lib.mkForce [
                "final-message"
              ];

            };
          };
        })
      ];
    }).config.system.build.isoImage;
  };
}
