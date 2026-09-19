{
  coreutils,
  jay-screenshot,
  libnotify,
  luvvly-assets,
  luvvlyLib,
  satty,
  wl-clipboard,
  writeShellApplication,
}:

let
  inherit (luvvlyLib) mkShellArgs;

  getIcon = luvvlyLib.iconPath luvvly-assets;
in
writeShellApplication {
  name = "jay-screenshot-tool";
  runtimeInputs = [
    coreutils
    jay-screenshot
    libnotify
    satty
    wl-clipboard
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
          edited="''${saved%.png}-edited.png"
          satty --filename "$saved" --output-filename "$edited"
          wl-copy --type image/png < "$edited"
          ;;
        save)
          saved=$(save "$shot")
          notify-send --icon="$saved" ${notifArgs} ${saveNotifArgs}
          ;;
      esac
    '';
}
