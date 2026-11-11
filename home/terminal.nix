# TERMINAL : Ghostty, qui lance Nushell.
# + starship (prompt), zoxide (`z dossier`), carapace (autocomplétion).
# Couleurs et police : Stylix.
{ pkgs, host, ... }:

{
  programs.ghostty = {
    enable = host != "r400";
    settings = {
      command = "${pkgs.fish}/bin/fish";
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
    };
  };

  programs.foot = {
    enable = host == "r400";
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
