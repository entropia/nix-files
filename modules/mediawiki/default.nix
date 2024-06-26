{
  config,
  pkgs,
  lib,
  ...
}:

let

  inherit (lib)
    mkDefault
    mkEnableOption
    mkPackageOption
    mkForce
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib)
    concatStringsSep
    literalExpression
    mapAttrsToList
    optional
    optionals
    optionalString
    types
    filterAttrs
    ;

  mediawikiName = name: "mediawiki-${name}";

  cacheDir = name: "/var/cache/mediawiki-${name}";
  stateDir = name: "/var/lib/mediawiki-${name}";

  # https://www.mediawiki.org/wiki/Compatibility
  php = pkgs.php81;

  pkg = name: conf: pkgs.stdenv.mkDerivation rec {
    pname = "${mediawikiName name}-full";
    inherit (src) version;
    src = conf.package;

    installPhase = ''
      mkdir -p $out
      cp -r * $out/

      # try removing directories before symlinking to allow overwriting any builtin extension or skin
      ${concatStringsSep "\n" (
        mapAttrsToList (k: v: ''
          rm -rf $out/share/mediawiki/skins/${k}
          ln -s ${v} $out/share/mediawiki/skins/${k}
        '') conf.skins
      )}

      ${concatStringsSep "\n" (
        mapAttrsToList (k: v: ''
          rm -rf $out/share/mediawiki/extensions/${k}
          ln -s ${
            if v != null then v else "$src/share/mediawiki/extensions/${k}"
          } $out/share/mediawiki/extensions/${k}
        '') conf.extensions
      )}
    '';
  };

  mediawikiScripts = name: conf:
    pkgs.runCommand "${mediawikiName name}-scripts"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/bin
        for i in changePassword.php createAndPromote.php userOptions.php edit.php nukePage.php update.php; do
          makeWrapper ${php}/bin/php $out/bin/${mediawikiName name}-$(basename $i .php) \
            --set MEDIAWIKI_CONFIG ${mediawikiConfig name conf} \
            --add-flags ${pkg name conf}/share/mediawiki/maintenance/$i
        done
      '';

  mediawikiConfig = name: conf: pkgs.writeText "LocalSettings.php" ''
    <?php
      # Protect against web entry
      if ( !defined( 'MEDIAWIKI' ) ) {
        exit;
      }

      $wgSitename = "${conf.name}";
      $wgMetaNamespace = false;

      ## The URL base path to the directory containing the wiki;
      ## defaults for all runtime URL paths are based off of this.
      ## For more information on customizing the URLs
      ## (like /w/index.php/Page_title to /wiki/Page_title) please see:
      ## https://www.mediawiki.org/wiki/Manual:Short_URL
      # $wgScriptPath = "";

      ## The protocol and server name to use in fully-qualified URLs
      $wgServer = "${conf.url}";

      ## The URL path to static resources (images, scripts, etc.)
      $wgResourceBasePath = $wgScriptPath;

      $wgArticlePath      = "/$1";
      $wgUsePathInfo      = true;

      ## The URL path to the logo.  Make sure you change this from the default,
      ## or else you'll overwrite your logo when you upgrade!
      $wgLogo = "$wgResourceBasePath/resources/assets/wiki.png";

      ## UPO means: this is also a user preference option

      $wgEnableEmail = true;
      $wgEnableUserEmail = true; # UPO

      $wgPasswordSender = "${conf.passwordSender}";

      $wgEnotifUserTalk = false; # UPO
      $wgEnotifWatchlist = false; # UPO
      $wgEmailAuthentication = true;

      ## Database settings
      $wgDBtype = "${conf.database.type}";
      $wgDBserver = "${conf.database.host}:${conf.database.socket}";
      $wgDBport = "${toString conf.database.port}";
      $wgDBname = "${conf.database.name}";
      $wgDBuser = "${conf.database.user}";
      ${
        optionalString (
          conf.database.passwordFile != null
        ) "$wgDBpassword = file_get_contents(\"${conf.database.passwordFile}\");"
      }

      ${
        optionalString (conf.database.type == "mysql" && conf.database.tablePrefix != null) ''
          # MySQL specific settings
          $wgDBprefix = "${conf.database.tablePrefix}";
        ''
      }

      ${
        optionalString (conf.database.type == "mysql") ''
          # MySQL table options to use during installation or update
          $wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
        ''
      }

      ## Shared memory settings
      $wgMainCacheType = CACHE_NONE;
      $wgMemCachedServers = [];

      ${
        optionalString (conf.uploadsDir != null) ''
          $wgEnableUploads = true;
          $wgUploadDirectory = "${conf.uploadsDir}";
        ''
      }

      $wgUseImageMagick = true;
      $wgImageMagickConvertCommand = "${pkgs.imagemagick}/bin/convert";

      # InstantCommons allows wiki to use images from https://commons.wikimedia.org
      $wgUseInstantCommons = false;

      # Periodically send a pingback to https://www.mediawiki.org/ with basic data
      # about this MediaWiki instance. The Wikimedia Foundation shares this data
      # with MediaWiki developers to help guide future development efforts.
      $wgPingback = true;

      ## If you use ImageMagick (or any other shell command) on a
      ## Linux server, this will need to be set to the name of an
      ## available UTF-8 locale
      $wgShellLocale = "C.UTF-8";

      ## Set $wgCacheDirectory to a writable directory on the web server
      ## to make your wiki go slightly faster. The directory should not
      ## be publicly accessible from the web.
      $wgCacheDirectory = "${cacheDir name}";

      # Site language code, should be one of the list in ./languages/data/Names.php
      $wgLanguageCode = "en";

      $wgSecretKey = file_get_contents("${stateDir name}/secret.key");

      # Changing this will log out all existing sessions.
      $wgAuthenticationTokenVersion = "";

      ## For attaching licensing metadata to pages, and displaying an
      ## appropriate copyright notice / icon. GNU Free Documentation
      ## License and Creative Commons licenses are supported so far.
      $wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
      $wgRightsUrl = "";
      $wgRightsText = "";
      $wgRightsIcon = "";

      # Path to the GNU diff3 utility. Used for conflict resolution.
      $wgDiff = "${pkgs.diffutils}/bin/diff";
      $wgDiff3 = "${pkgs.diffutils}/bin/diff3";

      # Enabled skins.
      ${concatStringsSep "\n" (mapAttrsToList (k: v: "wfLoadSkin('${k}');") conf.skins)}

      # Enabled extensions.
      ${concatStringsSep "\n" (mapAttrsToList (k: v: "wfLoadExtension('${k}');") conf.extensions)}


      # End of automatically generated settings.
      # Add more configuration options below.

      ${conf.extraConfig}
  '';

  enabledServers = filterAttrs (name: conf: conf.enable) config.services.mediawiki.servers;
