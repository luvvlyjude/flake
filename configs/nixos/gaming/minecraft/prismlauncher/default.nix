{
  hm =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      mcsrPkgs = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system};

      # autoPatchelf corrupts native-image so the install check segfaults; only java is used
      # https://github.com/NixOS/nixpkgs/pull/578694
      graalvm = mcsrPkgs.graalvm-21.overrideAttrs { doInstallCheck = false; };

      # Tracked build (rule A.8.4), unpatched; Prism's LD_LIBRARY_PATH covers its dlopens.
      glfw = pkgs.fetchurl {
        name = "libglfw.so";
        url = "https://github.com/JamiKettunen/mcsr-glfw/releases/download/20261019-v3.5.1/libglfw-x86_64.so";
        sha512 = "9c6f51924ca376ba13936157778de2e7e35be34c69ab904241db32266161f3184974e08daba73eeea91afbab329b23c8e088985845562946e3c015faca9ab036";
      };
    in
    {
      programs.prismlauncher = {
        enable = true;
        package = pkgs.prismlauncher.override {
          additionalLibs = [
            pkgs.jemalloc
          ];
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
          # Env = "\"{\\\"LD_PRELOAD\\\":\\\"${lib.getLib pkgs.jemalloc}/lib/libjemalloc.so.2\\\",\\\"MALLOC_CONF\\\":\\\"dirty_decay_ms:10000,muzzy_decay_ms:10000\\\",\\\"MANGOHUD_CONFIG\\\":\\\"fps_limit=300,no_display\\\",\\\"__GL_THREADED_OPTIMIZATIONS\\\":\\\"0\\\"}\"";
          Env = "\"{\\\"LD_PRELOAD\\\":\\\"${lib.getLib pkgs.jemalloc}/lib/libjemalloc.so.2\\\",\\\"MANGOHUD_CONFIG\\\":\\\"fps_limit=300,no_display\\\",\\\"__GL_THREADED_OPTIMIZATIONS\\\":\\\"0\\\"}\"";
          EnableFeralGamemode = true;
          EnableMangoHud = true;
          IgnoreJavaCompatibility = true;
          IgnoreJavaWizard = true;
          JavaPath = "${lib.getBin graalvm}/bin/java";
          JvmArgs = "-XX:+UseZGC -XX:+AlwaysPreTouch -Dgraal.TuneInlinerExploration=1 -XX:NmethodSweepActivity=1";
          MaxMemAlloc = 4096;
          MinMemAlloc = 4096;
          UseNativeGLFW = true;
          CustomGLFWPath = "${glfw}";
          WrapperCommand = "waywall wrap --";
        };
      };
    };
}
