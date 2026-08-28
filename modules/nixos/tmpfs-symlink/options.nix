{ lib }:

let
  relativePath = lib.types.strMatching "^[^/].*" // {
    description = "path relative to $HOME (not starting with '/')";
  };

  mountSizeStr = lib.types.strMatching "^[0-9]+([kKmMgG]|%)?$" // {
    description = "tmpfs max usage size option string (eg. 4G, 15%, ...)";
  };
in
{
  enable = lib.mkEnableOption "Declarative Minecraft world symlinking with optional tmpfs saves";

  instances = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule ({
        options.saves = lib.mkOption {
          type = relativePath;
          default = "";
          example = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
          description = ''
            Path to the instance's normal saves folder.

            Path should be relative to `user`'s $HOME.
          '';
        };

        options.size = lib.mkOption {
          type = mountSizeStr;
          default = "4G";
          example = "4G";
          description = ''
            Max usage of system memory for this instance's tmpfs.
              
            noop unless this instance's `tmpfs` option set to `true`.
          '';
        };

        options.tmpfs = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = ''
            Whether to mount tmpfs of `size` to this instance's saves folder.

            Because this option mounts tmpfs over the existing saves folder it
            can end up hiding persistent existing saves. They do not get deleted.
            All worlds in the instance's tmpfs saves folder will be deleted apon
            reboot and must be explicitly copied or moved to save them.
          '';
        };

        options.user = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "alice";
          description = ''
            The user whose $HOME to use for other path options and who will own the tmpfs mount.
          '';
        };

        options.worlds = lib.mkOption {
          type = lib.types.listOf relativePath;
          default = [ ];
          example = [ "mcsr/worlds/Instance Exclusive World" ];
          description = ''
            World folders linked into this instance.

            List should be paths relative to `user`'s $HOME.
          '';
        };
      })
    );
  };
}
