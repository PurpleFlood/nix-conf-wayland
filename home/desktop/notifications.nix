# MAKO : notifications. Couleurs : suivent le fond d'écran (matugen, voir
# theming.nix). Toute la config est le modèle ci-dessous, écrit par matugen dans
# ~/.config/mako/config (home-manager ne gère plus ce fichier).
{ config, ... }:

{
  services.mako.enable = true;

  # Stylix ne touche plus aux notifications : tout vient du modèle.
  stylix.targets.mako.enable = false;

  rice.colorTemplates.mako = {
    target = "mako/config";
    reload = "${config.services.mako.package}/bin/makoctl reload";
    text = ''
      # Généré par matugen (modèle dans home/desktop/notifications.nix) : ne pas modifier ici.
      font=${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.popups}
      default-timeout=5000
      border-radius=10
      border-size=2
      padding=12
      margin=12
      anchor=top-right
      max-visible=5

      background-color={{colors.surface.default.hex}}e6
      text-color={{colors.on_surface.default.hex}}
      border-color={{colors.primary.default.hex}}
      progress-color=over {{colors.primary_container.default.hex}}

      [urgency=low]
      border-color={{colors.outline.default.hex}}

      [urgency=critical]
      border-color={{colors.error.default.hex}}
    '';
  };
}
