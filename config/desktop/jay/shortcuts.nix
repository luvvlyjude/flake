{
  jayLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (jayLib)
    exec
    moveToOutput
    moveToWorkspace
    pushMode
    showWorkspace
    switchToVt
    ;

  mod = "logo";

  # --- keys ---

  # `field`/`sign` describe which edge of a window the direction resizes and
  # in which direction that edge grows, see the resize mode below.
  dirs = [
    (mkDir "left" [ "h" "Left" ] "dx1" (-1))
    (mkDir "down" [ "j" "Down" ] "dy2" (1))
    (mkDir "up" [ "k" "Up" ] "dy1" (-1))
    (mkDir "right" [ "l" "Right" ] "dx2" (1))
  ];

  dirActions = [
    (mkDirAction "${mod}-" (d: "focus-${d}"))
    (mkDirAction "${mod}-shift-" (d: "move-${d}"))
    (mkDirAction "${mod}-shift-ctrl-" (d: moveToOutput { direction = d; }))
  ];

  mkDir = dir: keys: field: sign: {
    inherit
      dir
      keys
      field
      sign
      ;
  };

  mkDirAction = prefix: action: {
    inherit prefix action;
  };

  # Shortcuts that should fire again while the key is held. Only complex
  # shortcuts can repeat, so this wraps a plain shortcut table into one.
  repeating = lib.mapAttrs (
    _: action: {
      inherit action;
      repeat = true;
    }
  );

  mkPlayerctl =
    cmd:
    exec [
      (lib.getExe pkgs.playerctl)
      "--ignore-player=firefox"
      cmd
    ];

  # generate {prefix}{key} and {prefix}{arrow} bindings for all four directions
  dirBindings = lib.listToAttrs (
    lib.concatMap (
      dir:
      lib.concatMap (
        key: map (action: lib.nameValuePair "${action.prefix}${key}" (action.action dir.dir)) dirActions
      ) dir.keys
    ) dirs
  );

  workspaceBindings = lib.listToAttrs (
    lib.concatMap (ws: [
      (lib.nameValuePair "${mod}-${ws}" (showWorkspace ws))
      (lib.nameValuePair "${mod}-shift-${ws}" (moveToWorkspace ws))
    ]) (map toString (lib.range 0 9))
  );

  vtBindings = lib.listToAttrs (
    lib.genList (n: lib.nameValuePair "ctrl-alt-F${toString (n + 1)}" (switchToVt (n + 1))) 12
  );

  screenshotOf =
    mode:
    exec {
      shell =
        "${lib.getExe pkgs.jay-screenshot} ${mode} "
        + (lib.optionalString (mode == "region") "\"$(${lib.getExe pkgs.slurp} -d)\"");
    };
in
rec {
  complex-shortcuts = repeating (
    dirBindings
    // {
      "${mod}-semicolon" = "$switch-monitor";
    }
  );

  shortcuts =
    vtBindings
    // workspaceBindings
    // {
      F24 = pushMode "disabled";
      F23 = "none";

      # compositor
      "${mod}-alt-m" = "quit";
      "${mod}-alt-r" = "reload-config-toml";

      # windows
      "${mod}-shift-q" = "close";
      "${mod}-f" = "toggle-fullscreen";
      "${mod}-v" = "toggle-floating";
      "${mod}-d" = "split-horizontal";
      "${mod}-m" = "toggle-mono";

      # launch
      "${mod}-Return" = exec "footclient";
      "${mod}-r" = exec "fuzzel";

      "${mod}-shift-s" = screenshotOf "region";

      # player
      XF86AudioPlay = mkPlayerctl "play-pause";
      XF86AudioNext = mkPlayerctl "next";
      XF86AudioPrev = mkPlayerctl "previous";
    };

  modes."disabled" = {
    complex-shortcuts = lib.mapAttrs (_: _: { action = "none"; }) complex-shortcuts;
    shortcuts = lib.mapAttrs (name: _: if name == "F23" then "pop-mode" else "none") shortcuts;
  };
}
