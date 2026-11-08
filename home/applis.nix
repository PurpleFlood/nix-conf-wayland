# APPLIS communes à toutes les machines.
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

# Mumble forcé en mode X11 (XWayland) : le push-to-talk fonctionne quand
# la fenêtre active est une appli X11, donc dans les jeux Steam/Proton.
let
  mumble = pkgs.symlinkJoin {
    name = "mumble";
    paths = [ pkgs.mumble ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/mumble --set QT_QPA_PLATFORM xcb";
  };

  # Bitwig 4.4 extrait dans ~/bitwig-studio-4.4, lancé dans un environnement
  # Linux classique (steam-run) avec les bibliothèques qui lui manquent.
  bitwig = pkgs.writeShellScriptBin "bitwig" ''
    export LD_LIBRARY_PATH=${
      lib.makeLibraryPath (
        with pkgs;
        [
          libxcb-wm
          libxcb-util
          libbsd
          xorg.libxkbfile
          xorg.libXtst
          xorg.libXcursor
          libxkbcommon
        ]
      )
    }:${pkgs.pipewire.jack}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.steam-run}/bin/steam-run "$HOME/Soft/bitwig-studio/bitwig-studio" "$@"
  '';

in

{
  # ─── Outils du rice ────────────────────────────────────────────────────
  programs.yazi.enable = true; # fichiers en terminal (Thunar côté système)

  # Annotation des captures : copie directe dans le presse-papiers.
  programs.satty = {
    enable = true;
    settings.general = {
      copy-command = "wl-copy";
      early-exit = true; # se ferme après la copie
      output-filename = "~/Images/Captures/annotee-%Y-%m-%d_%H-%M-%S.png";
    };
  };

  programs.zathura.enable = true; # PDF
  programs.mpv.enable = true; # vidéo
  programs.obs-studio.enable = true; # enregistrement / streaming

  # GitHub en ligne de commande + identifiants pour git push.
  # Une seule fois par machine : `gh auth login`.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  home.packages = with pkgs; [
    # ─── Bureau Wayland ──────────────────────────────────────────────────
    imv # images
    vlc
    wiremix # mixeur PipeWire en terminal
    bluetui # Bluetooth en terminal
    playerctl # touches lecture / pause / suivant
    brightnessctl # luminosité
    grim # capture d'une zone…
    slurp # …sélectionnée à la souris
    wl-clipboard # wl-copy / wl-paste
    libnotify # notify-send

    # ─── Terminal / CLI ──────────────────────────────────────────────────
    bat
    eza
    fzf
    btop
    htop
    fastfetch
    glow
    jq
    _7zz
    xz
    zstd
    unzip
    newsboat
    yt-dlp
    ansible
    pkgs-unstable.ani-cli # suit les changements des sites
    sshfs
    openssl

    # --- compatibilité
    bottles

    # Twitch
    wtwitch
    twitch-tui
    twitch-dl
    streamlink
    ffmpeg

    # ─── Applis ──────────────────────────────────────────────────────────
    file-roller
    keepassxc
    qbittorrent
    pidgin
    mumble
    discord
    spotify
    spotify-player
    obsidian
    blender
    krita
    libreoffice
    nextcloud-client
    filezilla

    # ─── Dev ─────────────────────────────────────────────────────────────
    # (gcc et nodejs sont dans home/neovim.nix)
    cmake
    gnumake
    pkg-config
    rustc
    cargo
    jdk21
    dotnet-sdk
    ghidra
    podman-compose
    claude-code
    opencode
    bitwig
  ];

  xdg.desktopEntries.bitwig = {
    name = "Bitwig Studio";
    exec = "bitwig";
    icon = "audio-x-generic";
    categories = [
      "Audio"
      "AudioVideo"
    ];
  };
}
