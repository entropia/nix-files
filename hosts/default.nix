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
          inventory = builtins.fromJSON
            (builtins.readFile ./inventory.json)
          ;


          hosts = lib.listToAttrs (map
            (host: {
              name = host.hostName;
              value = {
                imports = [ (./. + "/gulaschdisplay") ];
                networking.hostName = host.hostName;
                deployment.targetHost = host.targetHost;
              };
            }
            )
            inventory);

        in
        (lib.foldl (lib.recursiveUpdate) { } [
          {
            meta = {
              nixpkgs = import inputs.nixpkgs {
                system = "aarch64-linux";
              };

              specialArgs = {
                inherit inputs;
              };
            };

            defaults.imports = [
              ../profiles/base
              inputs.sops-nix.nixosModules.sops
              { nixpkgs.overlays = [ self.overlays.default ]; }
            ];
          }
          hosts
        ]
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
