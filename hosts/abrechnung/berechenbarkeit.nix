{ config, pkgs, ... }: {
  x.sops.secrets."hosts/abrechnung/berechenbarkeit_vouch_proxy_env" = {};

  systemd.services.berechenbarkeit = {
    description = "berechenbarkeit";
    after = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
   
    environment = {
      BERECHENBARKEIT_STORAGE_BASE_PATH = "/var/lib/berechenbarkeit/storage";
    };
    preStart = ''
      mkdir -p /var/lib/berechenbarkeit/storage
    '';

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      User = "berechenbarkeit";
      StateDirectory = "berechenbarkeit";
      ExecStart = "${pkgs.berechenbarkeit}/bin/berechenbarkeit --database-url 'postgres:///berechenbarkeit?host=/run/postgresql'";
      Restart = "always";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "berechenbarkeit" ];
    ensureUsers = [
      { name = "berechenbarkeit";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."abrechnung.entropia.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
    };
  };

  services.vouch-proxy = {
    enable = true;
    servers."abrechnung.entropia.de" = {
      clientId = "abrechnung.entropia.de";
      port = 12300;
      environmentFiles = [ config.sops.secrets."hosts/abrechnung/berechenbarkeit_vouch_proxy_env".path ];
    };
  };
}
