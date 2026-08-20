{
  home-manager.sharedModules = [
    (
      {
        inputs,
        lib,
        pkgs,
        ...
      }:
      let
        mcsrPkgs = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        home.packages = [
          pkgs.glfw-waywall
        ];

        programs.prismlauncher = {
          enable = true;
          package = pkgs.prismlauncher.override {
            additionalLibs = [
              pkgs.jemalloc
            ];
            jdks = [
              mcsrPkgs.graalvm-21
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
            JavaPath = "${lib.getBin mcsrPkgs.graalvm-21}/bin/java";
            JvmArgs = "-XX:+UseZGC -XX:+AlwaysPreTouch";
            MaxMemAlloc = 4096;
            MinMemAlloc = 4096;
            UseNativeGLFW = true;
            CustomGLFWPath = "${pkgs.glfw-waywall}/lib/libglfw.so";
            WrapperCommand = "waywall wrap --";
          };
        };
      }
    )
  ];
}
