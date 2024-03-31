{
  isNormalUser = true;
  extraGroups = [ "wheel" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsWelWGB1T9d0s+MkIGnxCSfBwfLMrNEYbhatSUEH/a cardno:000618651900"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7iTFFz0i5BDIQji/H2EhDIa2alVhocgkISNNHrf+GU cardno:000618693870"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwfwNlqnctDdC6f+xa4UZJec5uW0cRU6MsUMFxY9GTD henry@XPS-13-7390"
  ];
}
