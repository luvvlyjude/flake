{ lib }:

let
  block =
    name: mkValue: attrs:
    "@${name} {\n${lib.generators.toKeyValue { mkKeyValue = k: v: "    ${mkValue k v};"; } attrs}}\n";
in
block "OBSThemeMeta" (k: v: "${k}: '${v}'") {
  name = "Luvvly";
  id = "com.luvvly.Yami.Luvvly";
  extends = "com.obsproject.Yami";
  author = "jude";
  dark = "true";
}
+ block "OBSThemeVars" (k: v: "--${k}: ${v}") {
  grey1 = "#5A3355";
  grey2 = "#4A2445";
  grey3 = "#3D1A38";
  grey4 = "#350030";
  grey5 = "#250015";
  grey6 = "#140010";
  grey7 = "#0A0008";
  grey8 = "#000000";

  primary = "#8A007A";
  primary_light = "#B0209E";
  primary_lighter = "#E060D0";
  primary_dark = "#5A0050";
  primary_darker = "#350030";

  bg_window = "var(--grey8)";
  bg_base = "var(--grey8)";
  bg_preview = "var(--grey8)";

  text = "#EEEEEE";
  text_light = "#EEEEEE";
  text_muted = "#999999";
}
