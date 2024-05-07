{ config, ... }: {
  x.sops.secrets."hosts/${config.networking.hostName}/backup_zweitwohnsitz_password" = {};
 
  services.borgbackup.jobs.zweitwohnsitz = {
    paths = [ "/var/lib" "/root" ];
    exclude = [ "'**/.cache'" ];
    doInit = true;
    repo =  "ssh://borgbackup@zweitwohnsitz.entropia.de/./${config.networking.hostName}.${config.networking.domain}";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets."hosts/${config.networking.hostName}/backup_zweitwohnsitz_password".path}";
    };
    environment = {
      BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
      BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
    };
    compression = "auto,zlib";
    startAt = "daily";
  };
}
