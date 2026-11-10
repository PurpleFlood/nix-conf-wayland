# TERMINAL : Ghostty, qui lance Nushell.
# + starship (prompt), zoxide (`z dossier`), carapace (autocomplétion).
# Couleurs et police : Stylix.
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
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
