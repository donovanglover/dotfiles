{ lib, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/63546625-e99c-4aa4-ba11-ff193ad13047";
      fsType = "ext4";
    };
  };

  boot.initrd.luks.devices = {
    "LUKS-MOBILE-NIXOS-ROOTFS" = {
      device = "/dev/disk/by-uuid/28e0bd73-e4fb-4002-9b17-a494823e6999";
    };
  };

  nix.settings.max-jobs = lib.mkDefault 2;
}
