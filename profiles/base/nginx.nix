# Better default for Nginx
{ config, lib, ... }: {
  config = lib.mkIf config.services.nginx.enable {
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    services.nginx = {
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      # Nginx sends all the access logs to /var/log/nginx/access.log by default.
      # instead of going to the journal!
      commonHttpConfig = "access_log syslog:server=unix:/dev/log;";

      sslDhparam = config.security.dhparams.params.nginx.path;
    };

    # start nginx after dhparams have been generated
    systemd.services.nginx.wants = [ "dhparams-gen-nginx.service" ];

    security.dhparams = {
      enable = true;
      params.nginx = { };
    };
  };
}
