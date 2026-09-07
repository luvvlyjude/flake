{
  lib,
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

    extraPackages = with pkgs; [
    ];
  };

  hm =
    hm:
    let
      inherit (lib) getExe;

      jayLib = import ./jayLib.nix { };

      # Each part is a plain expression that returns its piece of `settings`, not
      # a module, so nothing merges them for us: `mergeDisjoint` below is what
      # keeps two parts from quietly claiming the same key.
      settings = map importPart [
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

      importPart =
        part:
        import part {
          inherit
            hm
            jayLib
            lib
            pkgs
            ;
        };

      mergeDisjoint =
        parts:
        let
          shared = lib.filter (name: lib.count (part: part ? ${name}) parts > 1) (
            lib.unique (lib.concatMap lib.attrNames parts)
          );
        in
        if shared == [ ] then
          lib.mergeAttrsList parts
        else
          throw "jay config: ${lib.concatStringsSep ", " shared} defined by more than one part";
    in
    {
      wayland.windowManager.jay = {
        enable = true;

        settings = mergeDisjoint settings;
      };
    };
}
