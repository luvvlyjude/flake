{
  username = "jude";
  system = "x86_64-linux";
  stateVersion = "26.05";

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # resolved from ../../configs/nixos/
  nixosModules = [
    "core/environment/etc"
    "core/fonts.nix"
    "core/hardware/nvidia.nix"
    "core/localization.nix"
    "core/network/network-manager.nix"
    "core/network/printing.nix"
    "core/network/ssh.nix"
    "core/network/tailscale"
    "core/nix-config"
    "core/packages/packages.nix"
    "core/pam-limits"
    "core/rtkit"
    "core/sound/pipewire.nix"
    "core/tty-config"

    "desktop/foot"
    "desktop/fuzzel"
    "desktop/i3status-rust"
    "desktop/jay"
    "desktop/theming"
    "desktop/swaync"
    "desktop/xdg"

    "gaming/gamemode"
    "gaming/mangohud"
    "gaming/minecraft/modcheck"
    "gaming/minecraft/ninjabrain-bot"
    "gaming/minecraft/prismlauncher"
    "gaming/minecraft/tmpfs-symlink"
    "gaming/minecraft/waywall"

    "programs/bash"
    "programs/btop"
    "programs/claude"
    "programs/discord"
    "programs/fastfetch"
    "programs/gh"
    "programs/git"
    "programs/imv"
    "programs/mcp"
    "programs/mpv"
    "programs/ncdu"
    "programs/neovim"
    "programs/nh"
    "programs/ranger"
    "programs/satty"
    "programs/spotify"
    "programs/tree"
    "programs/vlc"
    "programs/vscodium"
    "programs/wev"
    "programs/zen"
    "programs/ydotool"
    "programs/zed"
  ];

  # resolved from ../../configs/home/
  homeModules = [ ];
}
