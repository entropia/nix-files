{ inputs, lib, ... }: {
  imports = [
    ../../users
    ./nginx.nix
    inputs.self.nixosModules.default
  ];

  config = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "without-password";
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "oops@lists.entropia.de";
    };

    security.sudo.wheelNeedsPassword = false;

    nix.settings = {
      trusted-users = [ "@wheel" ];
      trusted-substituters = [ "https://entropia.cachix.org" ];
      substituters = [ "https://entropia.cachix.org" ];
      trusted-public-keys = [ "entropia.cachix.org-1:a3vy2scFVr0sQvtp2CPlOlzUKmPfbvs1/9VFsqqI5Sk=" ];
    };

    # connect to node using local user name
    deployment.targetUser = lib.mkDefault null;
  };
}
