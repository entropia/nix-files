# Temporary copy of nixos-common.nix to allow of an easier migration
# to a flake based setup
{ inputs, ... }:
{
  config = {
    nix = {
      gc = {
        automatic = true;
        dates = "Sat 05:15";
        options = "--delete-older-than 60d";
      };
      optimise = {
        automatic = true;
        dates = [ "05:45" ];
      };

      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings.trusted-users = [ "@wheel" ];
    };

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
