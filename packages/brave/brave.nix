{inputs, ...}: let
  inherit (inputs) wrappers;
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
  c = slot: "#${palette.${slot}}";
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # chromium keeps only the last of each switch, so these repeat the wrapper's own
    enable = [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
      "VaapiOnNvidiaGPUs"
    ];
    disable = [
      "OutdatedBuildDetector"
      "UseChromeOSDirectVideoDecoder"
      # calls leave the mic's input level alone
      "WebRtcAllowInputVolumeAdjustment"
    ];

    # dark reader has no managed storage; these keys go into its own, whole values
    darkReader = (pkgs.formats.json {}).generate "brave-dark-reader.json" {
      # natively dark sites too
      detectDarkTheme = false;

      theme = {
        mode = 1;
        brightness = 100;
        contrast = 100;
        grayscale = 0;
        sepia = 0;
        # over sites' own fonts; it skips code and icon fonts
        useFont = true;
        fontFamily = "Maple Mono NF";
        textStroke = 0;
        engine = "dynamicTheme";
        stylesheet = "";
        # its built-in Catppuccin is mocha
        darkColorScheme = "Catppuccin";
        darkSchemeBackgroundColor = c "base00";
        darkSchemeTextColor = c "base05";
        lightColorScheme = "Default";
        lightSchemeBackgroundColor = "#dcdad7";
        lightSchemeTextColor = "#181a1b";
        scrollbarColor = "";
        # surface2, from catppuccin/dark-reader
        selectionColor = c "base04";
        styleSystemControls = false;
        immediateModify = false;
      };
    };

    # extension storage is leveldb: setting name -> compact json, keys sorted
    pinExtension =
      pkgs.writers.writePython3 "brave-pin-extension" {
        libraries = [pkgs.python3Packages.plyvel];
      } ''
        import json
        import os
        import sys

        import plyvel

        local, sync, pin_file = sys.argv[1:]
        with open(pin_file) as f:
            pin = json.load(f)

        # sync storage unless the extension's sync is off
        store = sync
        if os.path.isdir(local):
            db = plyvel.DB(local)
            if db.get(b"syncSettings") == b"false":
                store = local
            db.close()

        # none yet: the extension hasn't started once
        if os.path.isdir(store):
            db = plyvel.DB(store)
            for key, value in pin.items():
                want = json.dumps(value, separators=(",", ":"), sort_keys=True)
                if db.get(key.encode()) != want.encode():
                    db.put(key.encode(), want.encode())
            db.close()
      '';

    # brave holds the extension's storage open while running, so only pin while it's closed
    enforce = pkgs.writeShellApplication {
      name = "brave-pin-settings";
      text = ''
        dir=''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Origin
        [[ ! -L $dir/SingletonLock ]] || exit 0

        id=eimadpbcbfnmbkopoojfekhnkhdbieeh
        ${pinExtension} "$dir/Default/Local Extension Settings/$id" "$dir/Default/Sync Extension Settings/$id" ${darkReader}
      '';
    };
  in {
    packages.brave = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.brave-origin.override {
          commandLineArgs = "--enable-features=${lib.concatStringsSep "," enable} --disable-features=${lib.concatStringsSep "," disable}";
        };
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}
