{ inputs, ... }:
{
  flake.homeModules.prismlauncher =
    {
      lib,
      pkgs,
      ...
    }:
    let
      mcsrPkgs = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system};

      # autoPatchelf corrupts native-image so the install check segfaults; only java is used
      # https://github.com/NixOS/nixpkgs/pull/578694
      graalvm = mcsrPkgs.graalvm-21.overrideAttrs { doInstallCheck = false; };
    in
    {
      programs.prismlauncher = {
        enable = true;
        package = pkgs.prismlauncher.override {
          glfw3-minecraft = pkgs.glfw-mcsr;
          jdks = [
            graalvm
          ];
          textToSpeechSupport = false;
        };
        settings = {
          ApplicationTheme = "dark";
          AutoCloseConsole = false;
          AutomaticJavaDownload = false;
          AutomaticJavaSwitch = false;
          ConsoleFont = "Noto Sans Mono";
          ConsoleFontSize = 12;
          # double nested toJson because Prism stores Env as JSON inside quoted INI
          Env = builtins.toJSON (
            builtins.toJSON {
              LD_PRELOAD = "${lib.getLib pkgs.jemalloc}/lib/libjemalloc.so.2";
              MANGOHUD_CONFIG = "fps_limit=300,no_display";
              __GL_THREADED_OPTIMIZATIONS = "0";
            }
          );
          EnableFeralGamemode = true;
          EnableMangoHud = true;
          IgnoreJavaCompatibility = true;
          IgnoreJavaWizard = true;
          JavaPath = "${lib.getBin graalvm}/bin/java";
          JvmArgs = "-XX:+UseZGC -XX:+AlwaysPreTouch -Dgraal.TuneInlinerExploration=1 -XX:NmethodSweepActivity=1";
          MaxMemAlloc = 4096;
          MinMemAlloc = 4096;
          UseNativeGLFW = true;
          WrapperCommand = "waywall wrap --";
        };
      };
    };
}
