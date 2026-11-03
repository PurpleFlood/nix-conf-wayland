# WAYBAR : la barre. Lancée automatiquement avec la session (systemd).
# Couleurs : Stylix. Les clics ouvrent les outils en terminal (Ghostty).
{ ... }:

let
  tui = cmd: "ghostty -e ${cmd}"; # ouvre un outil en terminal
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.barre = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 8;

      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "wireplumber"
        "bluetooth"
        "network"
        "power-profiles-daemon"
        "battery"
        "custom/extinction"
      ];

      "niri/window".max-length = 50;

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A %d %B}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = [ "󰕿" "󰖀" "󰕾" ];
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
        format-icons = [ "󰂎" "󰁻" "󰁽" "󰁿" "󰂁" "󰁹" ];
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
  };
}
