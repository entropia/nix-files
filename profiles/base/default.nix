{ inputs, lib, pkgs, ... }: {
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

    nix.gc = {
      automatic = true;  
      options = "--delete-older-than 2d";
    };

    nix.settings = {
      trusted-users = [ "@wheel" ];
      trusted-substituters = [ "https://entropia.cachix.org" ];
      substituters = [ "https://entropia.cachix.org" ];
      trusted-public-keys = [ "entropia.cachix.org-1:a3vy2scFVr0sQvtp2CPlOlzUKmPfbvs1/9VFsqqI5Sk=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };

    programs.htop.enable = true;
    programs.mtr.enable = true;
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
      withPython3 = false;
    };

    environment.systemPackages = with pkgs; [
      bind.dnsutils # for dig
      tcpdump
    ];

    # connect to node using local user name
    deployment.targetUser = lib.mkDefault null;
  };
}
