{
  config = {
    users.users.evlli = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjb/pugEDmRXP0Qr/vxgJu3kUslpGWLwgVzDnlXZcwk"
      ];
    };
  };
}
