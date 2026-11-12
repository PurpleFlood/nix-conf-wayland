# BASE : toujours active, sur toutes les machines.
# Le rice complet mais léger : niri, waybar, anyrun, foot, fish, Neovim, Firefox.
# Rien ici ne doit demander un matériel particulier (carte graphique récente,
# processeur avec AVX, pilote propriétaire…) : la base doit tourner partout.
{ ... }:

{
  imports = [
    ./options.nix # les réglages par machine : clavier, terminal, écrans
    ./systeme.nix # Nix, langue, utilisateur, réseau, son, matériel
    ./bureau.nix # niri, écran de connexion, verrouillage, fichiers
    ./theme.nix # Stylix
  ];
}
