{ pkgs, ... }:

{
  imports = [
    ../../config/core
    ../../config/core/environment/etc
    ../../config/core/fonts.nix
    ../../config/core/hardware/nvidia.nix
    ../../config/core/localization.nix
    ../../config/core/network/network-manager.nix
    ../../config/core/network/printing.nix
    ../../config/core/network/ssh.nix
    ../../config/core/network/tailscale
    ../../config/core/nix-config
    ../../config/core/packages/packages.nix
    ../../config/core/pam-limits
    ../../config/core/rtkit
    ../../config/core/sound/pipewire.nix
    ../../config/core/tty-config

    ../../config/desktop/foot
    ../../config/desktop/fuzzel
    ../../config/desktop/i3status-rust
    ../../config/desktop/jay
    ../../config/desktop/theming
    ../../config/desktop/swaync
    ../../config/desktop/xdg

    ../../config/gaming/gamemode
    ../../config/gaming/mangohud
    ../../config/gaming/minecraft/modcheck
    ../../config/gaming/minecraft/ninjabrain-bot
    ../../config/gaming/minecraft/prismlauncher
    ../../config/gaming/minecraft/tmpfs-symlink
    ../../config/gaming/minecraft/waywall

    ../../config/programs/bash
    ../../config/programs/btop
    ../../config/programs/discord
    ../../config/programs/fastfetch
    ../../config/programs/gh
    ../../config/programs/git
    ../../config/programs/imv
    ../../config/programs/mpv
    ../../config/programs/ncdu
    ../../config/programs/neovim
    ../../config/programs/nh
    ../../config/programs/ranger
    ../../config/programs/satty
    ../../config/programs/spotify
    ../../config/programs/tree
    ../../config/programs/vlc
    ../../config/programs/vscodium
    ../../config/programs/wev
    ../../config/programs/zen
    ../../config/programs/ydotool

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      # systemd-boot.enable = true;
      limine = {
        enable = true;
        secureBoot = {
          enable = true;
          autoEnrollKeys = {
            enable = true;
            extraArgs = [
              "--microsoft"
              "--firmware-builtin"
            ];
          };
          autoGenerateKeys = true;
        };
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  system.stateVersion = "26.05";
}
