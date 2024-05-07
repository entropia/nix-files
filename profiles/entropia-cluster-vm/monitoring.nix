{ config, ... }: {
  x.sops.secrets."profiles/entropia-cluster-vm/vmagent-remote-write-basic-auth-password" = {};

  services.prometheus.exporters.node.enable = true;

  services.vmagent = {
    enable = true;
    remoteWrite = {
      url = "https://stats.entropia.de/prometheus/api/v1/write";
      basicAuthUsername = "meow";
      basicAuthPasswordFile = config.sops.secrets."profiles/entropia-cluster-vm/vmagent-remote-write-basic-auth-password".path;
    };
    extraArgs = [
      "-remoteWrite.flushInterval=30s"
      "-remoteWrite.showURL"
    ];
    prometheusConfig = {
      global = {
        external_labels = {
          environment = "prod";
          instance = "${config.networking.hostName}.entropia.de";
        };
        scrape_interval = "1m";
        scrape_timeout = "10s";
      };
      scrape_configs = [
        {
          job_name = "vmagent";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:8429" ];
            }
          ];
        }
        {
          job_name = "node";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
    };  
  };
}
