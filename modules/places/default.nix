{
  config,
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.luvvly.places = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          username = mkOption { type = types.str; };
          stateVersion = mkOption { type = types.str; };
          system = mkOption { type = types.str; };
          nixosModules = mkOption { type = types.listOf types.deferredModule; };
          homeModules = mkOption { type = types.listOf types.deferredModule; };
        };
      }
    );
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      hostName: host:
      withSystem host.system (
        { pkgs, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.pkgs = pkgs;
              luvvly.username = host.username;
              networking.hostName = hostName;
              system.stateVersion = host.stateVersion;
            }

            # import nixosModules list
            { imports = host.nixosModules; }
            # import homeModules list
            { home-manager.users.${host.username}.imports = host.homeModules; }
          ];
        }
      )
    ) config.luvvly.places;
  };
}
