{ config, pkgs, ... }:

{
  environment.etc = {
    issue = {
      # change the tty nixos greeting to pink from green
      # invisible esc byte characters inserted before each '['
      # ctrl+v esc to insert an esc byte
      source = pkgs.writeText "issue" ''

        [1;38;5;53m${config.services.getty.greetingLine}[0m
        ${config.services.getty.helpLine}

      '';
    };
  };
}
