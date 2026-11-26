{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  systems = import inputs.systems;

  perSystem =
    { pkgs, system, ... }:
    {
      # used to set nixpkgs.pkgs in hosts using withSystem
      # this is the flake-wide declaration of what pkgs is
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
        # every overlay this flake has applied globally
        overlays = lib.attrValues config.flake.overlays;
      };

      checks = {
        statix = pkgs.runCommandLocal "check-statix" { } ''
          ${lib.getExe pkgs.statix} check ${self}
          touch $out
        '';

        deadnix = pkgs.runCommandLocal "check-deadnix" { } ''
          ${lib.getExe pkgs.deadnix} --fail ${self}
          touch $out
        '';
      };

      treefmt = {
        projectRootFile = "flake.nix";

        programs.nixfmt.enable = true;
        programs.stylua.enable = true;

        # external submodule
        settings.global.excludes = [
          "modules/pieces/gaming/minecraft/waywall-config/ww_temporary_ninbot/**"
        ];
      };
    };
}
