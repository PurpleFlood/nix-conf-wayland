# PROFIL SIMPLE : un bureau classique, « comme sur Windows », pour quelqu'un
# qui débute sous Linux. Barre des tâches, menu Démarrer, réglages en fenêtres,
# Firefox normal (aucun de tes réglages), bureautique, impression.
# Le système se met à jour tout seul depuis ton dépôt GitHub.
#
#   rice.profile = "simple";
#   rice.user = "marie";             # son compte (sans sudo)
#   rice.simple.desktop = "cinnamon";
{
  config,
  lib,
  pkgs,
  private,
  ...
}:

let
  cfg = config.rice.simple;
  enabled = config.rice.profile == "simple";
in
{
  options.rice.simple = {
    desktop = lib.mkOption {
      type = lib.types.enum [
        "cinnamon"
        "plasma"
        "xfce"
      ];
      default = "cinnamon";
      description = ''
        - "cinnamon" : proche de Windows, simple, assez léger (conseillé) ;
        - "plasma"   : KDE, le plus complet, mais le plus lourd ;
        - "xfce"     : le plus léger, pour les vieilles machines avec peu de RAM.
      '';
    };

    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Mise à jour automatique chaque nuit depuis ton dépôt GitHub (private.repository) : tu fais
        `git push` chez toi, la machine suit. Appliquée au redémarrage suivant.
      '';
    };
  };

  config = lib.mkIf enabled (
    lib.mkMerge [
      # ─── Commun aux trois bureaux ───────────────────────────────────────
      {
        services.xserver = {
          enable = true;
          xkb.layout = config.rice.keyboard;
        };

        # Impression et numérisation (la plupart des imprimantes marchent seules)
        services.printing.enable = true;
        hardware.sane.enable = true;

        # Applis installables sans toucher à Nix (boutique graphique)
        services.flatpak.enable = true;

        # Firefox normal, sans tes réglages
        programs.firefox = {
          enable = true;
          languagePacks = [ "fr" ];
        };

        environment.systemPackages = with pkgs; [
          libreoffice
          hunspellDicts.fr-any # correcteur orthographique français
          vlc
        ];

        # Le compte admin (toi) n'apparaît pas sur l'écran de connexion.
        systemd.tmpfiles.rules = [
          "f+ /var/lib/AccountsService/users/${config.rice.admin} 0600 root root - [User]\\nSystemAccount=true\\n"
        ];

        # home-manager pour la personne (utilisé seulement si un module y ajoute quelque chose)
        home-manager.users.${config.rice.user}.home.stateVersion = "26.05";

        # Mises à jour automatiques depuis ton dépôt
        system.autoUpgrade = lib.mkIf cfg.autoUpgrade {
          enable = true;
          flake = "${private.repository}#${config.networking.hostName}"; # ton dépôt (dépôt privé)
          operation = "boot"; # appliquée au prochain démarrage, jamais en pleine session
          dates = "03:30";
          randomizedDelaySec = "45min";
          persistent = true; # rattrape la mise à jour si le PC était éteint
        };
      }

      # ─── Cinnamon ──────────────────────────────────────────────────────
      (lib.mkIf (cfg.desktop == "cinnamon") {
        services.xserver.desktopManager.cinnamon.enable = true;
        services.xserver.displayManager.lightdm.enable = true;
        environment.systemPackages = [ pkgs.gnome-software ]; # boutique (Flatpak)
      })

      # ─── KDE Plasma ────────────────────────────────────────────────────
      (lib.mkIf (cfg.desktop == "plasma") {
        services.desktopManager.plasma6.enable = true;
        services.displayManager.sddm = {
          enable = true;
          wayland.enable = true;
        };
        environment.systemPackages = [ pkgs.kdePackages.discover ]; # boutique (Flatpak)
      })

      # ─── XFCE ──────────────────────────────────────────────────────────
      (lib.mkIf (cfg.desktop == "xfce") {
        services.xserver.desktopManager.xfce.enable = true;
        services.xserver.displayManager.lightdm.enable = true;
        environment.systemPackages = [ pkgs.gnome-software ]; # boutique (Flatpak)
      })
    ]
  );
}
