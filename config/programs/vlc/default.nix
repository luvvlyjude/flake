{
  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.vlc ];

      xdg.mimeApps.defaultApplications = {
        "audio/aac" = "vlc.desktop";
        "audio/flac" = "vlc.desktop";
        "audio/mp3" = "vlc.desktop";
        "audio/wav" = "vlc.desktop";

        "video/avi" = "vlc.desktop";
        "video/mkv" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
      };
    })
  ];
}
