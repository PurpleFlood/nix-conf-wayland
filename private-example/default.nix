# EXEMPLE DU DÉPÔT PRIVÉ (nix-private).
#
# Le vrai dépôt est privé : il contient ce qui ne regarde que moi (adresses du
# homelab, certificat, e-mail, favoris…). Ce dossier a la même forme avec de
# fausses valeurs, pour que n'importe qui puisse construire la config :
#
#   nixos-rebuild build --flake .#minimal --impure --override-input private path:./private-example
#
# Pour ton propre dépôt privé : copie ce dossier dans un nouveau dépôt GitHub
# privé, remplace les valeurs, et ajoute tes fichiers (certificat, favoris).
{
  # Ton compte administrateur sur toutes les machines (sudo, SSH avec sshKeys).
  admin = "user";

  # Ton dépôt public (pour les mises à jour automatiques du profil simple).
  repository = "github:ton-pseudo/nix-conf-wayland";

  # Comptes des personnes à qui tu prépares une machine (profil simple),
  # par nom de machine. Leurs prénoms restent ainsi hors du dépôt public.
  hostUsers = {
    sl510 = "invite";
  };

  # Identité git (home/default.nix)
  git = {
    name = "Exemple";
    email = "exemple@example.com";
  };

  # Clés SSH publiques autorisées sur le compte admin de toutes les machines
  # (contenu de ~/.ssh/id_ed25519.pub sur ton PC).
  sshKeys = [ ];

  # Réseau de la maison (module homeNetwork)
  homeNetwork = {
    dns = [ "192.168.1.1" ]; # ton serveur DNS local
    certificates = [ ]; # ex. [ ./caddy-root.crt ]
  };

  # Clé secrète de SearXNG (module searxng) : une longue chaîne au hasard,
  # par exemple générée avec `openssl rand -hex 32`.
  searxngSecretKey = "remplace-moi-par-une-chaine-au-hasard";

  # Fichier de favoris de Zen (module zen) : dans ton clone du dépôt privé,
  # pour qu'il soit modifiable (Zen l'écrit à la fermeture).
  bookmarksFile = "/home/user/git/nix-private/bookmarks.html";
}
