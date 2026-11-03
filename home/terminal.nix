# TERMINAL : Ghostty, qui lance Nushell.
# + starship (prompt), zoxide (`z dossier`), carapace (autocomplétion).
# Couleurs et police : Stylix.
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      command = "${pkgs.nushell}/bin/nu";
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
    };
  };

  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.carapace.enable = true;
}
