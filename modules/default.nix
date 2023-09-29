{ inputs, ... }: {
  # Create a nixosModules attribute for every directory in this folder.
  # Modules are named after the folder name.
  flake.nixosModules =
    let
      inherit (inputs.nixpkgs.lib)
        genAttrs
        filterAttrs
        attrNames
        attrValues;

      isDir = _name: type: type == "directory";

      moduleFolders = attrNames
        (filterAttrs isDir
          (builtins.readDir ./.)
        );

      buildModule = name: {
        imports = [
          (./. + "/${name}")
        ];
      };

      modules = genAttrs moduleFolders buildModule;
    in
    {
      default.imports = attrValues modules;
    } // modules;
}

