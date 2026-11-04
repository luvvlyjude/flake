{
  inputs,
  ...
}:

{
  imports = [
    # all consumed nixosModules should go here
    inputs.bcachefs-tools.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.jay.nixosModules.default
    inputs.mcsr-nixos.nixosModules.tmpfs-symlink

    ./users.nix
  ];

  boot.tmp.cleanOnBoot = true;

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };
}
