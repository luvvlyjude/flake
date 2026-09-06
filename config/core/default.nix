{
  inputs,
  lib,
  user,
  ...
}:

let
  inherit (lib) mkAliasOptionModule;
in
{
  imports = [
    inputs.self.nixosModules.default
    inputs.bcachefs-tools.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.jay.nixosModules.default
    inputs.mcsr-nixos.nixosModules.tmpfs-symlink

    (mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])

    ./users.nix
  ];

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.self.overlays.default ];
  };

  home-manager = {
    # leaving out for now so that i'm warned on collisions
    # backupFileExtension = "hm-bak";
    extraSpecialArgs = { inherit inputs user; };
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      inputs.self.homeManagerModules.default
      inputs.jay.homeManagerModules.default
    ];
  };
}
