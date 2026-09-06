{ config, user, ... }:

{
  programs.nh = {
    enable = true;

    flake = "${config.users.users.${user}.home}/projects/flake";
  };
}
