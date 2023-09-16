{
  config = {
    users.users = {
      xanderio = {
        isNormalUser= true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDvsq3ecdR4xigCpOQVfmWZYY74KnNJIJ5Fo0FsZMGW"
        ];
      };
      evlli = {
        isNormalUser= true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjb/pugEDmRXP0Qr/vxgJu3kUslpGWLwgVzDnlXZcwk"
        ];
      };
    };
  };
}
