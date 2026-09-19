{
  inputs,
  lib,
  luvvlyLib,
  ...
}:

let
  mkHost =
    name: path:
    let
      host = import path;
    in
    lib.nixosSystem {
      specialArgs = {
        inherit inputs luvvlyLib;
        user = host.user or "jude";
      };

      modules = [
        ./core
        { networking.hostName = name; }
      ]
      ++ host.modules;
    };
in
lib.mapAttrs mkHost (luvvlyLib.collectNixFiles { directory = ./systems; })
