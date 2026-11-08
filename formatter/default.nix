{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    programs.nixfmt.enable = true;
    programs.stylua.enable = true;

    # external submodule
    settings.global.excludes = [
      "configs/nixos/gaming/minecraft/waywall/waywall-config/ww_temporary_ninbot/**"
    ];
  };
}
