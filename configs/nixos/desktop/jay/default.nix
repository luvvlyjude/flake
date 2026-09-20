{
  lib,
  luvvlyLib,
  pkgs,
  ...
}:

{
  programs.jay = {
    enable = true;

    # jay bin gets CAP_SYS_NICE
    # elevated scheduler and high-priority vulkan queues
    # better performance under load
    # default is true but here for clarity
    realtime-scheduling = true;

    xwayland.enable = true;

    extraPackages = [
    ];
  };

  hm =
    hm:
    let
      partArgs = {
        inherit
          hm
          luvvlyLib
          lib
          pkgs
          ;
      };

      settings = map (luvvlyLib.importWith partArgs) [
        ./actions.nix
        ./bar.nix
        ./behavior.nix
        ./clients.nix
        ./env.nix
        ./inputs.nix
        ./outputs.nix
        ./shortcuts.nix
        ./theme.nix
        ./windows.nix
      ];

    in
    {
      wayland.windowManager.jay = {
        enable = true;

        settings = luvvlyLib.mergeDisjoint "jay config" settings;
      };
    };
}
