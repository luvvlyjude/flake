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
    filter
    getExe
    mkIf
    ;

  cfg = config.services.tmpfs-symlink;
  options = import ./options.nix { inherit lib; };
  assertions = import ./assertions.nix { inherit config lib; } allTmpfs allWorlds cfg;

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

  stateFile = (
    pkgs.writeText "tmpfs-symlink-all-links" (
      concatStringsSep "\n" (map (world: world.link) allWorlds) + "\n"
    )
  );

  script = pkgs.writeShellApplication {
    name = "tmpfs-symlink";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      # delete all links declared in the previous state file
      if [ -f "${stateFilePath}" ]; then
        while IFS= read -r line; do
          if [ -L "$line" ]; then
            echo "Removing link: $line"
            rm -- "$line"
          fi
        done < "${stateFilePath}"
      fi

      # manually start the mount unit only after deleting links
      # this way all on-disk links get deleted before mounting tmpfs
      # if someone is enabling tmpfs for the first time it would otherwise
      # leave behind links on disk
      ${concatMapStringsSep "\n" (tmpfs: ''
        systemctl start ${escapeSystemdPath tmpfs.where}.mount
      '') allTmpfs}

      # create all world links
      ${concatMapStringsSep "\n" (world: ''
        if [ -e "${world.link}" ]; then
          echo "Warning: Something with the same name already exists at ${world.link}. Skipping..."
        elif [ ! -d "$(dirname "${world.link}")" ]; then
          echo "Warning: Parent directory does not exist for ${world.link}. Skipping..."
        else
          if [ ! -e "${world.target}" ]; then
            echo "Warning: Target source does not exist for ${world.link}. Creating dead link..."
          fi
          ln -sT "${world.target}" "${world.link}"
        fi
      '') allWorlds}

      install -Dm644 ${stateFile} ${stateFilePath}
    '';
  };
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
        ExecStart = getExe script;
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
