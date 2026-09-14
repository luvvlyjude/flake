{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) composeManyExtensions;

  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    }
    // {
      jay-tray-item = inputs.jay-tray-item.packages.${prev.stdenv.hostPlatform.system}.default;

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
in
composeManyExtensions [
  additions
  modifications

  inputs.bcachefs-tools.overlays.default
  inputs.jay.overlays.default
  inputs.jay-screenshot.overlays.default
]
