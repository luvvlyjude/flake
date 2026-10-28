{
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

  # ProtectHome hides /home from immich; expose only these folders, read-only
  systemd.services.immich-server.serviceConfig.BindReadOnlyPaths = [
  ];
}
