# VEILLE : swayidle surveille l'inactivité et déclenche gtklock (verrouillage)
# puis l'extinction des écrans. Malgré son nom, swayidle n'est pas lié à sway.
{ ... }:

{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300; # 5 min : verrouillage
        command = "gtklock -d";
      }
      {
        timeout = 600; # 10 min : écrans éteints
        command = "niri msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = "gtklock -d"; # verrouille avant la mise en veille
      lock = "gtklock -d"; # `loginctl lock-session`
    };
  };
}
