{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ ];
    # load early: stage 2 skips modules-load on this machine (systemd#3436)
    initrd.kernelModules = [ "it87" ];
    # stock it87 has no IT8688E, the fan chip on this X570 board.
    # nixpkgs installs it next to the stock it87.ko.xz, which depmod then picks,
    # so move it to updates/, which depmod always prefers. Last make flag wins.
    extraModulePackages = [
      (config.boot.kernelPackages.it87.overrideAttrs (old: {
        makeFlags = old.makeFlags ++ [
          "MODDESTDIR=$(out)/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/updates"
        ];
      }))
    ];
    # Gigabyte's ACPI claims the chip's ports, so it87 refuses to load without this
    extraModprobeConfig = "options it87 ignore_resource_conflict=1";
    blacklistedKernelModules = [
      # disable module for unused 2070 SUPER GPU USB-C controller
      "ucsi_ccg"
    ];

    kernelParams = [
      # dont touch BIOS configured ASPM value
      "pcie_aspm=off"
      # keep NVMe out of deep sleep
      "nvme_core.default_ps_max_latency_us=0"
      # let OpenRGB see RAM by letting i2c-piix4 use the SMBus the BIOS reserves
      "acpi_enforce_resources=lax"
    ];
  };

  fileSystems = {
    "/" =
      let
        uuid = "70fdf5d5-4f7c-4def-b8eb-6df5f6da441d";
      in
      {
        device = "UUID=${uuid}";
        fsType = "bcachefs";
        options = [ "x-systemd.wants=bcachefs-wait-devices@${uuid}.service" ];
      };

    "/boot" = {
      device = "/dev/disk/by-uuid/1926-4056";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/mnt/readyshare" = {
      device = "//192.168.1.1/USB_Storage";
      fsType = "cifs";
      options = [
        "guest"
        "uid=1000"
        "gid=100"
        "_netdev"
        # mount on first access so a powered-off router can't stall boot or shutdown
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        # same negotiation as unset, silences the "no dialect specified" warning
        "vers=default"
      ];
    };
  };

  # initrd already unlocked /, the stage 2 copy only hits EBUSY on the mounted device.
  # The module's `bcachefs unlock -c` ExecCondition doesn't catch it. No nixpkgs issue
  # found (2026-10-26); to test, drop this, reboot, `systemctl status unlock-bcachefs--`.
  systemd.services."unlock-bcachefs--".enable = false;

  swapDevices = [
    { device = "/dev/disk/by-uuid/b89e6dab-ac87-4ec9-8be6-5aad9d8d5ffd"; }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
