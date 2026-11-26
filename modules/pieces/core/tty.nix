{
  flake.nixosModules.tty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      console = {
        earlySetup = true;
        font = "ter-132b";
        keyMap = "us";
        packages = [
          pkgs.terminus_font
        ];
      };

      services.getty = {
        # clean up the getty tty login
        greetingLine = "[ Welcome to ${config.system.nixos.distroName} ${config.system.nixos.release} \\r (\\l) ]";
        helpLine = lib.mkForce "";
      };

      environment.etc = {
        issue = {
          # change the tty nixos greeting to pink from green
          # invisible esc byte characters inserted before each '['
          # ctrl+v esc to insert an esc byte
          text = ''

            [1;38;5;53m${config.services.getty.greetingLine}[0m
            ${config.services.getty.helpLine}

          '';
        };
      };
    };
}
