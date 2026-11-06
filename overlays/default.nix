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
    inputs.jay-tray-item.overlays.default
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
  external = final: _prev: {
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

    # version bumps and upstream-fix pins go through luvvlyLib.overrideAttrsUntil,
    # so eval warns once nixpkgs catches up and the override can go

    # spotify with autoscrolling and wayland forced
    spotify = prev.spotify.overrideAttrs (oldAttrs: {
      preFixup = (oldAttrs.preFixup or "") + ''
        gappsWrapperArgs+=(
          --add-flags "--ozone-platform=wayland"
          --add-flags "--enable-blink-features=MiddleClickAutoscroll"
        )
      '';
    });

    # my nvidia_gpu fixes from luvvlyjude/i3status-rust: VRAM read as MiB, vram_* placeholders
    i3status-rust = luvvlyLib.overrideAttrsUntil "0.36.3" prev.i3status-rust (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        (final.fetchpatch {
          url = "https://github.com/luvvlyjude/i3status-rust/commit/e3814f336180a4ea132e8cf96ce7fc24aee11c05.patch";
          hash = "sha256-g4UuAR22tjfL3/aeksH25ii4vvWS3hd9cukXcKY1ODY=";
        })
        (final.fetchpatch {
          url = "https://github.com/luvvlyjude/i3status-rust/commit/1177c071149b32fb7d9706b3b1bb967e63419c68.patch";
          hash = "sha256-TUvwQJC3uoPUAvu6UGWTL19GSUUiFnBtVo0CAfM5ZNU=";
        })
      ];
    });

    # UI tests need AWT; not a version bump, so overrideAttrsUntil can't tell when nixpkgs#581568 lands
    ninjabrain-bot =
      prev.lib.warnIfNot (prev.lib.hasInfix "headless" prev.ninjabrain-bot.env.JAVA_HOME.name)
        "ninjabrain-bot: nixpkgs#581568 landed, drop the JAVA_HOME override"
        (
          prev.ninjabrain-bot.overrideAttrs (old: {
            env = old.env // {
              JAVA_HOME = final.jdk;
            };
          })
        );
  };
}
