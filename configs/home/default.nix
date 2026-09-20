{ inputs, ... }:

{
  imports = [
    # all consumed homeModules should go here
    inputs.jay.homeManagerModules.default
  ];
}
