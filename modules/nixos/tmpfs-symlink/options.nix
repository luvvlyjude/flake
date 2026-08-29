{ lib }:

let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types)
    bool
    listOf
    str
    strMatching
    submodule
    ;

  relativePath = strMatching "[^/].*" // {
    description = "path relative to $HOME (not starting with '/')";
  };

  mountSizeStr = strMatching "[0-9]+([kKmMgG]|%)?" // {
    description = "tmpfs max usage size option string (eg. 4G, 15%, ...)";
  };
in
{
  enable = mkEnableOption "Declarative Minecraft world symlinking with optional tmpfs saves";

  instances = mkOption {
    type = listOf (submodule ({
      options.saves = mkOption {
        type = relativePath;
        example = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
        description = ''
          Path to the instance's normal saves folder.

          Path should be relative to `user`'s $HOME.
        '';
      };

      options.size = mkOption {
        type = mountSizeStr;
        default = "4G";
        example = "15%";
        description = ''
          Max usage of system memory for this instance's tmpfs.

          No effect unless this instance's `tmpfs` option set to `true`.
        '';
      };

      options.tmpfs = mkOption {
        type = bool;
        default = false;
        example = true;
        description = ''
          Whether to mount tmpfs of `size` to this instance's saves folder.

          Because this option mounts tmpfs over the existing saves folder it
          can end up hiding persistent existing saves. They do not get deleted.
          All worlds in the instance's tmpfs saves folder will be deleted upon
          reboot and must be explicitly copied or moved to save them. Hidden
          on-disk worlds can be recovered by unmounting the tmpfs.
        '';
      };

      options.user = mkOption {
        type = str;
        example = "alice";
        description = ''
          The user whose $HOME to use for other path options and who will own the tmpfs mount.
        '';
      };

      options.worlds = mkOption {
        type = listOf relativePath;
        default = [ ];
        example = [ "mcsr/worlds/Portal Practice v2" ];
        description = ''
          World folders linked into this instance.

          List should be paths relative to `user`'s $HOME.
        '';
      };
    }));
    default = [ ];
    example = [
      {
        saves = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
        size = "15%";
        tmpfs = true;
        user = "alice";
        worlds = [
          "mcsr/worlds/Portal Practice v2"
        ];
      }
    ];
    description = ''
      List of instance submodules defining each instance's options

      Each instance requires specifying `user` and `saves`.
    '';
  };
}
