{
  lib,
  coreutils,
  fuzzel,
  jay-tray-item,
  procps,
  systemd,
  writeShellApplication,
  writeShellScript,
  fuzzelOutput ? "DP-2",
}:

let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    getExe
    toLower
    ;

  choices = [
    "Poweroff"
    "Reboot"
    "Hibernate"
  ];

  # copy all icons to store under 1 directory
  icons = ./icons;

  getIcon = icon: "${icons}/${toLower icon}.png";
  getEscapedIcon = icon: ''\0icon\x1f${getIcon icon}'';

  mkEntry = choice: choice + getEscapedIcon choice;
  mkCase = choice: choice + ") systemctl ${toLower choice} ;;";

  entries = concatMapStringsSep "\\n" mkEntry (choices ++ [ "Cancel" ]);
  cases = concatMapStringsSep "\n" mkCase choices;

  fuzzelArgs = concatMapStringsSep " " escapeShellArg [
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

  powerMenu = writeShellApplication {
    name = "fuzzel-power-menu";
    runtimeInputs = [
      coreutils
      fuzzel
      procps
      systemd
    ];
    text = ''
      # so that clicking the tray item toggles this fuzzel menu
      if pkill -f 'fuzzel.*--cache=/dev/null.*--select=Cancel'; then
        exit 0
      fi

      choice=$(echo -e "${entries}" | fuzzel ${fuzzelArgs})

      case "$choice" in
        ${cases}
        *) exit 0 ;;
      esac
    '';
  };
in
writeShellScript "jay-tray-power" ''
  ${getExe jay-tray-item} --icon ${getIcon "jay-logo"} --left-click ${getExe powerMenu}
''
