# TERMINAL : foot (partout) ou Ghostty (option rice.terminal), qui lancent fish.
# + starship (prompt), zoxide (`z dossier`), carapace (autocomplétion).
# Police : Stylix. Couleurs : suivent le fond d'écran (matugen, voir theming.nix),
# via un fichier inclus ; modèles en bas du fichier.
{
  config,
  osConfig,
  pkgs,
  ...
}:

let
  # Rôles matugen → 16 couleurs du terminal (format sans « # » pour foot).
  ansi = fmt: {
    "0" = "{{colors.surface_container_highest.default.${fmt}}}";
    "1" = "{{colors.red.default.${fmt}}}";
    "2" = "{{colors.green.default.${fmt}}}";
    "3" = "{{colors.yellow.default.${fmt}}}";
    "4" = "{{colors.blue.default.${fmt}}}";
    "5" = "{{colors.magenta.default.${fmt}}}";
    "6" = "{{colors.cyan.default.${fmt}}}";
    "7" = "{{colors.on_surface_variant.default.${fmt}}}";
    "8" = "{{colors.outline.default.${fmt}}}";
    "9" = "{{colors.on_red_container.default.${fmt}}}";
    "10" = "{{colors.on_green_container.default.${fmt}}}";
    "11" = "{{colors.on_yellow_container.default.${fmt}}}";
    "12" = "{{colors.on_blue_container.default.${fmt}}}";
    "13" = "{{colors.on_magenta_container.default.${fmt}}}";
    "14" = "{{colors.on_cyan_container.default.${fmt}}}";
    "15" = "{{colors.on_surface.default.${fmt}}}";
  };
  footAnsi = ansi "hex_stripped";
  ghosttyAnsi = ansi "hex";
in

{
  programs.ghostty = {
    enable = osConfig.rice.terminal == "ghostty"; # demande OpenGL 3.3
    settings = {
      command = "${pkgs.fish}/bin/fish";
      # Couleurs générées par matugen (« ? » : pas d'erreur si absent)
      config-file = "?${config.xdg.configHome}/ghostty/colors";
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
    };
  };

  programs.foot = {
    enable = osConfig.rice.terminal == "foot"; # rendu par le processeur : marche partout
    settings.main = {
      shell = "${pkgs.fish}/bin/fish";
      pad = "10x10";
      initial-color-theme = "dark";
      include = "${config.xdg.configHome}/foot/colors.ini"; # généré par matugen
    };
  };

  # Stylix garde la police (et l'opacité de Ghostty), les couleurs viennent de matugen.
  stylix.targets.foot.colors.enable = false;
  stylix.targets.ghostty.colors.enable = false;

  # foot relit ses couleurs à chaque nouvelle fenêtre.
  rice.colorTemplates.foot = {
    target = "foot/colors.ini";
    text = ''
      # Généré par matugen (modèle dans home/terminal.nix) : ne pas modifier ici.
      [colors-dark]
      alpha=${toString config.stylix.opacity.terminal}
      foreground={{colors.on_surface.default.hex_stripped}}
      background={{colors.surface.default.hex_stripped}}
      selection-foreground={{colors.on_primary_container.default.hex_stripped}}
      selection-background={{colors.primary_container.default.hex_stripped}}
      regular0=${footAnsi."0"}
      regular1=${footAnsi."1"}
      regular2=${footAnsi."2"}
      regular3=${footAnsi."3"}
      regular4=${footAnsi."4"}
      regular5=${footAnsi."5"}
      regular6=${footAnsi."6"}
      regular7=${footAnsi."7"}
      bright0=${footAnsi."8"}
      bright1=${footAnsi."9"}
      bright2=${footAnsi."10"}
      bright3=${footAnsi."11"}
      bright4=${footAnsi."12"}
      bright5=${footAnsi."13"}
      bright6=${footAnsi."14"}
      bright7=${footAnsi."15"}
    '';
  };

  # Ghostty : Ctrl+Maj+, dans une fenêtre pour appliquer les nouvelles couleurs
  # à toutes les fenêtres ouvertes. Pas de rechargement automatique : le signal
  # de rechargement peut fermer toutes les fenêtres de Ghostty.
  rice.colorTemplates.ghostty = {
    target = "ghostty/colors";
    text = ''
      # Généré par matugen (modèle dans home/terminal.nix) : ne pas modifier ici.
      background = {{colors.surface.default.hex}}
      foreground = {{colors.on_surface.default.hex}}
      cursor-color = {{colors.primary.default.hex}}
      selection-background = {{colors.primary_container.default.hex}}
      selection-foreground = {{colors.on_primary_container.default.hex}}
      ${builtins.concatStringsSep "\n" (map (i: "palette = ${i}=${ghosttyAnsi.${i}}") (map toString (builtins.genList (x: x) 16)))}
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting          # pas de message d'accueil
      fish_vi_key_bindings       # mode vi, comme ton réglage Nushell
    '';
  };
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.carapace.enable = true;
}
