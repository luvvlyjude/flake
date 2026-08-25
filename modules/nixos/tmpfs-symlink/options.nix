{ lib }:

let
  relativePath = lib.types.strMatching "[^/].*" // {
    description = "path relative to $HOME (not starting with  '/')";
  };
in
{
  enable = lib.mkEnableOption "Declarative Minecraft world symlinking with optional tmpfs saves";

  users = lib.mkOption {
    type = lib.types.attrsWith {
      placeholder = "user";
      elemType = (
        lib.types.submodule ({
          options.worlds = lib.mkOption {
            type = lib.types.listOf relativePath;
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
                      type = relativePath;
                      default = ".local/share/PrismLauncher/instances/${name}/minecraft/saves";
                      defaultText = ".local/share/PrismLauncher/instances/<instance-name>/minecraft/saves";
                      example = ".local/share/PrismLauncher/instances/RSG Instance/minecraft/saves";
                      description = ''
                        Path to the instance's normal saves folder.

                        Path should be relative to `<user>`'s $HOME.
                      '';
                    };

                    options.tmpfs = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      example = true;
                      description = ''
                        Whether or not to link this instance's saves folder into `<user>.tmpfs`.

                        In order to avoid clobbering existing saves, this instance's saves folder
                        must be empty in order to replace with a link and the service will fail if not.
                      '';
                    };

                    options.worlds = lib.mkOption {
                      type = lib.types.listOf relativePath;
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
              `services.tmpfs-symlink.users.<user>.worlds` for the same `<user>`.
              Instances' saves folders may be declared to a different path using `saves`.
              Instances' saves folders may be linked to a folder at `<user>.tmpfs.mount` using `tmpfs`.
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
                type = relativePath;
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
                type = lib.types.strMatching "[0-9]+([kKmMgG]|%)?";
                default = "4g";
                example = "15%";
                description = ''
                  Max usage of system memory for this tmpfs.
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

              Changing these settings often requires manually unmounting and remounting
              or a reboot as `nixos-rebuild switch` does not handle most changes.
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
        worlds = [
          "mcsr/worlds/Portal Practice v2"
        ];
      };
    };
    description = ''
      Per-user declarations of instances, shared worlds, and an optional tmpfs.

      All path options within a user declaration are relative to their $HOME.

      `<user>.worlds` list link worlds into every instance declared for a user.

      All mounts, directories, and links created for options declared for a user
      will be owned by that user.
    '';
  };
}
