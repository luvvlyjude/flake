{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.symlink-worlds;
  options = import ./options.nix { inherit lib; };
  script = import ./script.nix { inherit lib pkgs; } allInstances;

  # nixpkgs wraps tmpfiles rules fields in single quotes
  # some maps have single quotes... (Lama's Practice Map)
  # we just escape the paths as well so its chill
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/tmpfiles.nix
  escape-path = lib.strings.escapeC [
    "\\"
    "'"
    "\""
    "\t"
    "\n"
    "\r"
  ];

  resolveUserAttrs =
    user: userAttrs:
    let
      home = config.users.users.${user}.home or "/nonexistent";
    in
    {
      inherit user;
      inherit (userAttrs) commonWorlds;
      group = config.users.users.${user}.group or "-";
      tmpfs-root =
        if user-attrs.tmpfs.enabled then
          "${config.users.users.${user}.home or "/nonexistent"}/${user-attrs.tmpfs.mount}"
        else
          null;
    };

  resolveInstanceAttrs =
    user: instanceName: instanceAttrs:
    let
      saves = "${user.home}/${instanceAttrs.saves}";
      destination = if instanceAttrs.tmpfs then "${user.tmpfs.mount}/${instanceName}-saves" else saves;
    in
    {
      inherit user destination saves;
      inherit (instanceAttrs) tmpfs;
      worlds = builtins.map (resolveWorldAttrs user destination) (
        user.commonWorlds ++ instanceAttrs.worlds
      );
    };

  resolveWorldAttrs = user: destination: relative-path: {
    inherit relative-path;
    name = builtins.baseNameOf relative-path;
    link = "${destination}/${builtins.baseNameOf relative-path}";
    target = "${user.home}/${relative-path}";
  };

  allInstances = lib.concatLists (
    lib.mapAttrsToList (
      user: userAttrs:
      lib.mapAttrsToList (resolveInstanceAttrs (resolveUserAttrs user userAttrs)) userAttrs.instances
    ) cfg.users
  );

  mount-unit = lib.mapNullable (
    tmpfs-mount: "${utils.escapeSystemdPath tmpfs-mount}.mount"
  ) cfg.tmpfs-mount;

  # unfortunately we create a state file so that we can
  # effectively clean up links that we dont declare anymore
  current-links = lib.unique (
    lib.concatMap (
      instance:
      (builtins.map (world: "${world.link-path}-module-managed") instance.worlds)
      ++ lib.optional instance.tmpfs instance.saves-path
    ) all-instances
  );

  current-links-file = pkgs.writeText "symlink-worlds-current-links" (
    lib.concatStringsSep "\n" (lib.sort (a: b: a < b) current-links) + "\n"
  );
in
{
  options.services.symlink-worlds = options;

  config = lib.mkIf cfg.enable {
    assertions =
      (lib.mapAttrsToList (user: _: {
        assertion = config.users.users ? ${user};
        message = "services.symlink-worlds.users.${user}: no such user in users.users.";
      }) cfg.users)
      ++ (lib.concatMap (
        instance:
        [
          {
            assertion = !instance.tmpfs || cfg.tmpfs-mount != null;
            message = "services.symlink-worlds: unexpected null: `tmpfs-mount` must not be null if ${instance.name}.tmpfs is `true`.";
          }
          {
            assertion = !instance.tmpfs || (cfg.tmpfs-mount == null || lib.hasPrefix "/" cfg.tmpfs-mount);
            message = "services.symlink-worlds: ${cfg.tmpfs-mount}: `tmpfs-mount` must be an absolute path.";
          }
          {
            assertion = !(lib.hasPrefix "/" instance.saves);
            message = "services.symlink-worlds: ${instance.user}.${instance.name}: `saves` must be relative to $HOME.";
          }
        ]
        ++ (lib.concatMap (world: [
          {
            assertion = !(lib.hasPrefix "/" world.relative-world-path);
            message = "services.symlink-worlds: ${world.relative-world-path}: world paths must be relative to $HOME.";
          }
        ]) instance.worlds)
      ) all-instances);

    systemd.tmpfiles.settings."10-symlink-worlds-mc" = lib.mkMerge (
      # merge list of sets
      builtins.map (
        instance:
        # saves destination directory
        {
          ${escape-path instance.saves-destination}.dir = {
            type = "d=";
            mode = "0755";
            inherit (instance) user group;
          };
        }
        # linking worlds
        // builtins.listToAttrs (
          builtins.map (
            world:
            lib.nameValuePair (escape-path world.link-path) {
              link = {
                type = "L+";
                argument = world.real-path;
              };
            }
          ) instance.worlds
        )
        # link saves directory
        # type is only 'L' not 'L+' so as to not overwrite saves folders with real worlds
        // lib.optionalAttrs (instance.tmpfs) {
          ${escape-path instance.saves-path}.link = {
            type = "L";
            argument = instance.tmpfs-path;
          };
          # something was angry because parent directory of instance.tmpfs-path was owned by root
          # unless i create/modify it specifically
          ${escape-path cfg.tmpfs-mount}.dir = {
            type = "d";
            mode = "0755";
            inherit (instance) user group;
          };
        }
      ) all-instances
    );

    systemd.services.symlink-worlds = {
      description = "Prune old links and refresh linked worlds";
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "local-fs.target"
      ];
      unitConfig.RequiresMountsFor = lib.optional (cfg.tmpfs-mount != null) cfg.tmpfs-mount;
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "tmpfs-symlink";
        ExecStart = lib.getExe script;
      };
    };

    fileSystems = lib.mapAttrs' (
      user: user-attrs:
      lib.mkIf user-attrs.tmpfs.enable (
        lib.nameValuePair user-attrs.mount-path {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "size=${user-attrs.tmpfs.size}"
            "mode=0755"
            "uid=${user}"
            "gid=${config.users.users.${user}.group or "users"}"
          ]
          ++ user-attrs.tmpfs.extra-options;
        }
      )
    ) cfg.users;
  };
}
