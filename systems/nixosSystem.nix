# this file is the default shared/required shape of a nixosSystem
# one of these is built for each folder in this directory
# created based on the contents of that folder's default.nix

{
  inputs,
  host,
  lib,
  luvvlyLib,
  hostName,
  systemsPkgsMap,
  ...
}:

let
  inherit (lib) mkAliasOptionModule;

  # create "aliased" lists of modules which resolve from ../configs/{nixos|home}
  # attr names r nixosModules and homeModules respectively
  prefixPathWith = prefix: path: ./. + ("/" + prefix + path);

  username = host.username or "jude";

  # stateVersion is shared between system and home
  stateVersion = host.stateVersion or (throw "mkNixosSystem: systems must define a state version!");

  # home-manager inherits the same args
  specialArgs = { inherit inputs luvvlyLib username; };
in
{
  inherit specialArgs;

  modules = [
    {
      # more shared core nixos system config
      imports = [
        inputs.self.nixosModules.default

        ../configs/nixos

        (mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])
      ]
      # modules relative to <system>/default.nix, usually hardware-configuration.nix, etc...
      ++ host.modules
      # modules in ../configs/nixos for configuring the system
      ++ map (prefixPathWith "../configs/nixos/") host.nixosModules;

      # pkgs built in flake.nix with all overlays and custom packages, keyed by host.system
      nixpkgs.pkgs = systemsPkgsMap.${host.system};

      hardware.enableAllFirmware = true;

      networking = { inherit hostName; };
      system = { inherit stateVersion; };

      # --- HOME-MANAGER RELATED CORE CONFIG ---
      home-manager = {
        extraSpecialArgs = specialArgs;

        useGlobalPkgs = true;
        useUserPackages = true;

        users.${username} = { osConfig, ... }: {
          imports = [
            inputs.self.homeModules.default

            # required core home-manager setup module
            ../configs/home
          ]
          # modules in ../configs/home for configuring the user's home
          ++ map (prefixPathWith "../configs/home/") host.homeModules;

          programs.home-manager.enable = true;

          home = {
            inherit stateVersion username;
            homeDirectory = osConfig.users.users.${username}.home;
          };
        };
      };
    }
  ];
}
