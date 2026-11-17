# TOR : mode anonyme à la demande, façon AnonSurf (Parrot OS).
#
#   sudo anon start      tout le trafic de la machine passe par Tor
#   sudo anon stop       retour à la normale
#   sudo anon new        nouvelle identité (nouveaux circuits, nouvelle IP)
#   anon status          état + IP vue de l'extérieur
#
# Comment ça marche : Tor n'est PAS lancé au démarrage. `anon start` le démarre
# et ajoute une table nftables « anon » :
#   - connexions TCP → redirigées vers Tor (port transparent 9040) ;
#   - requêtes DNS → résolues par Tor (port 9053), pas de fuite DNS ;
#   - tout le reste (UDP, IPv6, ping…) → bloqué.
# Si Tor plante, la table reste en place : rien ne sort en clair (kill switch).
#
# Avec Mullvad : allume le VPN AVANT `anon start` (Tor passe alors dans le VPN).
# Changer de pays avec `vpn` pendant le mode anonyme ne marche pas (ping bloqué).
# Tailscale est coupé pendant le mode anonyme.
#
# Pour l'anonymat en navigation, Tor Browser (installé ici) reste bien meilleur :
# un Firefox/Zen normal passant par Tor se reconnaît à son empreinte (polices,
# taille d'écran, extensions, comptes connectés…).
#
#   rice.tor.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rice.tor;

  transPort = 9040;
  dnsPort = 9053;
  # Plage d'adresses fictives que Tor donne aux sites .onion (AutomapHosts).
  virtualNet = "10.192.0.0/10";

  # Réseaux locaux laissés en accès direct (imprimante, NAS, homelab…).
  lanNets = "{ 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 }";
  lanRules = lib.optionalString cfg.allowLan ''
    ip daddr ${lanNets} return
  '';
  lanAccept = lib.optionalString cfg.allowLan ''
    ip daddr ${lanNets} accept
  '';

  rules = pkgs.writeText "anon.nft" ''
    table inet anon {
      chain nat_out {
        type nat hook output priority -100;
        meta skuid "tor" return                       # Tor lui-même sort en direct
        oifname "lo" return
        udp dport 53 redirect to :${toString dnsPort}  # DNS → Tor (même vers le LAN)
        tcp dport 53 redirect to :${toString dnsPort}
        ip daddr ${virtualNet} meta l4proto tcp redirect to :${toString transPort} # .onion
        ${lanRules}
        ip protocol tcp redirect to :${toString transPort}       # TCP → Tor
      }
      chain filter_out {
        type filter hook output priority 0; policy drop;
        ct state established,related accept
        meta skuid "tor" accept
        meta mark 0xca6c accept                       # paquets chiffrés du VPN Mullvad (wg-quick)
        oifname "lo" accept
        ${lanAccept}
      }
    }
  '';

  anon = pkgs.writeShellApplication {
    name = "anon";
    runtimeInputs = with pkgs; [
      nftables
      systemd
      curl
      jq
      libnotify
      coreutils
      util-linux # setpriv
      conntrack-tools
    ];
    text = ''
      need_root() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "À lancer avec sudo : sudo anon $1" >&2
          exit 1
        fi
      }
      # Marqueur posé par `anon start` (lisible sans être root).
      active() { [ -e /run/anon-active ]; }

      # IP publique et vérification Tor (via le site du projet Tor).
      check() {
        local info
        info=$(curl -s --max-time 15 https://check.torproject.org/api/ip || true)
        if [ "$(printf '%s' "$info" | jq -r '.IsTor // false' 2>/dev/null)" = true ]; then
          echo "Via Tor ✓  IP : $(printf '%s' "$info" | jq -r .IP)"
        elif [ -n "$info" ]; then
          echo "PAS via Tor ✗  IP : $(printf '%s' "$info" | jq -r '.IP // "?"')"
        else
          echo "Pas de réponse (Tor encore en train de se connecter ?)"
        fi
      }

      # Notification sur le bureau de l'utilisateur qui a lancé sudo.
      notify() {
        if [ -n "''${SUDO_UID:-}" ]; then
          # shellcheck disable=SC2153
          setpriv --reuid="$SUDO_UID" --regid="$SUDO_GID" --init-groups \
            env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$SUDO_UID/bus" \
            notify-send "Mode anonyme" "$1" >/dev/null 2>&1 || true
        fi
      }

      case "''${1:-status}" in
        start)
          need_root start
          if active || nft list table inet anon >/dev/null 2>&1; then echo "Déjà actif."; exit 0; fi
          systemctl start tor.service
          nft -f ${rules}
          touch /run/anon-active
          # Coupe les connexions déjà ouvertes en clair (Discord, mails…) :
          # elles se reconnecteront, cette fois par Tor.
          conntrack -F >/dev/null 2>&1 || true
          resolvectl flush-caches 2>/dev/null || true
          echo "Mode anonyme actif. Connexion au réseau Tor…"
          sleep 5
          check
          notify "Actif : tout passe par Tor"
          ;;
        stop)
          need_root stop
          nft delete table inet anon 2>/dev/null || true
          rm -f /run/anon-active
          systemctl stop tor.service
          resolvectl flush-caches 2>/dev/null || true
          echo "Mode anonyme désactivé."
          notify "Désactivé : connexion normale"
          ;;
        new)
          need_root new
          active || { echo "Le mode anonyme n'est pas actif."; exit 1; }
          systemctl restart tor.service
          sleep 5
          check
          notify "Nouvelle identité"
          ;;
        status)
          if active; then echo "Mode anonyme : ACTIF"; else echo "Mode anonyme : inactif"; fi
          check
          ;;
        *)
          echo "usage : anon start | stop | new | status" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.rice.tor = {
    enable = lib.mkEnableOption "le mode anonyme Tor (commande anon) et Tor Browser";
    allowLan = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Garder l'accès direct au réseau local pendant le mode anonyme.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tor = {
      enable = true;
      client = {
        enable = true; # proxy SOCKS 127.0.0.1:9050 (pour torsocks, etc.)
        transparentProxy.enable = true; # port 9040
        dns.enable = true; # port 9053 + adresses fictives pour les .onion
      };
      # Adresses fictives des .onion : hors de 127.x (qui ne passerait pas par
      # la redirection), comme le recommande la doc de Tor.
      settings.VirtualAddrNetworkIPv4 = virtualNet;
    };
    # Tor ne démarre qu'avec `anon start`.
    systemd.services.tor.wantedBy = lib.mkForce [ ];

    environment.systemPackages = [
      anon
      pkgs.tor-browser
      pkgs.torsocks # `torsocks <commande>` : une seule commande via Tor
    ];
  };
}
