{
  isNormalUser = true;
  extraGroups = [ "wheel" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYwYILNJdKdyGfmOMpzOpkFNv9Cgq2eWu2j3YhFivVm"
  ];
}
