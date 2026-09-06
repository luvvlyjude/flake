# yoinked this idea straight from ktrompfl B)
{ }:

rec {
  # --- action constructors ---
  #
  # One per action type the configuration uses; see the `Action` section of
  # jay's toml spec for the full list. Adding another one is a one-line
  # change and keeps the call sites free of `type = ...` tables.

  # `command` is a program name, an argument vector, or a `{ prog, args }`
  # table.
  exec = command: {
    type = "exec";
    exec = command;
  };

  # `connector` is a connector configuration, i.e. a `match` plus whatever
  # it changes about every output that matches it.
  configureConnector = connector: {
    type = "configure-connector";
    inherit connector;
  };
  enableConnector =
    match:
    configureConnector {
      inherit match;
      enabled = true;
    };
  disableConnector =
    match:
    configureConnector {
      inherit match;
      enabled = false;
    };

  createMark = name: {
    type = "create-mark";
    id = {
      inherit name;
    };
  };
  jumpToMark = name: {
    type = "jump-to-mark";
    id = {
      inherit name;
    };
  };

  configureIdle = idle: {
    type = "configure-idle";
    inherit idle;
  };

  defineAction = name: action: {
    type = "define-action";
    inherit name action;
  };

  pushMode = name: {
    type = "push-mode";
    inherit name;
  };

  showWorkspace = name: {
    type = "show-workspace";
    inherit name;
  };

  moveToWorkspace = name: {
    type = "move-to-workspace";
    inherit name;
  };

  multi = actions: {
    type = "multi";
    inherit actions;
  };

  showSingle = target: {
    type = "show-single";
    inherit target;
  };

  # `target` picks the output, either relative to the current one
  # (`{ direction = "left"; }`) or by name (`{ output.name = "beamer"; }`).
  moveToOutput = target: { type = "move-to-output"; } // target;

  switchToVt = num: {
    type = "switch-to-vt";
    inherit num;
  };

  # `delta` moves one or more window edges, e.g. `{ dx1 = -10; }`.
  resize = delta: { type = "resize"; } // delta;

  # # --- bar ---
  # #
  # # The two bar segments that reflect compositor state - the input mode and
  # # the idle inhibitor - cannot be observed from the outside, so whatever
  # # changes either of them pushes the new value into the bar itself.
  # bar =
  #   let
  #     jay-bar = lib.getExe pkgs.jay-bar;
  #   in
  #   {
  #     mode =
  #       name:
  #       exec [
  #         jay-bar
  #         "mode"
  #         name
  #       ];
  #     idleInhibitor =
  #       state:
  #       exec [
  #         jay-bar
  #         "idle-inhibitor"
  #         state
  #       ];
  #     init = exec [
  #       jay-bar
  #       "init"
  #     ];
  #   };

  # --- constants ---

  # Shared by behavior.nix, which arms the timeout, and actions.nix, which
  # restores it when the idle inhibitor is switched off again.
  idle = {
    minutes = 10;
    # screen goes black during grace period before idle action and output disable
    grace-period.seconds = 15;
  };
}
