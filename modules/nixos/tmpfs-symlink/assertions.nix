{ config, lib }:
allTmpfs: cfg:
lib.imap0 (i: instance: {
  assertion = config.users.users ? ${instance.user};
  message = "services.tmpfs-symlink.instances.${toString i}.user: \"${instance.user}\" no such user in users.users.";
}) cfg.instances
++ [
  {
    assertion = lib.allUnique (map (tmpfs: tmpfs.where) allTmpfs);
    message = "services.tmpfs-symlink: two tmpfs-enabled instances declare the same saves path.";
  }
]
