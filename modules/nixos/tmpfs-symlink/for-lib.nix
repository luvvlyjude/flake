{ lib, resolve }:

{
  users =
    func: users:
    builtins.concatLists (
      lib.mapAttrsToList (
        name: attrs:
        let
          user = resolve.userAttrs name attrs;
        in
        lib.toList (func user)
      ) users
    );

  instances =
    func: user: instances:
    builtins.concatLists (
      lib.mapAttrsToList (
        name: attrs:
        let
          instance = resolve.instanceAttrs user name attrs;
        in
        lib.toList (func user instance)
      ) instances
    );

  worlds =
    func: user: instance: worlds:
    builtins.concatLists (
      builtins.map (
        path:
        let
          world = resolve.worldAttrs user instance path;
        in
        lib.toList (func user instance world)
      ) worlds
    );
}
