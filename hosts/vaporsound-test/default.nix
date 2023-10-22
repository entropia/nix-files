{ pkgs, ... }: {

  imports = [
    ../../profiles/raspberry_pi/4.nix
  ];

  config = {
    networking.hostName = "vaporsound-test";

    deployment.targetHost = "10.214.227.9";

    system.stateVersion = "23.05";

    networking.useNetworkd = true;
    systemd.network.wait-online.anyInterface = true;

    systemd.network.networks."10-lan" = {
      enable = true;
      name = "en*";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
        DNSOverTLS = "opportunistic";
        IPv6AcceptRA = "yes";
        IPv6PrivacyExtensions = "yes";
      };
    };

    services.avahi = {
      enable = true;
      publish.enable = true;
    };

    services.resolved.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    hardware.deviceTree.enable = true;
    hardware.deviceTree.overlays = [
      {
        name = "iqaudio-dacplus-overlay";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "brcm,bcm2711";

            fragment@0 {
              target = <&i2s>;
              __overlay__ {
                status = "okay";
              };
            };

            fragment@1 {
              target = <&i2c1>;
              __overlay__ {
                #address-cells = <1>;
                #size-cells = <0>;
                status = "okay";

                pcm5122@4c {
                  #sound-dai-cells = <0>;
                  compatible = "ti,pcm5122";
                  reg = <0x4c>;
                  AVDD-supply = <&vdd_3v3_reg>;
                  DVDD-supply = <&vdd_3v3_reg>;
                  CPVDD-supply = <&vdd_3v3_reg>;
                  status = "okay";
                };
              };
            };

            fragment@2 {
              target = <&sound>;
              iqaudio_dac: __overlay__ {
                compatible = "iqaudio,iqaudio-dac";
                i2s-controller = <&i2s>;
                mute-gpios = <&gpio 22 0>;
                status = "okay";
                iqaudio-dac,auto-mute-amp;
              };
            };
          };
        '';
      }
    ];

    environment.systemPackages = with pkgs; [
      pulseaudio-ctl
      alsa-utils
    ];
  };
}
