{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
        ({lib, pkgs, ...}: {
          system.stateVersion = "23.05";
          boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" "cma=320M"];
  	      hardware.enableRedistributableFirmware = true;
	        networking.wireless.enable = true;
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPliatform.system = "aarch64-linux";
          #nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
          # ... extra configs as above
          
          environment.systemPackages = with pkgs; [firefox];
          users.users.hassenix = {
            isNormalUser = true;
            home = "/home/hassenix";
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = [ "" ];
          };
          
          services.cage = {
            enable = true; 
            extraArguments = [ "-r" "-- firefox --kiosk https://hass.club.entropia.de" ]; 
          };
        })
      ];
    };
    images.rpi3 = nixosConfigurations.rpi3.config.system.build.sdImage;
  };
}
