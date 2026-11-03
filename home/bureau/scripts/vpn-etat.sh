# État du VPN pour waybar (JSON). L'icône est toujours affichée :
# pleine couleur si une interface WireGuard est active, grisée sinon.

# Interface WireGuard active (pas besoin de root avec ip)
serveur=$(ip -o link show type wireguard 2>/dev/null | awk -F': ' '{print $2; exit}')

# IP publique, vue par Mullvad (fonctionne aussi hors VPN)
info=$(curl -s --max-time 4 https://am.i.mullvad.net/json)
ip=$(printf '%s' "$info" | jq -r '.ip // "?"' 2>/dev/null)
pays=$(printf '%s' "$info" | jq -r '.country // ""' 2>/dev/null)
ville=$(printf '%s' "$info" | jq -r '.city // ""' 2>/dev/null)

if [ -n "$serveur" ]; then
  jq -n -c --arg t "󰖂 ${ville:-VPN}" \
    --arg tip "Connecté · $serveur
${ip:-?} — ${ville}${ville:+, }${pays}
Clic : changer de pays / déconnecter" \
    '{text:$t, tooltip:$tip, class:"actif"}'
else
  jq -n -c --arg tip "VPN non connecté
IP : ${ip:-?}
Clic : choisir un pays" \
    '{text:"󰖂", tooltip:$tip, class:"inactif"}'
fi
