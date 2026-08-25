{ config, lib }:
cfg:
lib.concatLists (
  lib.mapAttrsToList (
    name: user:
    [
      {
        assertion = config.users.users ? ${name};
        message = "services.tmpfs-symlink.users.${name}: no such user in users.users.";
      }
    ]
    ++ lib.concatLists (
      lib.mapAttrsToList (instanceName: instance: [
        {
          assertion = instance.tmpfs -> user.tmpfs.enable;
          message = "services.tmpfs-symlink.users.${name}.instances.${instanceName}: tmpfs is true but users.${name}.tmpfs.enable is false.";
        }
        {
          assertion = lib.allUnique (builtins.map builtins.baseNameOf (instance.worlds ++ user.worlds));
          message = "services.tmpfs-symlink.users.${name}: two worlds with the same name would cause links to collide.";
        }
      ]) user.instances
    )
  ) cfg.users
)
