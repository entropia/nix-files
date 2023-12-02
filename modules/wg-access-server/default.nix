{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.services.wg-access-server;

  settingsFormat = pkgs.formats.yaml { };
in
{

  options.services.wg-access-server = {
    enable = mkEnableOption "wg-access-server";

    package = mkOption {
      type = types.package;
      default = pkgs.wg-access-server;
      description = "The wg-access-server package";
    };

    settings = mkOption {
      type = settingsFormat.type;
      default = { };
      description = "See https://www.freie-netze.org/wg-access-server/2-configuration/ for possible options";
    };

    oidcClientSecretFile = mkOption {
      type = types.path;
      description = "The path to a file containing the oidc client secret";
    };

    adminPasswordFile = mkOption {
      type = types.path;
      description = "The path to a file containing the password for the admin user";
    };

    wireguardPrivateKey = mkOption {
      type = types.path;
      description = "The path to a file containing the wireguard private key (generate via wg genkey)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.wg-access-server.settings = {
      storage = "sqlite3://db.sqlite";
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };

    systemd.services.wg-access-server = {
      description = "WG access server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      script = ''
        export WG_ADMIN_PASSWORD="$(< $CREDENTIALS_DIRECTORY/WG_ADMIN_PASSWORD )"
        export WG_WIREGUARD_PRIVATE_KEY="$(< $CREDENTIALS_DIRECTORY/WG_WIREGUARD_PRIVATE_KEY )"

        mkdir -p $STATE_DIRECTORY/website
        rm -f $STATE_DIRECTORY/website/build
        ln -s ${cfg.package}/site/ $STATE_DIRECTORY/website/build

        export OIDC_CLIENT_SECRET="$(< $CREDENTIALS_DIRECTORY/OIDC_CLIENT_SECRET )"
        jq <${pkgs.writeText "config.yml" (builtins.toJSON cfg.settings)} \
          '.auth.oidc.clientSecret = $ENV.OIDC_CLIENT_SECRET' \
           > "$STATE_DIRECTORY/config.yml"
  
        ${lib.getExe cfg.package} serve --config "$STATE_DIRECTORY/config.yml"
      '';

      path = with pkgs; [
        iptables
        # needed by startup script
        jq
      ];

      serviceConfig =
        let
          capabilities = [
            "CAP_NET_ADMIN"
          ] ++ lib.optional cfg.settings.dns.enabled "CAP_NET_BIND_SERVICE";
        in
        {
          WorkingDirectory = "/var/lib/wg-access-server";
          StateDirectory = "wg-access-server";

          LoadCredential = [
            "WG_ADMIN_PASSWORD:${cfg.adminPasswordFile}"
            "WG_WIREGUARD_PRIVATE_KEY:${cfg.wireguardPrivateKey}"
            "OIDC_CLIENT_SECRET:${cfg.oidcClientSecretFile}"
          ];

          # Hardening
          DynamicUser = true;
          AmbientCapabilities = capabilities;
          CapabilityBoundingSet = capabilities;
        };
    };
  };
}
