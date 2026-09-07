{
  lib,
  coreutils,
  fuzzel,
  jay-screenshot,
  jay-tray-item,
  libnotify,
  procps,
  satty,
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

  # copy all icons to store under 1 directory
  icons = ./icons;

  getIcon = icon: "${icons}/${toLower icon}.png";
  getEscapedIcon = icon: ''\0icon\x1f${getIcon icon}'';

  mkShellArgs = concatMapStringsSep " " escapeShellArg;
in
{
  jay-screenshot-tool = writeShellApplication {
    name = "jay-screenshot-tool";
    runtimeInputs = [
      coreutils
      jay-screenshot
      libnotify
      satty
    ];
    text =
      let
        notifArgs = mkShellArgs [
          "--app-name=jay-screenshot-tool"
          "--app-icon=${getIcon "jay-logo"}"
        ];
        captureNotifArgs = mkShellArgs [
          "--action=edit=Edit"
          "--action=save=Save"
          "--expire-time=5000"
          "Screenshot"
          "copied to clipboard"
        ];
        saveNotifArgs = mkShellArgs [
          "--expire-time=2000"
          "Screenshot"
          "saved to screenshots folder"
        ];
      in
      ''
        save() {
          dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
          mkdir -p "$dir"
          saved="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
          mv "$1" "$saved"
          echo "$saved"
        }

        shot=$(mktemp --tmpdir screenshot-XXXXXXXX.png)
        trap 'rm -f "$shot"' EXIT

        jay-screenshot --copy --file "$shot" "$@"

        action=$(notify-send --icon="$shot" ${notifArgs} ${captureNotifArgs})

        case "$action" in
          edit)
            saved=$(save "$shot")
            satty --filename "$saved" --output-filename "''${saved%.png}-edited.png"
            ;;
          save)
            saved=$(save "$shot")
            notify-send --icon="$saved" ${notifArgs} ${saveNotifArgs}
            ;;
        esac
      '';
  };

  jay-tray-power = writeShellApplication {
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
  };
}