in
{
  options = {
    services.mediawiki = {
      servers = mkOption {
        default = {};
        type = types.attrsOf (
          types.submodule (
            { config, name, ... }:
            {
              options = {
                enable = mkEnableOption "MediaWiki";

                package = mkPackageOption pkgs "mediawiki" { };

                finalPackage = mkOption {
                  type = types.package;
                  readOnly = true;
                  default = pkg name config;
                  defaultText = literalExpression "pkg";
                  description = ''
                    The final package used by the module. This is the package that will have extensions and skins installed.
                  '';
                };

                name = mkOption {
                  type = types.str;
                  default = "MediaWiki";
                  example = "Foobar Wiki";
                  description = "Name of the wiki. Defaults to the name of the attribute set.";
                };

                url = mkOption {
                  type = types.str;
                  default = "http://localhost";
                  example = "https://wiki.example.org";
                  description = "URL of the wiki.";
                };

                uploadsDir = mkOption {
                  type = types.nullOr types.path;
                  default = "${stateDir}/${name}-uploads";
                  description = ''
                    This directory is used for uploads of pictures. The directory passed here is automatically
                    created and permissions adjusted as required.
                  '';
                };

                passwordFile = mkOption {
                  type = types.path;
                  description = ''
                    A file containing the initial password for the administrator account "admin".
                  '';
                  example = "/run/keys/mediawiki-password";
                };

                passwordSender = mkOption {
                  type = types.str;
                  default = "root@localhost";
                  description = "Contact address for password reset.";
                };

                skins = mkOption {
                  default = { };
                  type = types.attrsOf types.path;
                  description = ''
                    Attribute set of paths whose content is copied to the {file}`skins`
                    subdirectory of the MediaWiki installation in addition to the default skins.
                  '';
                };

                extensions = mkOption {
                  default = { };
                  type = types.attrsOf (types.nullOr types.path);
                  description = ''
                    Attribute set of paths whose content is copied to the {file}`extensions`
                    subdirectory of the MediaWiki installation and enabled in configuration.

                    Use `null` instead of path to enable extensions that are part of MediaWiki.
                  '';
                  example = literalExpression ''
                    {
                      Matomo = pkgs.fetchzip {
                        url = "https://github.com/DaSchTour/matomo-mediawiki-extension/archive/v4.0.1.tar.gz";
                        sha256 = "0g5rd3zp0avwlmqagc59cg9bbkn3r7wx7p6yr80s644mj6dlvs1b";
                      };
                      ParserFunctions = null;
                    }
                  '';
                };

                database = {
                  type = mkOption {
                    type = types.enum [
                      "mysql"
                    ];
                    default = "mysql";
                    description = "Database engine to use. MySQL/MariaDB is the database of choice by MediaWiki developers.";
                  };

                  host = mkOption {
                    type = types.str;
                    default = "localhost";
                    description = "Database host address.";
                  };

                  port = mkOption {
                    type = types.port;
                    default = 3306;
                    defaultText = literalExpression "3306";
                    description = "Database host port.";
                  };

                  name = mkOption {
                    type = types.str;
                    default = "mediawiki" + lib.optionalString (name != "") ("-" + name);
                    defaultText = literalExpression ''
                      "mediawiki" + lib.optionalString (name != "") ("-" + name)
                    '';
                    description = "Database name.";
                  };

                  user = mkOption {
                    type = types.str;
                    default = "mediawiki" + lib.optionalString (name != "") ("-" + name);
                    defaultText = literalExpression ''
                      "mediawiki" + lib.optionalString (name != "") ("-" + name)
                    '';
                    description = "Database user.";
                  };

                  passwordFile = mkOption {
                    type = types.nullOr types.path;
                    default = null;
                    example = "/run/keys/mediawiki-dbpassword";
                    description = ''
                      A file containing the password corresponding to
                      {option}`database.user`.
                    '';
                  };

                  tablePrefix = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = ''
                      If you only have access to a single database and wish to install more than
                      one version of MediaWiki, or have other applications that also use the
                      database, you can give the table names a unique prefix to stop any naming
                      conflicts or confusion.
                      See <https://www.mediawiki.org/wiki/Manual:$wgDBprefix>.
                    '';
                  };

                  socket = mkOption {
                    type = types.nullOr types.path;
                    default = "/run/mysqld/mysqld.sock";
                    defaultText = literalExpression "/run/mysqld/mysqld.sock";
                    description = "Path to the unix socket file to use for authentication.";
                  };

                  createLocally = mkOption {
                    type = types.bool;
                    default = config.database.type == "mysql";
                    defaultText = literalExpression "true";
                    description = ''
                      Create the database and database user locally.
                      This currently only applies if database type "mysql" is selected.
                    '';
                  };
                };

                poolConfig = mkOption {
                  type =
                    with types;
                    attrsOf (oneOf [
                      str
                      int
                      bool
                    ]);
                  default = {
                    "pm" = "dynamic";
                    "pm.max_children" = 32;
                    "pm.start_servers" = 2;
                    "pm.min_spare_servers" = 2;
                    "pm.max_spare_servers" = 4;
                    "pm.max_requests" = 500;
                  };
                  description = ''
                    Options for the MediaWiki PHP pool. See the documentation on `php-fpm.conf`
                    for details on configuration directives.
                  '';
                };

                extraConfig = mkOption {
                  type = types.lines;
                  description = ''
                    Any additional text to be appended to MediaWiki's
                    LocalSettings.php configuration file. For configuration
                    settings, see <https://www.mediawiki.org/wiki/Manual:Configuration_settings>.
                  '';
                  default = "";
                  example = ''
                    $wgEnableEmail = false;
                  '';
                };
              };
            }
          )
        );
      };

    };
  };

  # implementation
  config = mkIf (enabledServers != { }) {

    assertions = lib.attrValues (
      lib.mapAttrs (name: conf: [
        {
          assertion =
            conf.database.createLocally -> (conf.database.type == "mysql");
          message = "services.mediawiki.${name}.createLocally is currently only supported for database type 'mysql'";
        }
        {
          assertion =
            conf.database.createLocally
            -> conf.database.user == (mediawikiName name) && conf.database.name == conf.database.user;
          message = "services.mediawiki.${name}.database.user must be set to ${mediawikiName name} if services.mediawiki.${mediawikiName name}.database.createLocally is set true";
        }
        {
          assertion = conf.database.createLocally -> conf.database.socket != null;
          message = "services.mediawiki.${name}.database.socket must be set if services.mediawiki.${name}.database.createLocally is set to true";
        }
        {
          assertion = conf.database.createLocally -> conf.database.passwordFile == null;
          message = "a password cannot be specified if services.mediawiki.${name}.database.createLocally is set to true";
        }
      ]) enabledServers
    );

    services.mysql = lib.concatMapAttrs (name: conf: {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ conf.database.name ];
      ensureUsers = [
        {
          name = conf.database.user;
          ensurePermissions = {
            "${conf.database.name}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    }) enabledServers;

    services.phpfpm.pools = lib.concatMapAttrs (name: conf: {
      "${mediawikiName name}" = {
      user = mediawikiName name;
      group = mediawikiName name;
      phpEnv.MEDIAWIKI_CONFIG = "${mediawikiConfig name conf}";
      phpPackage = php;
      settings =
        {
          "listen.owner" = mediawikiName name;
          "listen.group" = mediawikiName name;
        }
        // conf.poolConfig;
        };
    }) enabledServers;

    systemd.tmpfiles.rules = lib.mapAttrsToList (name: conf:
      [
        "d '${stateDir name}' 0750 ${mediawikiName name} ${mediawikiName name} - -"
        "d '${cacheDir name}' 0750 ${mediawikiName name} ${mediawikiName name} - -"
      ]
      ++ optionals (conf.uploadsDir != null) [
        "d '${conf.uploadsDir}' 0750 ${mediawikiName name} ${mediawikiName name} - -"
        "Z '${conf.uploadsDir}' 0750 ${mediawikiName name} ${mediawikiName name} - -"
      ]) enabledServers;

    systemd.services = lib.concatMapAttrs (name: conf: 
    {
    "${mediawikiName name}-init" = {
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-mediawiki.service" ];
      after = "mysql.service";
      script = ''
        if ! test -e "${stateDir name}/secret.key"; then
          tr -dc A-Za-z0-9 </dev/urandom 2>/dev/null | head -c 64 > ${stateDir name}/secret.key
        fi

        echo "exit( wfGetDB( DB_MASTER )->tableExists( 'user' ) ? 1 : 0 );" | \
        ${php}/bin/php ${pkg name conf}/share/mediawiki/maintenance/eval.php --conf ${mediawikiConfig name conf} && \
        ${php}/bin/php ${pkg name conf}/share/mediawiki/maintenance/install.php \
          --confpath /tmp \
          --scriptpath / \
          --dbserver ${lib.escapeShellArg "${conf.database.host}:${conf.database.socket}"} \
          --dbport ${toString conf.database.port} \
          --dbname ${lib.escapeShellArg conf.database.name} \
          ${
            optionalString (
              conf.database.tablePrefix != null
            ) "--dbprefix ${lib.escapeShellArg conf.database.tablePrefix}"
          } \
          --dbuser ${lib.escapeShellArg conf.database.user} \
          ${
            optionalString (
              conf.database.passwordFile != null
            ) "--dbpassfile ${lib.escapeShellArg conf.database.passwordFile}"
          } \
          --passfile ${lib.escapeShellArg conf.passwordFile} \
          --dbtype ${conf.database.type} \
          ${lib.escapeShellArg conf.name} \
          admin

        ${php}/bin/php ${pkg name conf}/share/mediawiki/maintenance/update.php --conf ${mediawikiConfig name conf} --quick
      '';

      serviceConfig = {
        Type = "oneshot";
        User = mediawikiName name;
        Group = mediawikiName name;
        PrivateTmp = true;
      };
      };
    }) enabledServers;

    users = lib.concatMapAttrs (name: conf: {
      users.${mediawikiName name} = {
        group = mediawikiName name;
        isSystemUser = true;
      };
      users.groups.${mediawikiName name} = { };
    }) enabledServers;

    environment.systemPackages = lib.mapAttrsToList mediawikiScripts enabledServers;
  };
}
