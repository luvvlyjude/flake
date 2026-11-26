{
  flake.nixosModules.limine = { pkgs, ... }: {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;

        limine = {
          enable = true;
          maxGenerations = 10;
          secureBoot = {
            enable = true;
            autoEnrollKeys = {
              enable = true;
              # firmware-builtin adds malformed Gigabyte db certs the kernel rejects at boot
              extraArgs = [ "--microsoft" ];
            };
            autoGenerateKeys = true;
          };
          additionalFiles."efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
          extraEntries = ''
            /memtest86
              protocol: efi
              path: boot():///efi/memtest86/memtest86.efi
          '';
        };
      };
    };
  };
}
