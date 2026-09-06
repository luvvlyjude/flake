{ jayLib, ... }:

let
  inherit (jayLib)
    createMark
    defineAction
    jumpToMark
    moveToWorkspace
    showSingle
    ;
in
{
  windows = [
    {
      # described by https://github.com/mahkoh/jay/issues/1077#issuecomment-5469636862
      name = "mono-default-layout";
      match = {
        is-workspace-container = true;
        just-mapped = true;
        types = "container";
      };
      action = showSingle "self";
    }
    {
      name = "track-left-output";
      match.all = [
        { focused = true; }
        { workspace-regex = "[12345]"; }
      ];
      action = [
        (createMark "left-monitor")
        (defineAction "switch-monitor" (jumpToMark "right-monitor"))
      ];
    }
    {
      name = "track-right-output";
      match.all = [
        { focused = true; }
        { workspace-regex = "[67890]"; }
      ];
      action = [
        (createMark "right-monitor")
        (defineAction "switch-monitor" (jumpToMark "left-monitor"))
      ];
    }
    {
      name = "2nd-monitor";
      match = {
        just-mapped = true;
        any = [
          { app-id = "discord"; }
          { app-id = "spotify"; }
          { app-id = "com.obsproject.Studio"; }
        ];
      };
      action = moveToWorkspace "0";
      auto-focus = false;
    }
    {
      name = "waywall";
      match.app-id = "waywall";
      action = moveToWorkspace "1";
      auto-focus = false;
    }
  ];
}
