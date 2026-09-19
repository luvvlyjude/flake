{
  lib,
  coreutils,
  fuzzel,
  jay-tray-item,
  luvvly-assets,
  luvvlyLib,
  procps,
  systemd,
  writeShellApplication,
  writeShellScript,
  fuzzelOutput ? "DP-2",
}:

let
  inherit (lib) concatMapStringsSep toLower;
  inherit (luvvlyLib) mkShellArgs;

  getIcon = luvvlyLib.iconPath luvvly-assets;
  getEscapedIcon = luvvlyLib.escapedIconPath luvvly-assets;
in
writeShellApplication {
  name = "jay-tray-power";
  runtimeInputs = [
    coreutils
    fuzzel
    jay-tray-item
    procps
    systemd
  ];
  text =
    let
      choices = [
        "Poweroff"
        "Reboot"
        "Hibernate"
      ];
      fuzzelArgs = mkShellArgs [
        "--dmenu"
        "--width=14"
        "--anchor=top-right"
        "--y-margin=20"
        "--hide-prompt"
        "--minimal-lines"
        "--cache=/dev/null"
        "--select=Cancel"
        "--output=${fuzzelOutput}"
      ];

      mkEntry = choice: choice + getEscapedIcon choice;
      mkCase = choice: choice + ") systemctl ${toLower choice} ;;";

      entries = concatMapStringsSep "\\n" mkEntry (choices ++ [ "Cancel" ]);
      cases = concatMapStringsSep "\n" mkCase choices;
    in
    ''
      jay-tray-item --icon ${getIcon "jay-logo"} --left-click ${writeShellScript "fuzzel-power-menu" ''
        # so that clicking the tray item toggles this fuzzel menu
        if pkill -f 'fuzzel.*--cache=/dev/null.*--select=Cancel'; then
          exit 0
        fi

        choice=$(echo -e "${entries}" | fuzzel ${fuzzelArgs})

        case "$choice" in
          ${cases}
          *) exit 0 ;;
        esac
      ''}
    '';
}
