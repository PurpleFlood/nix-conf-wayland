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
active_interfaces() { wg show interfaces 2>/dev/null; }

# Retrouve le fichier .conf d'une interface active
conf_of() { find "$DIR" -name "$1.conf" | head -1; }

disconnect() {
  for i in $(active_interfaces); do
    echo "Déconnexion de $i…"
    wg-quick down "$(conf_of "$i")" >/dev/null 2>&1
  done
}

# Latence moyenne (ms) vers le serveur d'un fichier .conf, 9999 si injoignable
latency() {
  local ip
  ip=$(sed -n 's/^[[:space:]]*Endpoint[[:space:]]*=[[:space:]]*\(.*\):[0-9]*$/\1/p' "$1" | head -1 | tr -d '[]')
  [ -z "$ip" ] && { echo 9999; return; }
  ping -c 3 -q -W 1 "$ip" 2>/dev/null \
    | awk -F'/' '/^(rtt|round-trip)/ {printf "%d\n", $5; found=1} END {if (!found) print 9999}'
}

case "${1:-}" in
  off)
    disconnect
    ;;
  status)
    a=$(active_interfaces)
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
    country="$1"
    [ -d "$DIR/$country" ] || { echo "Pays inconnu : $country (voir : vpn list)"; exit 1; }

    # On se déconnecte d'abord : le kill switch bloquerait les tests de latence
    disconnect

    best=""; best_ms=9999
    for f in "$DIR/$country"/*.conf; do
      [ -e "$f" ] || continue
      ms=$(latency "$f")
      printf '  %-25s %s ms\n' "$(basename "$f" .conf)" "$ms"
      if [ "$ms" -lt "$best_ms" ]; then best_ms=$ms; best=$f; fi
    done

    # Aucun serveur n'a répondu au ping : on prend un fichier au hasard
    if [ -z "$best" ]; then
      best=$(ls "$DIR/$country"/*.conf 2>/dev/null | shuf -n 1)
      [ -z "$best" ] && { echo "Aucun fichier .conf dans $DIR/$country"; exit 1; }
      echo "Aucun serveur n'a répondu au ping, choix au hasard."
    fi

    echo "Connexion à $(basename "$best" .conf)…"
    if output=$(wg-quick up "$best" 2>&1); then
      echo "Connecté."
    else
      echo "Échec de la connexion :"; echo "$output"; exit 1
    fi
    ;;
esac
