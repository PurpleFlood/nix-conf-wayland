# PETITS SERVICES lancés avec la session (systemd) :
# fond d'écran, presse-papiers, affichage volume/luminosité, lumière bleue,
# fenêtres d'authentification, montage automatique des clés USB.
#
# Avec Noctalia (rice.shell = "noctalia"), fond d'écran, jauge et lumière bleue
# sont gérés par Noctalia : awww, swayosd et wlsunset sont coupés.
{ osConfig, ... }:

let
  classic = osConfig.rice.shell == "classic";
in
{
  services.awww.enable = classic; # démon de fond d'écran (image posée par niri)

  services.cliphist.enable = true; # historique du presse-papiers (texte + images)

  services.swayosd.enable = classic; # jauge à l'écran pour le volume et la luminosité

  services.wlsunset = {
    enable = classic; # lumière plus chaude le soir
    latitude = 48.8;
    longitude = 2.3;
    temperature = {
      day = 6500;
      night = 3800;
    };
  };

  services.polkit-gnome.enable = true; # fenêtres « mot de passe requis »

  services.udiskie = {
    enable = true; # monte les clés USB automatiquement
    tray = "auto";
  };
}
