# APPLIS GÉNÉRALISTES : communication, bureautique, création, médias…
# + lancer des applis d'ailleurs (Flatpak, AppImage, Bottles).
#
#   rice.apps.enable = true;
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Mumble forcé en mode X11 (XWayland) : le push-to-talk fonctionne quand
  # la fenêtre active est une appli X11, donc dans les jeux Steam/Proton.
  mumble = pkgs.symlinkJoin {
    name = "mumble";
    paths = [ pkgs.mumble ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/mumble --set QT_QPA_PLATFORM xcb";
  };
in
{
  options.rice.apps.enable = lib.mkEnableOption "les applis généralistes";

  config = lib.mkIf config.rice.apps.enable {
    # ─── Applis d'ailleurs ────────────────────────────────────────────────
    services.flatpak.enable = true;

    # Lancer les AppImage directement (./fichier.AppImage)
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # ─── Côté utilisateur ─────────────────────────────────────────────────
    home-manager.users.asap = {
      programs.obs-studio.enable = true; # enregistrement / streaming

      home.packages = with pkgs; [
        # Communication
        mumble
        discord
        pidgin

        # Bureautique / notes
        libreoffice
        obsidian
        keepassxc
        nextcloud-client

        # Création
        blender
        krita

        # Médias
        vlc
        spotify
        spotify-player
        ffmpeg
        yt-dlp
        newsboat
        pkgs-unstable.ani-cli # suit les changements des sites

        # Twitch
        wtwitch
        twitch-tui
        twitch-dl
        streamlink

        # Fichiers / réseau
        file-roller
        qbittorrent
        filezilla

        # Compatibilité Windows (Wine en interface graphique)
        bottles
      ];
    };
  };
}
