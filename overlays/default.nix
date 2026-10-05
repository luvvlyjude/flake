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

    # version bumps and upstream-fix pins go through luvvlyLib.overrideAttrsUntil,
    # so eval warns once nixpkgs catches up and the override can go

    # without it the nvenc probe can't find the driver and obs hides nvenc;
    # overlaid so the plugins link against this obs instead of a second one
    obs-studio = prev.obs-studio.override { cudaSupport = true; };

    # 2.6.0 fails against obs 32.2, fixed upstream but unreleased
    # https://github.com/NixOS/nixpkgs/issues/556310
    obs-studio-plugins = prev.obs-studio-plugins // {
      obs-shaderfilter = luvvlyLib.overrideAttrsUntil "2.6.1" prev.obs-studio-plugins.obs-shaderfilter {
        version = "2.6.0-unstable-2026-09-22";
        src = final.fetchFromGitHub {
          owner = "exeldro";
          repo = "obs-shaderfilter";
          rev = "af9ae58f2aba19653e3635de129e7a62e466459d";
          hash = "sha256-03j+g98krr1uTrhXzD96CuvNBvHd/cg/CdpioS3MygE=";
        };
        # C23 strrchr returns const for a const arg, master still assigns it to char *
        env.NIX_CFLAGS_COMPILE = "-Wno-error=discarded-qualifiers";
        # master already installs to share/obs, the leftovers are duplicates
        postInstall = ''
          rm -rf $out/obs-plugins $out/data
        '';
      };
    };

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
