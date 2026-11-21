{inputs, ...}: {
  # catppuccin mocha/mauve
  flake.nixosModules.wyazi-theme = {
    lib,
    pkgs,
    ...
  }: let
    sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system};
    flavor = lib.importTOML "${inputs.catppuccin-yazi}/themes/mocha/catppuccin-mocha-mauve.toml";
  in {
    settings.theme =
      flavor
      // {
        # no bg, so wezterm's translucent one shows through
        app = flavor.app // {overall = {};};
        # the flavor expects its tmTheme in ~/.config/yazi; use the store's
        mgr = flavor.mgr // {syntect_theme = "${sources.bat}/Catppuccin Mocha.tmTheme";};
        # generic rules only; files and exts recolour every file icon
        icon = {inherit (flavor.icon) conds dirs;};
      };
  };
}
