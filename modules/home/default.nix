{ luvvlyLib, ... }:

{
  # custom modules
  # auto discovered from this directory
  # '.default' combines all modules, all exposed separately as well
  flake.homeModules = luvvlyLib.collectModules ./.;
}
