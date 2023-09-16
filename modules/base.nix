{ lib, ... }: {
  imports = [ ./users.nix ];
  config = {

    services.openssh = {
      enable = true;
    };

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "@wheel" ];

    # connect to node using local user name
    deployment.targetUser = lib.mkDefault null;
  };
}
