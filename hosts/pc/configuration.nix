# PC FIXE : ce qui est propre à cette machine (matériel) + les modules allumés.
# Le socle vient de modules/core, le rice du profil niri (modules/profiles/niri + home/) ;
# les réglages utilisateur propres au PC (écrans…) sont dans ./home.nix.
{ config, ... }:

let
  # Pilote Wi-Fi hors noyau pour la clé USB Realtek RTL8852AU.
  wifi = config.boot.kernelPackages.callPackage ../../pkgs/rtw89.nix { };
in
{
  imports = [
    # Disques et modules de démarrage, générés à l'installation du PC.
    ./hardware-configuration.nix
  ];

  # ─── Modules et réglages du rice ───────────────────────────────────────
  rice = {
    terminal = "ghostty";
    greeterDisabledOutputs = [ "DP-1" ]; # ReGreet seulement sur l'écran HDMI

    apps.enable = true;
    dev.enable = true;
    music.enable = true;
    gaming.enable = true;
    vr.enable = true;
    ai.enable = true;
    virtualisation.enable = true;
    zen.enable = true;
    searxng.enable = true;
    i2p.enable = true;
    tor.enable = true;
    vpn.enable = true;
    homeNetwork.enable = true;
  };

  # Écrans, bureaux et réglages utilisateur propres au PC
  home-manager.users.${config.rice.user}.imports = [ ./home.nix ];

  # ─── Démarrage : Limine (thème et fond appliqués par Stylix) ────────────
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
    enableEditor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  # ─── Wi-Fi : clé USB Realtek (pilote morrownr) ──────────────────────────
  boot.extraModulePackages = [ wifi ];
  hardware.usb-modeswitch.enable = true;
  # Les pilotes rtw89 du noyau ne doivent pas prendre la clé.
  boot.blacklistedKernelModules = [
    "rtw89_core"
    "rtw89_usb"
    "rtw89_pci"
    "rtw89_8852a"
    "rtw89_8852au"
    "rtw89_8852ae"
    "rtw89_8852b"
    "rtw89_8852bu"
    "rtw89_8852be"
    "rtw89_8852b_common"
    "rtw89_8851b"
    "rtw89_8851bu"
    "rtw89_8851be"
    "rtw89_8852c"
    "rtw89_8852cu"
    "rtw89_8852ce"
    "rtw89_8922a"
    "rtw89_8922au"
    "rtw89_8922ae"
  ];
  boot.extraModprobeConfig = ''
    options rtw89_core_git debug_mask=0x0 disable_ps_mode=n
    options rtw89_usb_git switch_usb_mode=y
  '';

  # ─── NVIDIA RTX 3050 ───────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ]; # charge le pilote (aussi sous Wayland)
  hardware.nvidia = {
    modesetting.enable = true; # indispensable pour Wayland
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Recommandé par niri : évite que le pilote NVIDIA garde des centaines
  # de Mo de mémoire vidéo en réserve pour le compositeur.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

  # Version de la PREMIÈRE installation du PC : ne pas changer.
  system.stateVersion = "26.05";
}
