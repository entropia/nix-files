{ lib, ... }:
let
  inherit (lib)
    filterAttrs
    attrNames
    ;

  isDir = _name: type: type == "directory";

  userFolders = attrNames
    (filterAttrs isDir
      (builtins.readDir ./.)
    );

  buildUser = name: (./. + "/${name}");
in
{
  imports = map buildUser userFolders;
}
