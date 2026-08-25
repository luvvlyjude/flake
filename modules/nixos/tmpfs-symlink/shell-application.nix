{
  for,
  lib,
  pkgs,
  sh,
}:

cfg:

let
  # unfortunately we create a state file so that we can
  # effectively clean up links that we dont declare anymore
  stateFilePath = "/var/lib/tmpfs-symlink/links";

  stateFile = pkgs.writeText "tmpfs-symlink-all-links" (
    builtins.concatStringsSep "\n" (
      lib.unique (
        for.users (
          user:
          for.instances (
            _: instance:
            for.worlds (
              _: _: world:
              world.link
            ) user instance instance.worlds
            ++ lib.optional instance.tmpfs instance.saves
          ) user user.instances
        ) cfg.users
      )
    )
    + "\n"
  );
in
pkgs.writeShellApplication {
  name = "tmpfs-symlink";
  runtimeInputs = [
    pkgs.coreutils
  ];
  text = builtins.concatStringsSep "\n" (
    [ (sh.deleteLinksFromFile stateFilePath) ]

    ++ for.users (
      user:
      for.instances (
        _: instance:
        [ (sh.createUserOwnedDirectory user instance.savesDestination) ]

        ++ lib.optionals instance.tmpfs [
          (sh.deleteEmptyDirectory instance.saves)
          (sh.createLink instance.savesTmpfs instance.saves)
        ]

        ++ for.worlds (
          _: _: world:
          sh.createLink world.target world.link
        ) user instance instance.worlds
      ) user user.instances
    ) cfg.users

    ++ [ (sh.installFileToPath stateFile stateFilePath) ]
  );
}
