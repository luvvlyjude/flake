{ luvvlyLib, ... }:

{
  # custom modules
  # auto discovered from this directory
  # '.default' combines all modules, all exposed separately as well
  flake.nixosModules = luvvlyLib.collectModules ./.;
}
