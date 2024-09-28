{ pkgs, config, ... }: {
  config = {
    x.sops.secrets = {
      "services/wg-access-server/secrets" = {};
    };
    
    services.wg-access-server = {
      enable = true;
      secretsFile = config.sops.secrets."services/wg-access-server/secrets".path;

      settings = {
        wireguard.mtu = 1280;
        vpn = {
          cidr = "192.168.73.0/24";
          # disable ipv6
          cidrv6 = 0;
          nat44 = false;
          nat66 = false;
          clientIsolation = false;
          allowedIPs = [
            "192.168.73.0/24"
            # oob network
            "192.168.72.0/24"
            # club internal networks
            "10.214.224.0/24"
            "10.214.225.0/24"
            "10.214.226.0/24"
            "10.214.227.0/24"

            # ffka hyper hyper visor
            "192.168.202.0/24"
            # GH Infra
            "192.168.62.0/24"
          ];
        };
        dns.enabled = false;
        clientConfig.mtu = config.services.wg-access-server.settings.wireguard.mtu;


        auth.oidc = {
          name = "Entropia SSO";
          issuer = "https://sso.entropia.de/realms/entropia";
          clientID = "wg-oob";
          redirectURL = "https://wg.oob.entropia.de/callback";
          scopes = [ "openid" "profile" ];
          claimMapping = {
            admin = "'entropia-oops' in roles";
          };
          claimsFromIDToken = false;
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 51820 ];
    };

    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
  
      virtualHosts."wg.oob.entropia.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = "http://localhost:8000";
      };
    };
  };
}
