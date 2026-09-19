{
  inputs,
  pkgs,
  ...
}:

let
  treefmt = inputs.treefmt-nix.lib.evalModule pkgs {
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
    programs.stylua.enable = true;

    # external submodule
    settings.global.excludes = [
      "configs/nixos/gaming/minecraft/waywall/waywall-config/ww_temporary_ninbot/**"
    ];
  };

  inherit (treefmt.config.build) wrapper check;
in
wrapper.overrideAttrs (old: {
  passthru = old.passthru or { } // {
    inherit check;
  };
})
