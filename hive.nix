{ inputs, overlay }:
{
  meta = {
    nixpkgs = import inputs.nixpkgs {
      overlays = [ overlay ];
      system = "x86_64-linux";
    };
  };

  "test" = { ... }: {
    fileSystems."/".device = "/dev/disk/by-label/test";
    fileSystems."/".fsType = "ext4";
    system.stateVersion = "25.11";
    boot.loader.grub.devices = [ "/test" ];
  };
}
