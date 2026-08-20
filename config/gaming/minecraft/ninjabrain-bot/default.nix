{
  home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        prefsXml = pkgs.writeText "prefs.xml" ''
          <?xml version="1.0" encoding="UTF-8" standalone="no"?>
          <!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">
          <map MAP_XML_VERSION="1.0">
            <entry key="angle_adjustment_display_type" value="1"/>
            <entry key="angle_adjustment_type" value="1"/>
            <entry key="default_boat_type" value="2"/>
            <entry key="direction_help_enabled" value="true"/>
            <entry key="hotkey_decrement_code" value="65542"/>
            <entry key="hotkey_decrement_modifier" value="0"/>
            <entry key="hotkey_increment_code" value="65543"/>
            <entry key="hotkey_increment_modifier" value="0"/>
            <entry key="hotkey_redo_code" value="65602"/>
            <entry key="hotkey_redo_modifier" value="0"/>
            <entry key="hotkey_reset_code" value="65600"/>
            <entry key="hotkey_reset_modifier" value="0"/>
            <entry key="hotkey_undo_code" value="65601"/>
            <entry key="hotkey_undo_modifier" value="0"/>
            <entry key="language_v2" value="en-US"/>
            <entry key="mismeasure_warning_enabled" value="true"/>
            <entry key="sensitivity" value="0.02291165"/>
            <entry key="sensitivity_manual" value="0.02291165"/>
            <entry key="settings_version" value="3"/>
            <entry key="show_angle_updates" value="true"/>
            <entry key="sigma_boat" value="7.0E-4"/>
            <entry key="size" value="1"/>
            <entry key="stronghold_display_type" value="2"/>
            <entry key="translucent" value="false"/>
            <entry key="use_precise_angle" value="true"/>
            <entry key="view" value="1"/>
          </map>
        '';
      in
      {
        home.packages = [
          (pkgs.ninjabrain-bot.override { jre = pkgs.temurin-bin-17; })
        ];

        home.activation.ninjabrainbotPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run install -Dm644 ${prefsXml} "$HOME/.java/.userPrefs/ninjabrainbot/prefs.xml"
        '';
      }
    )
  ];
}
