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
    nix.settings.trusted-users = [ "@wheel" ];

    # connect to node using local user name
    deployment.targetUser = lib.mkDefault null;
  };
}
