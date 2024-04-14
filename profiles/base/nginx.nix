# Better default for Nginx
{ config, lib, ... }: {
  config = lib.mkIf config.services.nginx.enable {
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    services.nginx = {
      enableReload = true;

      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;
      recommendedZstdSettings = lib.mkDefault true;
      recommendedBrotliSettings = lib.mkDefault true;

      # create a access log file every vhost
      commonHttpConfig = ''
        access_log /var/log/nginx/access-$server_name.log combined;
      '';

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

