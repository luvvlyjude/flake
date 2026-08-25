{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tmpfs-symlink;
  options = import ./options.nix { inherit lib; };
  assertions = import ./assertions.nix { inherit config lib; } cfg;

  for = import ./for-lib.nix { inherit lib resolve; };
  resolve = import ./resolve-lib.nix { inherit config; };
  sh = import ./sh-lib.nix { inherit lib; };

  shellApplication = import ./shell-application.nix {
    inherit
      for
      lib
      pkgs
      sh
      ;
  } cfg;
in
{
  options.services.tmpfs-symlink = options;

  config = lib.mkIf cfg.enable {
    inherit assertions;

    systemd.services.tmpfs-symlink = {
      description = "Create links to worlds and saves; using tmpfs if specified.";
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "local-fs.target"
      ];
      unitConfig.RequiresMountsFor = for.users (
        user: lib.optional (user.tmpfs != null) user.tmpfs.root
      ) cfg.users;
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "tmpfs-symlink";
        ExecStart = lib.getExe shellApplication;
      };
    };

    systemd.mounts = (
      for.users (
        user:
        lib.optional (user.tmpfs != null) {
          what = "tmpfs";
          where = user.tmpfs.root;
          type = "tmpfs";
          options = lib.concatStringsSep "," user.tmpfs.options;
          wantedBy = [ "local-fs.target" ];
          wants = [ "tmpfs-symlink.service" ];
          before = [ "tmpfs-symlink.service" ];
        }
      ) cfg.users
    );
  };
}
