{
  pkgs,
  lib,
  self,
  system,
  ...
}:

let
  inherit (lib) getExe;
  inherit (pkgs) runCommandLocal;
in
{
  formatting = self.formatter.${system}.check self;

  statix = runCommandLocal "check-statix" { } ''
    ${getExe pkgs.statix} check ${self}
    touch $out
  '';

  deadnix = runCommandLocal "check-deadnix" { } ''
    ${getExe pkgs.deadnix} --fail ${self}
    touch $out
  '';
}
