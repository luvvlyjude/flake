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
}
