{
  flake.nixosModules.wniri-rules = let
    # proton, gamescope, eden, minecraft
    games = [
      {app-id = "^steam_app_\\d+$";}
      {app-id = "^gamescope$";}
      {app-id = "eden_emu|^eden$";}
      {app-id = "^Minecraft";}
    ];

    # mpv, the shim's player, freetube
    players = [
      {app-id = "^mpv$";}
      {app-id = "(?i)jellyfin-mpv-shim$";}
      {app-id = "(?i)freetube";}
    ];
  in {
    settings.window-rules = [
      # big picture never asks for fullscreen through xwayland-satellite
      {
        matches = [
          {
            app-id = "^steam$";
            title = "^Steam Big Picture Mode$";
          }
        ];
        open-fullscreen = true;
      }

      # friends, chats, settings, properties: over a fullscreen game, not a column scrolling it away
      {
        matches = [{app-id = "^steam$";}];
        excludes = [
          {title = "^Steam$";}
          {title = "^Steam Big Picture Mode$";}
        ];
        open-floating = true;
      }

      # toasts: bottom-right corner, focus stays put
      {
        matches = [
          {
            app-id = "^steam$";
            title = "^notificationtoasts_\\d+_desktop$";
          }
        ];
        default-floating-position = _: {
          props = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
        };
        open-focused = false;
      }

      # undertale: fullscreen letterboxes 640x480 at an exact 3x; a maximised column scales it unevenly
      {
        matches = [
          {app-id = "^steam_app_391540$";}
          {title = "^UNDERTALE$";}
        ];
        open-fullscreen = true;
      }

      {
        matches = games;
        # on outputs set to on-demand vrr in Dux's display settings
        variable-refresh-rate = true;
      }

      # wezterm's translucent background
      {
        matches = [
          {app-id = "^org\\.wezfurlong\\.wezterm$";}
          {app-id = "^btop$";}
        ];
        background-effect.blur = true;
      }

      # not is-focused: a launcher or which-key taking focus would fade everything
      {
        matches = [{is-active = false;}];
        excludes = games ++ players;
        opacity = 0.85;
        background-effect.blur = true;
      }

      # menus and popovers; 15 is libadwaita's popup radius
      {
        matches = [
          {app-id = "^org\\.gnome\\.Nautilus$";}
          {app-id = "^org\\.gnome\\.Papers$";}
        ];
        popups = {
          geometry-corner-radius = 15;
          opacity = 0.85;
          background-effect.blur = true;
        };
      }
    ];

    settings.layer-rules = [
      {
        matches = [{namespace = "^wlr_which_key$";}];
        shadow.on = _: {};
        geometry-corner-radius = 12;
        background-effect.blur = true;
      }

      {
        matches = [{namespace = "^nirimap$";}];
        background-effect.blur = true;
      }

      # live halves capture the screen under shatterlock, not shatterlock itself
      {
        matches = [{namespace = "^shatterlock$";}];
        hide-from-own-capture = true;
      }
    ];
  };
}
