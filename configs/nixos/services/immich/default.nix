{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  inherit (lib) escapeShellArgs getExe;

  screenshotsDir = config.hm.xdg.userDirs.extraConfig.SCREENSHOTS;

  # UNUSED RIGHT NOW JUST A DRY RUN
  # deletes week-old screenshots this run confirmed are on the server
  prune = pkgs.writeShellApplication {
    name = "immich-screenshots-prune";
    runtimeInputs = [
      pkgs.findutils
      pkgs.jq
    ];
    text = ''
      # immich-go logs files as "<folder>:<name>"
      mapfile -t confirmed < <(
        jq -r --arg root "${screenshotsDir}" '
          select(.msg == "server has duplicate")
          | .file
          | sub("^[^:]*:"; "")
          | "\($root)/\(.)"
        ' "$RUNTIME_DIRECTORY/upload.json"
      )

      find "''${confirmed[@]}" -maxdepth 0 -type f -mtime +7 -print # dry run right now
    '';
  };

  # %H is the hostname, %t the user's runtime dir
  uploadArgs = [
    "--server=http://luvvly-pc:2283"
    "--into-album=Screenshots"
    "--tag=Screenshots"
    "--tag=Device/%H"
    "--device-uuid=%H"
    "--no-ui"
    "--log-type=JSON"
    "--log-file=%t/immich-screenshots/upload.json"
  ];
in
{
  sops = {
    secrets."immich/api-key-all-permissions" = { };

    templates.immich-go-env = {
      content = "IMMICH_GO_UPLOAD_API_KEY=${config.sops.placeholder."immich/api-key-all-permissions"}";
      owner = username;
    };
  };

  # custom service to upload local screenshots to immich
  systemd.user = {
    paths.immich-screenshots = {
      wantedBy = [ "default.target" ];
      pathConfig.PathChanged = screenshotsDir;
    };

    services.immich-screenshots = {
      description = "Upload screenshots to Immich";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.templates.immich-go-env.path;
        ExecStart = "${getExe pkgs.immich-go} upload from-folder ${escapeShellArgs uploadArgs} ${screenshotsDir}";
        ExecStartPost = getExe prune;
        RuntimeDirectory = "immich-screenshots";
      };
    };
  };

  # firewall stays closed; reachable over tailscale0, which is trusted
  services.immich = {
    enable = true;
    host = "0.0.0.0";

    # the module's ProtectClock implies a DeviceAllow list, which hides the GPU
    # from CUDA (ML) and nvenc (transcoding) unless the devices are listed;
    # classes from /proc/devices, so the GPU's index doesn't matter
    accelerationDevices = [
      "char-nvidia"
      "char-nvidia-caps"
      "char-nvidia-uvm"
    ];

    settings = {
      ffmpeg = {
        accel = "nvenc";
        accelDecode = true;
      };

      machineLearning = {
        facialRecognition = {
          modelName = "antelopev2";
          # default 0.5; lower splits lookalikes instead of merging them
          maxDistance = 0.43;
          # default 0.7; catches more blurry and side-on faces
          minScore = 0.56;
          # default 3; manually created ppl can have 1 photo, everyone else needs:
          minFaces = 7;
        };

        # SO400M-384 OOMs on the 8 GB 2070 Super alongside OCR and faces
        clip.modelName = "ViT-L-16-SigLIP2-384__webli";

        ocr = {
          # medium needs ~2x small's VRAM; 8 GB fits only small at a usable resolution
          modelName = "PP-OCRv6_small";
          # default 736; multiple of 32, leaves room for games while OCR runs
          maxResolution = 864;
        };
      };
    };
  };
}
