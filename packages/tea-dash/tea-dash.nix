{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: {
    packages.tea-dash = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.tea-dash;
      }
      ({config, ...}: {
        constructFiles.settings = {
          relPath = "tea-dash.yml";
          content = lib.generators.toYAML {} {
            # takes gh-dash themes as they are
            include = ["${inputs'.catppuccin.packages.gh-dash}/mocha/catppuccin-mocha-mauve.yml"];
          };
        };

        flags."--config" = config.constructFiles.settings.path;
      })
    ];
  };
}
