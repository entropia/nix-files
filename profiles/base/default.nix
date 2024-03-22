{ inputs, lib, ... }: {
  imports = [
    ../../users
    inputs.self.nixosModules.default
  ];

  config = {
    services.openssh = {
      enable = true;
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
