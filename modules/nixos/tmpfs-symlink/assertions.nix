{ config, lib }:
allTmpfs: allWorlds: cfg:
map (instance: {
  assertion = config.users.users ? ${instance.user};
  message = "services.tmpfs-symlink.instances.${
    toString (lib.lists.findFirstIndex (x: x.user == instance.user) null cfg.instances)
  }.user: \"${instance.user}\" no such user in users.users.";
}) cfg.instances
