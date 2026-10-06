{
  inputs,
  lib,
  luvvlyLib,
  systemsPkgsMap,
  ...
}:

let
  inherit (lib) mapAttrs nixosSystem;
  inherit (luvvlyLib) collectNixFiles;
in
mapAttrs
  (
    hostName: path:
    nixosSystem (
      import ./nixosSystem.nix {
        inherit
          inputs
          lib
          luvvlyLib
          hostName
          systemsPkgsMap
          ;
        host = import path;
      }
    )
  )
  # collect all files or folders with default.nix to use as systems
  # remove the default nixosSystem "shape" file ./system.nix from collected files
  (removeAttrs (collectNixFiles { directory = ./.; }) [ "nixosSystem" ])
