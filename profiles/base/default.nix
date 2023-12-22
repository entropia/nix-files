{ self, lib, ... }: {
  imports = [
    ../../users
    ./acme.nix
    ./nginx.nix
    ./nixos.nix
    ./openssh.nix
    self.nixosModules.default
  ];

  config = {
    # connect to node using local user name
    deployment.targetUser = lib.mkDefault null;
  };
}
