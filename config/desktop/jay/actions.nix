{ jayLib, ... }:

let
  inherit (jayLib) jumpToMark showWorkspace;
in
{
  actions = {
    switch-monitor = jumpToMark "right-monitor";
  };
}
