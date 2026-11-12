# TERMINAL : foot (partout) ou Ghostty (option rice.terminal), qui lancent fish.
# + starship (prompt), zoxide (`z dossier`), carapace (autocomplétion).
# Couleurs et police : Stylix.
{ osConfig, pkgs, ... }:

{
  programs.ghostty = {
    enable = osConfig.rice.terminal == "ghostty"; # demande OpenGL 3.3
    settings = {
      command = "${pkgs.fish}/bin/fish";
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
    };
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
