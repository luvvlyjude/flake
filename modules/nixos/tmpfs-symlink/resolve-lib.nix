{ config }:

{
  userAttrs =
    name: attrs:
    let
      home = config.users.users.${name}.home;
      group = config.users.users.${name}.group;
    in
    {
      inherit group name home;
      inherit (attrs) instances worlds;
      tmpfs =
        if attrs.tmpfs.enable then
          {
            root = "${home}/${attrs.tmpfs.mount}";
            options = [
              "size=${attrs.tmpfs.size}"
              "mode=0755"
              "uid=${name}"
              "gid=${group}"
            ]
            ++ attrs.tmpfs.extra-options;
          }
        else
          null;
    };

  instanceAttrs =
    user: name: attrs:
    let
      saves = "${user.home}/${attrs.saves}";
      savesTmpfs = if attrs.tmpfs then "${user.tmpfs.root}/${name}-saves" else null;
    in
    {
      inherit user saves savesTmpfs;
      inherit (attrs) tmpfs;
      savesDestination = if attrs.tmpfs then savesTmpfs else saves;
      worlds = attrs.worlds ++ user.worlds;
    };

  worldAttrs = user: instance: path: {
    target = "${user.home}/${path}";
    link = "${instance.savesDestination}/${builtins.baseNameOf path}";
  };
}
