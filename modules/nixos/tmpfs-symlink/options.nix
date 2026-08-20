{ lib }:

{
  enable = lib.mkEnableOption "symlink-worlds";

  users = lib.mkOption {
    type = lib.types.attrsWith {
      placeholder = "user";
      elemType = (
        lib.types.submodule ({
          options.common-worlds = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "mcsr/worlds/Portal Practice v2" ];
            description = ''
              World folders linked into all declared instances for `<user>`.

              List should be paths relative to `<user>`'s $HOME.
            '';
          };

          options.instances = lib.mkOption {
            type = lib.types.attrsWith {
              placeholder = "instance-name";
              elemType = (
                lib.types.submodule (
                  { name, ... }:
                  {
                    options.saves = lib.mkOption {
                      type = lib.types.str;
                      default = ".local/share/PrismLauncher/instances/${name}/minecraft/saves";
                      defaultText = ".local/share/PrismLauncher/instances/<instance-name>/minecraft/saves";
                      example = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
                      description = ''
                        Path to the instance's saves normal folder.

                        Path should be relative to `<user>`'s $HOME.
                      '';
                    };

                    options.tmpfs = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      example = true;
                      description = ''
                        Whether or not to link this instance's saves folder to `tmpfs-mount`.

                        This option can clobber your existing saves folder by replacing them
                        with a symlink, so make sure you backup worlds from there that you want.
                      '';
                    };

                    options.worlds = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      example = [ "mcsr/worlds/Instance Exclusive World" ];
                      description = ''
                        World folders linked only into this instance.

                        List should be paths relative to `<user>`'s $HOME.
                      '';
                    };
                  }
                )
              );
            };
            default = { };
            example = {
              seedqueue = {
                tmpfs = true;
                saves = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
                worlds = [
                  "mcsr/worlds/SeedQueue Exclusive World"
                ];
              };
            };
            description = ''
              Declare instances to link worlds into.

              Instances default to looking for a Prism Launcher instance folder
              relative to `<user>`'s $HOME with the name of `<instance-name>`.

              All instances declared will receive links to
              `services.symlink-worlds.<user>.common-worlds` for the same `<user>`.
              Instances' saves folders may be declared to a different path using `saves`.
              Instances' saves folders may be linked to a folder at `tmpfs-mount` using `tmpfs`.
              Instances may have exclusive worlds linked using the `worlds` list.
            '';
          };

          options.tmpfs = lib.mkOption {
            type = lib.types.submodule ({
              options.enable = lib.mkEnableOption "tmpfs";

              options.extra-options = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [ "noatime" ];
                description = ''
                  Extra options to mount the tmpfs with.
                '';
              };

              options.mount = lib.mkOption {
                type = lib.types.str;
                default = "mcsr/tmpfs";
                example = ".local/share/mcsr-tmpfs";
                description = ''
                  Path for where to mount the tmpfs for tmpfs linked saves instances.

                  Path should be relative to `<user>`'s $HOME.

                  For enabled instances, their saves folder will be symlinked
                  to a folder created here named after the instance.
                '';
              };

              options.size = lib.mkOption {
                type = lib.types.str;
                default = "4g";
                example = "15%";
                description = ''
                  Max usage of system memory in this tmpfs.
                '';
              };
            });
            default = { };
            example = {
              enable = true;
              extra-options = [ "noatime" ];
              mount = ".local/share/mcsr-tmpfs";
              size = "15%";
            };
            description = ''
              Declare a basic tmpfs for enabled instances' tmpfs saves.

              The mount automatically receives options for
              `mode=0755`, `uid=<user>`, and `gid=config.users.users.<user>.group`.

              Tmpfs linked saves are helpful for improving world folder write performance
              and can improve things like the length of "end lag".

              For enabled instances, their saves folder will be symlinked
              to a folder created here named after the instance.

              Enable this option per instance with `instances.<instance-name>.tmpfs`.
            '';
          };
        })
      );
    };
    default = { };
    example = {
      "alice" = {
        tmpfs = {
          enable = true;
          mount = ".local/share/mcsr-tmpfs";
          size = "15%";
        };
        instances = {
          seedqueue = {
            tmpfs = true;
            saves = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
            worlds = [
              "mcsr/worlds/SeedQueue Exclusive World"
            ];
          };
        };
        common-worlds = [
          "mcsr/worlds/Portal Practice v2"
        ];
      };
    };
    description = ''
      Declare users to declare their tmpfs, instances, and common-worlds.

      All path options within a user declaration are relative to their $HOME.

      All mounts, directories, and links created for options declared for a user
      will be owned by that user.
    '';
  };
}
