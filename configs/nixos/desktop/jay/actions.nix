{ luvvlyLib, ... }:

let
  inherit (luvvlyLib.jay) jumpToMark;
in
{
  actions = {
    switch-monitor = jumpToMark "right-monitor";
  };
}
