# MAKO : notifications. Couleurs et police : Stylix.
{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000; # disparaît après 5 s
      border-radius = 10;
      border-size = 2;
      padding = "12";
      margin = "12";
      anchor = "top-right";
      max-visible = 5;
    };
  };
}
