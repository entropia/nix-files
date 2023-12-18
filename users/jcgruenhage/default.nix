{
  config = {
    users.users.jcgruenhage = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+6i18ExXZENRxPhtIY8VP6y1JyxtcuCMk7pyC+W0MC opgpcard:0006:15454451"
      ];
    };
  };
}
