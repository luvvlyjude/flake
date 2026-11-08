{ lib, self, ... }:

let
  inherit (lib) getExe;
in
{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) runCommandLocal;
    in
    {
      checks = {
        statix = runCommandLocal "check-statix" { } ''
          ${getExe pkgs.statix} check ${self}
          touch $out
        '';

        deadnix = runCommandLocal "check-deadnix" { } ''
          ${getExe pkgs.deadnix} --fail ${self}
          touch $out
        '';
      };
    };
}
