{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    curl
    jq
    lshw
    nixfmt
    sbctl
    wget
    unzip
    zip
  ];
}
