{
  inputs,
  lib,
  luvvlyLib,
  withSystem,
  ...
}:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (lib) mapAttrs;
  inherit (luvvlyLib) collectNixFiles;
in
{
  # all nixos configurations
  # auto discovered from this directory
  flake.nixosConfigurations =
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
              withSystem
              ;
            host = import path;
          }
        )
      )
      # collect all files or folders with default.nix to use as systems
      # remove the default nixosSystem "shape" file ./system.nix from collected files
      (removeAttrs (collectNixFiles { directory = ./.; }) [ "nixosSystem" ]);
}
