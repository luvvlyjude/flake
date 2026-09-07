{ inputs, ... }:

let
  inherit (inputs.nixpkgs-unstable.lib) composeManyExtensions;

  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    }
    // {
      jay-tray-item = inputs.jay-tray-item.packages.${prev.stdenv.hostPlatform.system}.default;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # fuzzel mouse index fix not out yet
    fuzzel = prev.fuzzel.overrideAttrs (oldAttrs: rec {
      version = "unstable-302f228b";
      src = prev.fetchFromCodeberg {
        owner = "dnkl";
        repo = "fuzzel";
        rev = "302f228bb87d3c861a8debd39b9d8e4a0ea81037";
        hash = "sha256-gdBciE62m2M+b9TZ+PvipARYELe1d5vkSIM543uaqB0=";
      };
    });

    # spotify with autoscrolling and wayland forced
    spotify = prev.spotify.overrideAttrs (oldAttrs: rec {
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

  inputs.ktrompfl.overlays.default
]
