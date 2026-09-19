{
  inputs,
  lib,
  luvvlyLib,
  ...
}:

let
  inherit (lib) composeManyExtensions mapAttrs;
in
rec {
  # all overlays combined
  default = composeManyExtensions [
    additions
    external
    modifications

    inputs.bcachefs-tools.overlays.default
    inputs.jay.overlays.default
    inputs.jay-screenshot.overlays.default
  ];

  # collect all custom packages from '../packages' directory, flat at any depth
  additions =
    final: _prev:
    let
      # let custom packages access inputs or luvvlyLib if they need
      callPackage = final.newScope { inherit inputs luvvlyLib; };
    in
    mapAttrs (_name: path: callPackage path { }) (
      luvvlyLib.collectNixFiles {
        directory = ../packages;
        marker = "package.nix";
      }
    );

  # packages to overlay from external sources
  external = final: prev: {
    # does not expose its own overlay
    jay-tray-item = inputs.jay-tray-item.packages.${prev.stdenv.hostPlatform.system}.default;

    # while ktrompfl's flake has outputs, including it as an input brings in many other inputs
    ninjabrain-box = final.callPackage "${inputs.ktrompfl}/pkgs/ninjabrain-box" {
      inherit inputs;
      pkgs = final;
    };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # deadnix: skip
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # spotify with autoscrolling and wayland forced
    spotify = prev.spotify.overrideAttrs (oldAttrs: {
      preFixup = (oldAttrs.preFixup or "") + ''
        gappsWrapperArgs+=(
          --add-flags "--ozone-platform=wayland"
          --add-flags "--enable-blink-features=MiddleClickAutoscroll"
        )
      '';
    });
  };
}
