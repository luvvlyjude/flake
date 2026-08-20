{
  config,
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [
    # disable module for unused 2070 SUPER GPU USB-C controller
    "ucsi_ccg"
  ];

  boot.kernelParams = [
    # dont touch BIOS configured ASPM value
    "pcie_aspm=off"
  ];

  # override bcachefs package with latest snapshot release
  boot.bcachefs.package =
    inputs.bcachefs-tools.packages.${pkgs.stdenv.hostPlatform.system}.bcachefs-tools;

  fileSystems."/" = {
    device = "UUID=70fdf5d5-4f7c-4def-b8eb-6df5f6da441d";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1926-4056";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/mnt/bcachefs" = {
    device = "UUID=5f1e18d9-c665-4e62-9121-e482106c25cc";
    fsType = "bcachefs";
  };

  fileSystems."/mnt/readyshare" = {
    device = "//192.168.1.1/USB_Storage";
    fsType = "cifs";
    options = [
      "guest"
      "uid=1000"
      "gid=100"
      "_netdev"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/b89e6dab-ac87-4ec9-8be6-5aad9d8d5ffd"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
