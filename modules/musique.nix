# MUSIQUE : DAW, synthés, plugins et réglages audio basse latence.
# À importer dans la configuration.nix de chaque machine qui sert à la musique.
#
# Les plugins installés ici sont rangés dans /run/current-system/sw/lib/ :
#   vst3/  clap/  lv2/  vst/
# À indiquer une fois dans Reaper : Préférences → Plug-ins → VST / CLAP / LV2.
{ pkgs, ... }:

let
  # Wine dédié aux plugins Windows (Kilohearts…), dans son propre préfixe
  # ~/.wine-audio, avec EXACTEMENT la version de Wine qu'utilise yabridge.
  #   wine-audio Installeur.exe   → installe un plugin Windows
  wineAudio = pkgs.writeShellScriptBin "wine-audio" ''
    export WINEPREFIX="$HOME/.wine-audio"
    exec ${pkgs.wineWow64Packages.yabridge}/bin/wine "$@"
  '';
in
{
  # ─── Son : PipeWire en mode « studio » ─────────────────────────────────
  # JACK via PipeWire : Reaper, Cardinal et VCV Rack peuvent parler JACK,
  # tout en gardant le son du bureau (Firefox, Discord…) en même temps.
  services.pipewire.jack.enable = true;

  # Latence basse : 256 échantillons à 48 kHz ≈ 5 ms.
  # Si ça craque (xruns), monte à 512. Pour enregistrer une guitare, descends à 128.
  services.pipewire.extraConfig.pipewire."92-latence-basse" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [
        44100
        48000
        96000
      ];
      "default.clock.quantum" = 256;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 1024;
    };
  };

  # Priorité temps réel pour l'audio (évite les craquements quand le PC travaille).
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
  ];
  # FONTS
  fonts.packages = with pkgs; [
    roboto
    fira-sans
  ];
  # ─── Logiciels ─────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    reaper # le DAW
    audacity # édition audio rapide
    vital # synthé wavetable (VST3 / CLAP + appli autonome)
    vcv-rack # le rack modulaire, en appli autonome
    cardinal # VCV Rack en PLUGIN (VST3 / CLAP / LV2) pour charger tes patchs dans Reaper
    airwin2rack # Airwindows Consolidated : ~500 effets dans un seul plugin
    lsp-plugins # EQ, compresseurs, limiteurs… de qualité studio
    qpwgraph # brancher les entrées / sorties audio à la souris

    # Plugins Windows dans Reaper (Kilohearts Essentials…) via yabridge
    yabridge
    yabridgectl
    wineAudio
  ];
}
