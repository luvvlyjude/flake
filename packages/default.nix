{
  pkgs,
  lib,
  luvvlyLib,
  ...
}:

let
  inherit (lib) attrNames getAttrs;
  inherit (luvvlyLib) collectNixFiles;
in

# collect all packages the exact same way as they r created in ../overlays
getAttrs (attrNames (collectNixFiles {
  directory = ./.;
  marker = "package.nix";
})) pkgs
