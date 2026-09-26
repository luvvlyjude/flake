# yoinked this idea straight from ktrompfl B)

# The vocabulary the jay configuration is written in: constructors for the
# actions its toml spec spells as `{ type = ...; }` tables, the two bar
# segments that have to be pushed rather than polled, and the idle timeout
# that more than one part refers to.

{
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
}
