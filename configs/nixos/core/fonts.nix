{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      font-awesome
    ];
  };
}
