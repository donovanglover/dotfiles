{ config, lib, pkgs, ... }:

let
  inherit (lib) singleton;

  inherit (config.lib.stylix.colors.withHashtag)
    base00
    base02
    base03
    base05
    ;

  barScript = "dwm/bar.fish";
in
{
  home-manager.sharedModules = singleton {
    home = {
      packages = with pkgs; [
        feh
        xclip
      ];

      file.".xinitrc" = {
        executable = true;
        text = # bash
          ''
            #!/usr/bin/env sh

            export XDG_SESSION_TYPE=x11
            export GDK_BACKEND=x11
            export XDG_CURRENT_DESKTOP=dwm
            export GTK_IM_MODULE=fcitx
            export QT_IM_MODULE=fcitx
            export XMODIFIERS=@im=fcitx
            export SDL_IM_MODULE=fcitx
            export GLFW_IM_MODULE=ibus
            export GTK_CSD=0

            xrdb -merge ~/.Xresources
            xset r rate 300 50
            feh --no-fehbg --bg-scale ${config.stylix.image}
            ~/.config/${barScript} &
            picom --daemon
            ${pkgs.nemo}/bin/nemo-desktop &
            fcitx5 &

            while true; do
              dbus-launch --sh-syntax --exit-with-session dwm
            done
          '';
      };
    };

    xdg.configFile = {
      ${barScript} = {
        executable = true;
        text = # fish
        ''
          #!/usr/bin/env fish

          function get_icon
            if test "$argv" -gt 90
              echo " "
            else if test "$argv" -gt 60
              echo " "
            else if test "$argv" -gt 30
              echo " "
            else if test "$argv" -gt 10
              echo " "
            else
              echo " "
            end
          end

          function update_bar
            set VOLUME "音量：$(math "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | choose 1) * 100")%"
            set TIME "$(date '+%x（%a）%R')"
            set capacity "$(cat /sys/class/power_supply/BAT0/capacity)"

            set BATTERY "$(get_icon $capacity)$capacity%"

            xsetroot -name " $VOLUME・$BATTERY・$TIME "
          end

          while true
            update_bar

            sleep 10s
          end
        '';
      };
    };

    services = {
      picom = rec {
        enable = true;
        backend = "glx";

        vSync = true;
        fade = true;
        shadow = true;

        fadeDelta = 5;
        shadowOpacity = 0.2;

        fadeExclude = [
          "window_type = 'menu'"
          "window_type = 'dropdown_menu'"
          "window_type = 'popup_menu'"
          "window_type = 'tooltip'"
        ];

        shadowExclude = fadeExclude;

        opacityRules = [
          "95:class_g = 'Thunar'"
        ];

        settings = {
          blur = {
            method = "dual_kawase";
            size = 10;
          };

          blur-background-exclude = [
            "class_g = 'Nemo-desktop'"
          ];

          clip-shadow-above = [
            "class_g = 'dwm'"
          ];
        };
      };

      dunst = {
        enable = true;

        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };

        settings = {
          global = {
            geometry = "1870x5-25+45";
            width = 350;
            separator_height = 5;
            padding = 24;
            horizontal_padding = 24;
            frame_width = 3;
            idle_threshold = 120;
            alignment = "center";
            word_wrap = "yes";
            transparency = 5;
            format = "<b>%s</b>: %b";
            markup = "full";
            min_icon_size = 32;
            max_icon_size = 128;
          };
        };
      };
    };
  };

  services = {
    xserver = {
      displayManager.startx.enable = true;

      windowManager.dwm = {
        enable = true;

        package = pkgs.dwm.override {
          conf = # c
            ''
              #include <X11/XF86keysym.h>

              static const unsigned int borderpx = 0;
              static const unsigned int snap = 32;
              static const int user_bh = 16;
              static const int showbar = 1;
              static const int topbar = 1;
              static const char *fonts[] = {
                "Maple Mono:size=10",
                "Noto Sans Mono CJK JP:size=10",
                "Noto Color Emoji:size=10",
              };

              static const char *colors[][3] = {
                [SchemeNorm] = { "${base03}", "${base00}", "${base02}" },
                [SchemeSel] = { "${base05}", "${base00}", "${base03}" },
              };

              static const unsigned int baralpha = 243;

              static const unsigned int alphas[][3] = {
                [SchemeNorm] = { OPAQUE, baralpha, baralpha },
                [SchemeSel] = { OPAQUE, baralpha, baralpha },
              };

              static const char *tags[] = { "⬤", "⬤", "⬤" };

              static const Rule rules[] = {
                { "librewolf", NULL, NULL, 0, 1, -1 },
              };

              static const float mfact = 0.55;
              static const int nmaster = 1;
              static const int resizehints = 1;
              static const int lockfullscreen = 1;

              static const Layout layouts[] = {
                { "[]=", tile },
              };

              #define MODKEY Mod4Mask

              static char dmenumon[2] = "0";
              static const char *dmenucmd[] = { "rofi", "-show", "drun" };
              static const char *quitcmd[] = { "kill", "xinit" };
              static const char *termcmd[] = { "kitty", NULL };
              static const char *brighter[] = { "brightnessctl", "set", "5%+", NULL };
              static const char *dimmer[] = { "brightnessctl", "set", "5%-", NULL };
              static const char *up_vol[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+", NULL };
              static const char *down_vol[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-", NULL };
              static const char *mute_vol[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };

              static const Key keys[] = {
                { 0, XF86XK_AudioMute, spawn, {.v = mute_vol } },
                { 0, XF86XK_AudioLowerVolume, spawn, {.v = down_vol } },
                { 0, XF86XK_AudioRaiseVolume, spawn, {.v = up_vol } },
                { 0, XF86XK_MonBrightnessDown, spawn, {.v = dimmer } },
                { 0, XF86XK_MonBrightnessUp, spawn, {.v = brighter } },
                { MODKEY, XK_p, spawn, {.v = dmenucmd } },
                { MODKEY, XK_o, togglebar, {0} },
                { MODKEY, XK_f, togglefullscr, {0} },
                { MODKEY, XK_v, togglefloating, {0} },
                { MODKEY, XK_j, focusstack, {.i = +1 } },
                { MODKEY, XK_k, focusstack, {.i = -1 } },
                { MODKEY, XK_Return, zoom, {0} },
                { MODKEY, XK_comma, focusmon, {.i = -1 } },
                { MODKEY, XK_period, focusmon, {.i = +1 } },
                { MODKEY, XK_1, viewprev, {0} },
                { MODKEY, XK_2, viewnext, {0} },
                { MODKEY|ShiftMask, XK_1, tagtoprev, {0} },
                { MODKEY|ShiftMask, XK_1, reorganizetags, {0} },
                { MODKEY|ShiftMask, XK_2, tagtonext, {0} },
                { MODKEY|ShiftMask, XK_2, reorganizetags, {0} },
                { MODKEY|ShiftMask, XK_h, setmfact, {.f = -0.05} },
                { MODKEY|ShiftMask, XK_l, setmfact, {.f = +0.05} },
                { MODKEY|ShiftMask, XK_Return, spawn, {.v = termcmd } },
                { MODKEY|ShiftMask, XK_q, killclient, {0} },
                { MODKEY|ShiftMask, XK_comma, tagmon, {.i = -1 } },
                { MODKEY|ShiftMask, XK_period, tagmon, {.i = +1 } },
                { MODKEY|Mod1Mask, XK_Delete, spawn, {.v = quitcmd } },
              };

              static const Button buttons[] = {
                { ClkTagBar, 0, Button1, view, {0} },
                { ClkClientWin, MODKEY, Button1, movemouse, {0} },
                { ClkClientWin, MODKEY, Button3, resizemouse, {0} },
              };
            '';

          patches = with pkgs; [
            ../assets/dwm-actualfullscreen.patch
            ../assets/dwm-adjacenttag.patch
            ../assets/dwm-remove-layout-indicator.patch
            ../assets/dwm-remove-floating-indicator.patch
            ../assets/dwm-savefloats-alwayscenter.patch

            (fetchpatch {
              url = "https://dwm.suckless.org/patches/hide_vacant_tags/dwm-hide_vacant_tags-6.4.diff";
              hash = "sha256-GIbRW0Inwbp99rsKLfIDGvPwZ3pqihROMBp5vFlHx5Q=";
            })

            (fetchpatch {
              url = "https://dwm.suckless.org/patches/alpha/dwm-alpha-20230401-348f655.diff";
              hash = "sha256-ZhuqyDpY+nQQgrjniQ9DNheUgE9o/MUXKaJYRU3Uyl4=";
            })

            (fetchpatch {
              url = "https://dwm.suckless.org/patches/reorganizetags/dwm-reorganizetags-6.2.diff";
              hash = "sha256-Fj+cfw+5d7i6UrakMbebhZsfmu8ZfooduQA08STovK4=";
            })

            (fetchpatch {
              url = "https://dwm.suckless.org/patches/bar_height/dwm-bar-height-spacing-6.3.diff";
              hash = "sha256-usMIMmloUG4NrX10AVbgr8kFs9ZG6Krn1NxXTVcLq70=";
            })

            (fetchpatch {
              url = "https://raw.githubusercontent.com/bakkeby/patches/c5eae9d/dwm/dwm-desktop_icons-6.5.diff";
              hash = "sha256-oIgeph9pmIWKBepnQhc+aNWU7ZHxsJbhJr5LVNTtuHc=";
            })
          ];
        };
      };

    };

    libinput = {
      touchpad = {
        naturalScrolling = true;
        accelProfile = "flat";
        accelSpeed = "0.75";
      };

      mouse = {
        accelProfile = "flat";
      };
    };
  };
}
