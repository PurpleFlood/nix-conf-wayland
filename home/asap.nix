# TON UTILISATEUR (home-manager) : applis, dotfiles et rice.
# Commun à toutes les machines ; vide pour l'instant, le rice viendra ici.
{ pkgs, ... }:

{
  home.username = "asap";
  home.homeDirectory = "/home/asap";

  programs.git = {
    enable = true;
    settings.user = {
      name = "PurpleFlood";
      email = "flygus.games@gmail.com";
    };
  };

  programs.bash.enable = true;

  home.packages = with pkgs; [
    fastfetch
    bat
    eza
    fzf
  ];

  home.stateVersion = "26.05";
}
