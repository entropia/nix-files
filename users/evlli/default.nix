{
  isNormalUser = true;
  extraGroups = [ "wheel" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjb/pugEDmRXP0Qr/vxgJu3kUslpGWLwgVzDnlXZcwk"
    "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBLOrW0Z970f4RbXRYuXNKAkulKLyVApQiqmW8Mk6RWr5V2mJ7wQlsKsFcUPk63WLF5rJAiWo4hqneqLYFFQEf9fUWWNs2K9LPGLaYPfYgJLCNYxx0pVuMEEsMt+IPV24kQ== openpgp:0x4D3B3663"
  ];
}
