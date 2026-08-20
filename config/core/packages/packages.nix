{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    curl
    jq
    lshw
    wget
    unzip
    zip
  ];
}
