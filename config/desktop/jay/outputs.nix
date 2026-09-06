{ lib, ... }:

let
  outputs = [
    {
      name = "left";
      match.model = "ASUS VP28U";
      match.serial-number = "183231";
      x = 0;
      y = 0;
      scale = 2.0;
      mode = {
        width = 3840;
        height = 2160;
        refresh-rate = 59.997;
      };
      vrr.mode = "always";
      tearing.mode = "variant1"; # enabled when one or more applications r displayed fullscreen
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
      ];
    }
    {
      name = "right";
      match.model = "SyncMaster";
      match.serial-number = "HVZP203681";
      x = 1920;
      y = 10;
      mode = {
        width = 1680;
        height = 1050;
        refresh-rate = 59.954;
      };
      workspaces = [
        "6"
        "7"
        "8"
        "9"
        "0"
      ];
    }
  ];

  # Inverts the `workspaces` lists above: every workspace mentioned by any
  # output gets the outputs that mention it, in the order they are declared.
  workspaceNames = lib.unique (lib.concatMap (output: output.workspaces) outputs);
  initialOutput = name: {
    initial-output = map (output: { inherit (output) name; }) (
      lib.filter (output: lib.elem name output.workspaces) outputs
    );
  };
in
{
  # The displays and which of them a workspace starts out on.
  outputs = map (output: removeAttrs output [ "workspaces" ]) outputs;
  workspaces = lib.genAttrs workspaceNames initialOutput;
}
