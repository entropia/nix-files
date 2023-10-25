{
  isNormalUser = true;
  extraGroups = [ "wheel" "audio" "video" "pipewire" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDvsq3ecdR4xigCpOQVfmWZYY74KnNJIJ5Fo0FsZMGW"
  ];
}
