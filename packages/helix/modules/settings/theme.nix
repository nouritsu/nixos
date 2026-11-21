{
  flake.nixosModules.whelix-settings-theme = {...}: {
    settings.theme = "catppuccin_mocha_transparent";

    # wezterm's translucent background shows through
    themes.catppuccin_mocha_transparent = {
      inherits = "catppuccin_mocha";
      "ui.background" = {};
    };
  };
}
