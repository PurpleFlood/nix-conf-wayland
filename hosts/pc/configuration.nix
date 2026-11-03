# PC FIXE : ce qui est propre à cette machine (matériel, jeux, VR, IA).
# Le rice commun (niri, waybar…) vient de modules/ et home/ ;
# les réglages utilisateur propres au PC (écrans, jeux…) sont dans home/pc.nix.
{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Pilote Wi-Fi hors noyau pour la clé USB Realtek RTL8852AU.
  wifi = config.boot.kernelPackages.callPackage ../../pkgs/rtw89.nix { };
in
{
  imports = [
    # Disques et modules de démarrage, générés à l'installation du PC.
    ./hardware-configuration.nix
  ];

  networking.hostName = "pc";

  # ─── Démarrage : Limine (thème et fond appliqués par Stylix) ────────────
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
    enableEditor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  hardware.enableRedistributableFirmware = true;

  # ─── Wi-Fi : clé USB Realtek (pilote morrownr) ──────────────────────────
  boot.extraModulePackages = [ wifi ];
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
  hardware.graphics.enable32Bit = true; # jeux 32 bits / Steam / Wine
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

  # ─── Disque dur interne (données) ──────────────────────────────────────
  fileSystems."/mnt/data" = {
    device = "/dev/sda";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # ─── Jeux ──────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;

  # ─── VR : WiVRn (Quest 3) ──────────────────────────────────────────────
  # Version 26.9 (recette d'unstable) compilée avec les bibliothèques du système,
  # pour que les jeux puissent la charger (problème de glibc sinon).
  services.wivrn = {
    enable = true;
    package = pkgs.callPackage "${pkgs-unstable.path}/pkgs/by-name/wi/wivrn/package.nix" { };
    openFirewall = true;
    autoStart = true;
    highPriority = true;
    steam.importOXRRuntimes = true;
    # Couche OpenVR → OpenXR que WiVRn active à la connexion du casque
    config = {
      enable = true;
      json.openvr-compat-path = "${pkgs.xrizer}/lib/xrizer";
    };
  };

  # ─── IA locale : Ollama (Vulkan, pas de compilation CUDA) ──────────────
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };

  # ─── Paquets propres au PC ─────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    pkgs-unstable.android-tools # adb, même version que celui de WiVRn
    vrc-get
    unityhub
    # ALCOM (gestion des projets VRChat), avec un correctif d'affichage
    (symlinkJoin {
      name = "alcom";
      paths = [ alcom ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ALCOM --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      '';
    })
  ];

  # Accès SSH (dépannage depuis le portable).
  services.openssh.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Version de la PREMIÈRE installation du PC : ne pas changer.
  system.stateVersion = "26.05";
}
