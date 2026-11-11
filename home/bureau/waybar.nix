# WAYBAR : la barre. Lancée automatiquement avec la session (systemd).
# Couleurs : Stylix. Les clics ouvrent les outils en terminal (Ghostty).
{
  lib,
  pkgs,
  host,
  ...
}:

let

  terminal = if host == "r400" then "foot" else "ghostty";

  tui = cmd: terminal "-e ${cmd}"; # ouvre un outil en terminal

  # État du VPN Mullvad (bouton masqué si aucun pays n'est configuré).
  vpnEtat = pkgs.writeShellScriptBin "vpn-etat" ''
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
    ${builtins.readFile ./scripts/vpn-etat.sh}
  '';

in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.barre = {
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
        "custom/vpn"
        "power-profiles-daemon"
        "battery"
        "custom/extinction"
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
        exec = "${vpnEtat}/bin/vpn-etat";
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

      "custom/extinction" = {
        format = "⏻";
        tooltip = false;
        on-click = "menu-extinction";
      };
    };
    style = ''
          	window#waybar {
      	  border-radius: 12px;
      	}
      	tooltip {
      	  border-radius: 10px;
      	}
      	.modules-right {
      	  margin-right: 16px;
      	}
      	#custom-extinction {
      	  padding: 0 10px 0 6px;
      	}
      	      /* Boutons : coins arrondis et transition douce */
              #workspaces button, #clock, #wireplumber, #bluetooth, #network,
              #power-profiles-daemon, #battery, #custom-extinction, #custom-vpn.actif {
                border-radius: 8px;
                transition: background-color 0.2s ease, color 0.2s ease;
              }
              /* Survol : léger fond aux couleurs de la palette */
              #workspaces button:hover, #clock:hover, #wireplumber:hover,
              #bluetooth:hover, #network:hover, #power-profiles-daemon:hover,
              #battery:hover, #custom-vpn.actif:hover {
                background-color: alpha(@base0E, 0.25);
              }
              /* Le bouton d'extinction vire au rouge au survol */
              #custom-extinction:hover {
                background-color: alpha(@base08, 0.25);
                color: @base08;
              }
      	'';
  };
}
