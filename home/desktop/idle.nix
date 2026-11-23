# VEILLE : swayidle surveille l'inactivité et déclenche gtklock (verrouillage)
# puis l'extinction des écrans. Malgré son nom, swayidle n'est pas lié à sway.
#
# Le verrouillage passe par gtklock (rice classique) ou par Noctalia.
{ osConfig, ... }:

let
  lock =
    if osConfig.rice.shell == "classic" then
      "gtklock -d"
    else
      "noctalia-shell ipc call lockScreen lock";
in
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300; # 5 min : verrouillage
        command = lock;
      }
      {
        timeout = 600; # 10 min : écrans éteints
        command = "niri msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = lock; # verrouille avant la mise en veille
      lock = lock; # `loginctl lock-session`
    };
  };
}
