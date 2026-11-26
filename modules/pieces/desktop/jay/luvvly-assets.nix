{
  flake.overlays.luvvly-assets = final: _prev: {
    luvvly-assets = final.runCommand "luvvly-assets" { } ''
      mkdir -p $out/icons
      cp ${./icons}/*.png $out/icons/
    '';
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.luvvly-assets = pkgs.luvvly-assets;
    };
}
