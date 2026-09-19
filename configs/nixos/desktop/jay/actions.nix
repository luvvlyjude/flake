{ jayLib, ... }:

let
  inherit (jayLib) jumpToMark;
in
{
  actions = {
    switch-monitor = jumpToMark "right-monitor";
  };
}
