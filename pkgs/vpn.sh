#!/bin/bash
# vpn : connexion Mullvad (WireGuard) par pays, sur le serveur le plus rapide.
#
#   vpn <pays>   se connecte au meilleur serveur du dossier /etc/wireguard/<pays>/
#   vpn off      se déconnecte
#   vpn status   affiche la connexion en cours
#   vpn list     liste les pays disponibles
#
# À lancer avec sudo (wg-quick a besoin des droits root).

DIR="${VPN_DIR:-/etc/wireguard}"

# Interfaces WireGuard actives
actives() { wg show interfaces 2>/dev/null; }

# Retrouve le fichier .conf d'une interface active
conf_de() { find "$DIR" -name "$1.conf" | head -1; }

deconnecter() {
  for i in $(actives); do
    echo "Déconnexion de $i…"
    wg-quick down "$(conf_de "$i")" >/dev/null 2>&1
  done
}

# Latence moyenne (ms) vers le serveur d'un fichier .conf, 9999 si injoignable
latence() {
  local ip
  ip=$(sed -n 's/^[[:space:]]*Endpoint[[:space:]]*=[[:space:]]*\(.*\):[0-9]*$/\1/p' "$1" | head -1 | tr -d '[]')
  [ -z "$ip" ] && { echo 9999; return; }
  ping -c 3 -q -W 1 "$ip" 2>/dev/null \
    | awk -F'/' '/^(rtt|round-trip)/ {printf "%d\n", $5; found=1} END {if (!found) print 9999}'
}

case "${1:-}" in
  off)
    deconnecter
    ;;
  status)
    a=$(actives)
    if [ -n "$a" ]; then echo "Connecté : $a"; else echo "Non connecté"; fi
    ;;
  list)
    find "$DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
    ;;
  "")
    echo "Usage : vpn <pays> | off | status | list"
    exit 1
    ;;
  *)
    pays="$1"
    [ -d "$DIR/$pays" ] || { echo "Pays inconnu : $pays (voir : vpn list)"; exit 1; }

    # On se déconnecte d'abord : le kill switch bloquerait les tests de latence
    deconnecter

    meilleur=""; meilleure=9999
    for f in "$DIR/$pays"/*.conf; do
      [ -e "$f" ] || continue
      ms=$(latence "$f")
      printf '  %-25s %s ms\n' "$(basename "$f" .conf)" "$ms"
      if [ "$ms" -lt "$meilleure" ]; then meilleure=$ms; meilleur=$f; fi
    done

    # Aucun serveur n'a répondu au ping : on prend un fichier au hasard
    if [ -z "$meilleur" ]; then
      meilleur=$(ls "$DIR/$pays"/*.conf 2>/dev/null | shuf -n 1)
      [ -z "$meilleur" ] && { echo "Aucun fichier .conf dans $DIR/$pays"; exit 1; }
      echo "Aucun serveur n'a répondu au ping, choix au hasard."
    fi

    echo "Connexion à $(basename "$meilleur" .conf)…"
    if sortie=$(wg-quick up "$meilleur" 2>&1); then
      echo "Connecté."
    else
      echo "Échec de la connexion :"; echo "$sortie"; exit 1
    fi
    ;;
esac
