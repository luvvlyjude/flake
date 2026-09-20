{
  inputs,
  lib,
  luvvlyLib,
  systemsPkgsMap,
  ...
}:

let
  inherit (lib) mapAttrs nixosSystem;
  inherit (luvvlyLib) collectNixFiles importWith;
in
mapAttrs
  (
    hostName: path:
    nixosSystem (
      importWith {
        inherit
          inputs
          lib
          luvvlyLib
          hostName
          systemsPkgsMap
          ;
        host = import path;
      } ./nixosSystem.nix
    )
  )
  # collect all files or folders with default.nix to use as systems
  # remove the default nixosSystem "shape" file ./system.nix from collected files
  (removeAttrs (collectNixFiles { directory = ./.; }) [ "nixosSystem" ])
