{
  imports = [
    ./common.nix
  ];

  config = {
    boot = {
      kernelParams = [
        "dwc_otg.lpm_enable=0"
        "cma=320M"
        "plymouth.ignore-serial-consoles"
      ];
      initrd = {
        includeDefaultModules = false;
        kernelModules = [ "vc4" ];
        availableKernelModules =
          [ "usbhid" "usb_storage" "vc4" "bcm2835_dma" "i2c_bcm2835" ];
      };
    };
  };
}
