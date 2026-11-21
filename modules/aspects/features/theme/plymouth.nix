{
  den.aspects.plymouth.nixos = {self', ...}: {
    boot.plymouth = {
      enable = true;
      theme = "snowflake";
      themePackages = [self'.packages.plymouth-snowflake];
      # the initrd's only font, for the hint and password dots
      font = "${self'.packages.maple-mono-nf}/share/fonts/truetype/MapleMono-NF-Regular.ttf";
    };

    # its port also sets boot.plymouth.theme
    catppuccin.plymouth.enable = false;

    # no kernel or udev text over the splash
    boot.consoleLogLevel = 3;
    boot.kernelParams = ["quiet" "udev.log_level=3" "rd.udev.log_level=3"];
  };
}
