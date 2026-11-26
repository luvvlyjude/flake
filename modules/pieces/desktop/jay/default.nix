{ inputs, ... }:
{
  flake.nixosModules.jay = {
    imports = [ inputs.jay.nixosModules.default ];

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
  };

  # settings are added to this module from the files next to this one
  flake.homeModules.jay = {
    imports = [ inputs.jay.homeManagerModules.default ];

    wayland.windowManager.jay.enable = true;
  };
}
