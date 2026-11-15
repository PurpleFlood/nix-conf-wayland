# WAYBAR : la barre. Lancée automatiquement avec la session (systemd).
# Couleurs : suivent le fond d'écran (matugen, voir theming.nix) ; le style est
# le modèle `rice.colorTemplates.waybar` en bas du fichier.
# Les clics ouvrent les outils dans le terminal du rice.
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  tui = cmd: "${osConfig.rice.terminalExec} ${cmd}"; # ouvre un outil en terminal

  # État du VPN Mullvad (bouton masqué si aucun pays n'est configuré).
  vpnStatus = pkgs.writeShellScriptBin "vpn-status" ''
    export PATH=${
      lib.makeBinPath (
        with pkgs;
        [
          curl
          jq
          iproute2
          gawk
          coreutils
        ]
      )
    }:/run/wrappers/bin:$PATH
    ${builtins.readFile ./scripts/vpn-status.sh}
  '';

in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 30;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;
      spacing = 8;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "wireplumber"
        "bluetooth"
        "network"
      ]
      # Bouton VPN seulement si le module vpn est actif.
      ++ lib.optional osConfig.rice.vpn.enable "custom/vpn"
      ++ [
        "power-profiles-daemon"
        "battery"
        "custom/power"
      ];

      # Numéro du bureau sur son écran (1, 2, 3…) plutôt que son nom (6, 7, 8)
      "niri/workspaces".format = "{index}";

      "niri/window".max-length = 50;

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A %d %B}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        on-click = tui "wiremix";
      };

      bluetooth = {
        format = "󰂯";
        format-connected = "󰂱 {device_alias}";
        format-disabled = "󰂲";
        on-click = tui "bluetui";
      };

      network = {
        format-wifi = "󰖩 {essid}";
        format-ethernet = "󰈀";
        format-disconnected = "󰖪";
        tooltip-format = "{ipaddr} — {signalStrength}%";
        on-click = tui "nmtui";
      };

      "custom/vpn" = {
        exec = "${vpnStatus}/bin/vpn-status";
        return-type = "json";
        interval = 15;
        signal = 8; # rafraîchi tout de suite par vpn-menu
        on-click = "vpn-menu";
      };

      power-profiles-daemon = {
        format = "{icon}";
        format-icons = {
          power-saver = "󰌪";
          balanced = "󰗑";
          performance = "󰓅";
        };
      };

      battery = {
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons = [
          "󰂎"
          "󰁻"
          "󰁽"
          "󰁿"
          "󰂁"
          "󰁹"
        ];
        states = {
          warning = 25;
          critical = 10;
        };
      };

      "custom/power" = {
        format = "⏻";
        tooltip = false;
        on-click = "power-menu";
      };
    };
  };

  # Stylix ne touche plus à la barre : couleurs ET style viennent du modèle.
  stylix.targets.waybar.enable = false;

  # Style de la barre, rempli par matugen → ~/.config/waybar/style.css
  rice.colorTemplates.waybar = {
    target = "waybar/style.css";
    reload = "${pkgs.systemd}/bin/systemctl --user reload waybar.service";
    text = ''
      /* Généré par matugen (modèle dans home/desktop/waybar.nix) : ne pas modifier ici. */
      @define-color bg {{colors.surface.default.hex}};
      @define-color fg {{colors.on_surface.default.hex}};
      @define-color muted {{colors.on_surface_variant.default.hex}};
      @define-color accent {{colors.primary.default.hex}};
      @define-color accent-alt {{colors.tertiary.default.hex}};
      @define-color urgent {{colors.error.default.hex}};

      * {
        font-family: "${config.stylix.fonts.monospace.name}";
        font-size: ${toString config.stylix.fonts.sizes.desktop}pt;
      }

      window#waybar {
        background: alpha(@bg, ${toString config.stylix.opacity.desktop});
        color: @fg;
        border-radius: 12px;
      }

      tooltip {
        background: @bg;
        border: 1px solid @accent;
        border-radius: 10px;
      }
      tooltip label {
        color: @fg;
      }

      .modules-right {
        margin-right: 16px;
      }

      /* Bureaux : soulignés quand ils sont actifs */
      #workspaces button {
        color: @muted;
        border-bottom: 3px solid transparent;
        padding: 0 5px;
      }
      #workspaces button.focused,
      #workspaces button.active {
        color: @fg;
        border-bottom: 3px solid @accent;
      }
      #workspaces button.urgent {
        background-color: @urgent;
        color: @bg;
      }

      #window, #clock, #wireplumber, #bluetooth, #network,
      #power-profiles-daemon, #battery, #custom-vpn {
        padding: 0 5px;
      }
      #wireplumber.muted,
      #network.disconnected {
        color: @muted;
      }
      #battery.warning {
        color: @accent-alt;
      }
      #battery.critical {
        color: @urgent;
      }
      #custom-vpn.active {
        color: @accent;
      }
      #custom-power {
        padding: 0 10px 0 6px;
      }

      /* Boutons : coins arrondis et transition douce */
      #workspaces button, #clock, #wireplumber, #bluetooth, #network,
      #power-profiles-daemon, #battery, #custom-power, #custom-vpn.active {
        border-radius: 8px;
        transition: background-color 0.2s ease, color 0.2s ease;
      }
      /* Survol : léger fond aux couleurs de la palette */
      #workspaces button:hover, #clock:hover, #wireplumber:hover,
      #bluetooth:hover, #network:hover, #power-profiles-daemon:hover,
      #battery:hover, #custom-vpn.active:hover {
        background-color: alpha(@accent, 0.20);
      }
      /* Le bouton d'extinction vire au rouge au survol */
      #custom-power:hover {
        background-color: alpha(@urgent, 0.25);
        color: @urgent;
      }
    '';
  };
}
