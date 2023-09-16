{ inputs, self, ... }:
{
  flake =
    let
      inherit (inputs.nixpkgs) lib;

      inherit (inputs.colmena.lib.makeHive self.outputs.colmena) nodes;

    in
    {
      colmena =
        let
          isDir = _name: type: type == "directory";

          hosts = builtins.attrNames
            (lib.filterAttrs isDir
              (builtins.readDir ./.)
            );

          buildHosts = hosts: lib.genAttrs hosts (name: {
            imports = [
              (./. + "/${name}")
            ];
          });

          buildMeta = map (host:
            let
              metaFile = ./. + "${host}/meta.nix";
              meta = import metaFile;
            in
            if lib.pathIsRegularFile metaFile then
              {
                meta = {
                  nodeNixpkgs."${host}" = import inputs.nixpkgs {
                    inherit (meta) system;
                  };
                };
              }
            else
              { }
          );
        in
        (lib.foldl (lib.recursiveUpdate) { } ([
          {
            meta = {
              nixpkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
              };

              specialArgs = inputs;
            };

            defaults.imports = [
              ../modules/base.nix
            ];
          }
          (buildHosts hosts)
        ] ++
        (buildMeta hosts))
        );

      nixosConfigurations = nodes;

      sdImages =
        let
          containsSdImage = lib.filterAttrs
            (_: node:
              lib.hasAttrByPath [ "config" "system" "build" "sdImage" ] node);
        in
        lib.mapAttrs
          (_: node:
            node.config.system.build.sdImage)
          (containsSdImage nodes);
    };
}
