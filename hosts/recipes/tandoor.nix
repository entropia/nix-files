{ config, lib, pkgs, ... }: {
  config = {
    x.sops.secrets = {
      "services/tandoor/oidc_secret" = { };
      "services/tandoor/email_password" = { };
    };

    sops.templates."tandoor-socialaccount-providers" = {
      content = builtins.toJSON {
        openid_connect = {
          OAUTH_PKCE_ENABLED = "True";
          APPS = [
            {
              provider_id = "keycloak";
              name = "Entropia SSO";
              client_id = "recipes.entropia.de";
              secret = config.sops.placeholder."services/tandoor/oidc_secret";
              settings.server_url = "https://sso.entropia.de/realms/entropia/.well-known/openid-configuration";
            }
          ];
        };
      };
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [{
        name = "tandoor_recipes";
        ensureDBOwnership = true;
      }];
      ensureDatabases = [
        "tandoor_recipes"
      ];
    };

    systemd.services.nginx.serviceConfig.SupplimentaryGroups = [ "tandoor_recipes" ];

    services.nginx = {
      enable = true;
      virtualHosts."recipes.entropia.de" = {
        enableACME = true;
        forceSSL = true;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://${config.services.tandoor-recipes.address}:${toString config.services.tandoor-recipes.port}";
          recommendedProxySettings = true;
        };
        locations."/media/".alias = "/var/lib/tandoor-recipes/";
        locations."= /metrics" = {
          return = "404";
        };
      };
    };

    services.vmagent.prometheusConfig.scrape_configs = [
      {
        job_name = "tandoor";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [ "${config.services.tandoor-recipes.address}:${toString config.services.tandoor-recipes.port}" ];
          }
        ];
      }
    ];

    services.tandoor-recipes = {
      enable = true;
      extraConfig = {
        SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        SOCIALACCOUNT_ONLY = true;

        PRIVACY_URL = "https://entropia.de/Entropia:Datenschutz";
        IMPRINT_URL = "https://entropia.de/Impressum";

        DB_ENGINE = "django.db.backends.postgresql";
        POSTGRES_DB = "tandoor_recipes";

        ENABLE_METRICS = true;

        SORT_TREE_BY_NAME = true;

        # Space with ID 1 is public (entropia space)
        SOCIAL_DEFAULT_ACCESS = 1;
        SOCIAL_DEFAULT_GROUP = "user";

        EMAIL_HOST = "mail.entropia.de";
        EMAIL_PORT = 587;
        EMAIL_HOST_USER = "recipes@entropia.de";
        EMAIL_USE_TLS = true;
        DEFAULT_FROM_EMAIL = "recipes@entropia.de";
      };
    };

    users.users.tandoor_recipes = {
      isSystemUser = true;
      group = "tandoor_recipes";
    };
    users.groups.tandoor_recipes = { };

    systemd.services.tandoor-recipes = {
      serviceConfig = {
        ExecStart =
          let
            secretKeyFile = "/var/lib/tandoor-recipes/nixos-secret-key";

            startScript = pkgs.writeShellScript "start" ''
              export EMAIL_HOST_PASSWORD=$(< ''${CREDENTIALS_DIRECTORY}/email_password)
              export SOCIALACCOUNT_PROVIDERS=$(< ''${CREDENTIALS_DIRECTORY}/socialaccount-providers)

              if [[ ! -f '${secretKeyFile}' ]]; then
                (
                  umask 0377
                  tr -dc A-Za-z0-9 < /dev/urandom | head -c64 | ${pkgs.moreutils}/bin/sponge '${secretKeyFile}'
                )
              fi
              export SECRET_KEY=$(< '${secretKeyFile}')
              if [[ ! $SECRET_KEY ]]; then
                echo "SECRET_KEY is empty, refusing to start."
                exit 1
              fi

              ${config.services.tandoor-recipes.package.python.pkgs.gunicorn}/bin/gunicorn recipes.wsgi
            '';
          in
          lib.mkForce startScript;
        LoadCredential = [
          "socialaccount-providers:${config.sops.templates.tandoor-socialaccount-providers.path}"
          "email_password:${config.sops.secrets."services/tandoor/email_password".path}"
        ];
        BindReadOnlyPaths = [
          config.sops.templates.tandoor-socialaccount-providers.path
          config.sops.secrets."services/tandoor/email_password".path
        ];
        # With DynamicUser enabled nginx is unable to access the StateDirectory where the images are stored.
        DynamicUser = lib.mkForce false;
      };
    };
  };
}
