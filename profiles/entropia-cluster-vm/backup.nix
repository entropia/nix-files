{ config, lib, pkgs, ... }: {
  x.sops.secrets."hosts/${config.networking.hostName}/backup_zweitwohnsitz_password" = {};
 
  services.borgbackup.jobs.zweitwohnsitz = {
    paths = [ "/var/backup" "/var/lib" "/root" ];
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
    preHook = lib.mkIf config.services.postgresql.enable ''
      ${lib.getExe pkgs.sudo} -u postgres ${pkgs.postgresql}/bin/pg_dumpall --globals-only > /var/backup/postgresql/globals
      ${lib.getExe pkgs.sudo} -u postgres ${pkgs.postgresql}/bin/psql -t -A -c "SELECT datname FROM pg_database WHERE datname <> ALL ('{template0,template1,postgres}')" | ${pkgs.findutils}/bin/xargs -I DBNAME ${lib.getExe pkgs.sudo} -u postgres ${pkgs.postgresql}/bin/pg_dump -F directory -f /var/backup/postgresql/DBNAME DBNAME
    '';
    postCreate = lib.mkIf config.services.postgresql.enable ''
      rm -r /var/backup/postgresql/*
    '';
    readWritePaths = lib.optionals config.services.postgresql.enable [ "/var/backup/postgresql" ];
    compression = "auto,zlib";
    startAt = "daily";
  };

  systemd.tmpfiles.rules = lib.mkIf config.services.postgresql.enable [
    "d /var/backup/postgresql 0700 postgres - - -"
  ];
}
