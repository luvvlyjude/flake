{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (utils) escapeSystemdPath;
  inherit (lib)
    concatMap
    concatMapStringsSep
    concatStringsSep
    escapeShellArg
    filter
    mkIf
    ;

  cfg = config.services.tmpfs-symlink;
  options = import ./options.nix { inherit lib; };
  assertions = import ./assertions.nix { inherit config lib; } allTmpfs cfg;

  allTmpfs = map (
    instance:
    let
      home = config.users.users.${instance.user}.home;
      group = config.users.users.${instance.user}.group;
    in
    {
      inherit group;
      inherit (instance) user size;
      where = "${home}/${instance.saves}";
    }
  ) (filter (instance: instance.tmpfs) cfg.instances);

  allWorlds = concatMap (
    instance:
    let
      home = config.users.users.${instance.user}.home;
    in
    map (world: {
      target = "${home}/${world}";
      link = "${home}/${instance.saves}/${baseNameOf world}";
    }) instance.worlds
  ) cfg.instances;

  # unfortunately we create a state file so that we can
  # effectively clean up links that we dont declare anymore
  stateFilePath = "/var/lib/tmpfs-symlink/links";

  stateFile = pkgs.writeText "tmpfs-symlink-all-links" (
    concatStringsSep "\n" (map (world: world.link) allWorlds) + "\n"
  );

  script = pkgs.writeShellScript "tmpfs-symlink" ''
    # delete all links declared in the previous state file
    stateFilePath=${escapeShellArg stateFilePath}
    if [ -f "$stateFilePath" ]; then
      while IFS= read -r line; do
        if [ -L "$line" ]; then
          echo "Removing link: $line"
          rm -- "$line"
        fi
      done < "$stateFilePath"
    fi

    # manually start the mount unit only after deleting links
    # this way all on-disk links get deleted before mounting tmpfs
    # if someone is enabling tmpfs for the first time it would otherwise
    # leave behind links on disk
    ${concatMapStringsSep "\n" (tmpfs: ''
      ${config.systemd.package}/bin/systemctl start "${escapeSystemdPath tmpfs.where}.mount"
    '') allTmpfs}

    # create all world links
    ${concatMapStringsSep "\n" (world: ''
      link=${lib.escapeShellArg world.link}
      target=${lib.escapeShellArg world.target}
      if [ -e "$link" ] || [ -L "$link" ]; then
        echo "Warning: Something already exists at $link. Skipping..."
      elif [ ! -d "$(dirname "$link")" ]; then
        echo "Warning: Parent directory does not exist for $link. Skipping..."
      else
        if [ ! -e "$target" ]; then
          echo "Warning: Target does not exist for $link. Creating dead link..."
        fi
        ln -sT "$target" "$link"
      fi
    '') allWorlds}

    install -Dm644 ${stateFile} ${stateFilePath}
  '';
in
{
  options.services.tmpfs-symlink = options;

  config = mkIf cfg.enable {
    inherit assertions;

    systemd.services.tmpfs-symlink = {
      description = "Create links to worlds and saves; using tmpfs if specified.";
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "local-fs.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "tmpfs-symlink";
        ExecStart = script;
      };
    };

    systemd.mounts = map (tmpfs: {
      inherit (tmpfs) where;
      what = "tmpfs";
      type = "tmpfs";
      options = concatStringsSep "," [
        "size=${tmpfs.size}"
        "mode=0755"
        "uid=${tmpfs.user}"
        "gid=${tmpfs.group}"
      ];
    }) allTmpfs;
  };
}
