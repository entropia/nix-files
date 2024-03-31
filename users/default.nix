{ lib, config, ... }:
let
  cfg = config.entropia;
in
{
  options.entropia = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        list of users that get added to a host, in addition to the global admins
      '';
    };
  };

  config = {
    # Add our global admins
    entropia.users = [ 
      "herrbett" 
      "jcgruenhage"  
      "promasu"
      "stored"
      "transcaffeine"
      "twi"
      "xanderio"
    ];

    users.users = (lib.genAttrs (lib.unique cfg.users) (name: import ./${name}));
  };
}
