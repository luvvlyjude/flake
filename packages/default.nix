{ lib, luvvlyLib, ... }:

let
  inherit (lib) attrNames getAttrs;
  inherit (luvvlyLib) collectNixFiles;
in
{
  perSystem =
    { pkgs, ... }:
    {
      # custom packages
      # auto discovered from this directory
      # accessible through 'nix build', 'nix shell', etc
      # packages r sourced from this flake's overlays output so all overlays apply
      # collect all packages the exact same way as they r created in ../overlays
      packages = getAttrs (attrNames (collectNixFiles {
        directory = ./.;
        marker = "package.nix";
      })) pkgs;
    };
}
