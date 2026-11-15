# COULEURS DU RICE, À CHAUD : le fond d'écran donne la palette, sans rebuild.
#
# matugen (palettes « Material You », celles d'Android) calcule les couleurs
# depuis l'image, puis remplit des modèles déclarés par chaque brique du rice
# (option rice.colorTemplates : waybar, notifications, lanceur, terminal, niri).
# Chaque brique est ensuite rechargée.
#
# Commande `wallpaper` (aussi Mod+Shift+W) :
#   wallpaper              choisir un fond dans ~/Images/Wallpapers (aperçu en
#                          grand : ← → pour défiler, Entrée pour choisir,
#                          q pour annuler), puis un style
#   wallpaper style        garder le fond, changer seulement le style de palette
#   wallpaper set <image> [style]
#   wallpaper restore      remet le dernier fond (lancé à l'ouverture de session)
#   wallpaper colors       recalcule seulement les couleurs (lancé à chaque rebuild)
#
# Styles de palette (du plus doux au plus coloré) : neutral, tonal-spot (par
# défaut), content (fidèle à l'image), expressive, monochrome.
#
# Le reste du système (applis GTK, Firefox, écran de connexion…) garde la
# palette fixe de Stylix : voir modules/profiles/niri/theme.nix.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rice.colorTemplates;

  # Dossier des fonds d'écran (crée-le et mets-y tes images).
  wallpaperDir = "${config.home.homeDirectory}/Images/Wallpapers";
  # Fond utilisé tant qu'aucun n'a été choisi.
  defaultWallpaper = ../../wallpapers/wallhaven-r7gzzm.jpg;

  stateDir = "${config.xdg.stateHome}/rice";

  # Menu anyrun (liste sur l'entrée standard → ligne choisie).
  menu = "${pkgs.anyrun}/bin/anyrun --plugins ${pkgs.anyrun}/lib/libstdin.so --show-results-immediately true";

  # Configuration de matugen : une entrée par modèle déclaré.
  matugenConfig = (pkgs.formats.toml { }).generate "matugen-config.toml" {
    config = {
      # Couleurs du terminal (rouge, vert…) : teintées vers la couleur du fond
      # (blend) pour rester dans l'ambiance sans être criardes.
      custom_colors = {
        red = {
          color = "#e5534b";
          blend = true;
        };
        green = {
          color = "#57ab5a";
          blend = true;
        };
        yellow = {
          color = "#c69026";
          blend = true;
        };
        blue = {
          color = "#539bf5";
          blend = true;
        };
        magenta = {
          color = "#b083f0";
          blend = true;
        };
        cyan = {
          color = "#39c5cf";
          blend = true;
        };
      };
    };

    templates = lib.mapAttrs (name: t: {
      input_path = "${config.xdg.configHome}/matugen/templates/${name}";
      output_path = "${config.xdg.configHome}/${t.target}";
      post_hook = "${t.reload} >/dev/null 2>&1 || true";
    }) cfg;
  };

  wallpaper = pkgs.writeShellApplication {
    name = "wallpaper";
    runtimeInputs = with pkgs; [
      matugen
      awww
      imv
      coreutils
      findutils
      libnotify
    ];
    text = ''
      state=${lib.escapeShellArg stateDir}
      dir=${lib.escapeShellArg wallpaperDir}
      mkdir -p "$state"

      current_image() {
        local image
        image=$(cat "$state/wallpaper" 2>/dev/null || true)
        if [ -f "$image" ]; then echo "$image"; else echo ${defaultWallpaper}; fi
      }
      current_scheme() { cat "$state/scheme" 2>/dev/null || echo scheme-tonal-spot; }

      # Calcule la palette et remplit les modèles (+ rechargements).
      colors() {
        matugen image "$1" --mode dark --type "$2" --source-color-index 0 --quiet
        echo "$1" > "$state/wallpaper"
        echo "$2" > "$state/scheme"
      }

      apply() {
        awww img "$1" --transition-type fade || true
        colors "$1" "$2"
      }

      pick_scheme() {
        local choice
        choice=$(printf '%s\n' \
          "Doux (tonal-spot)" \
          "Sobre (neutral)" \
          "Fidèle à l'image (content)" \
          "Coloré (expressive)" \
          "Monochrome" | ${menu})
        case "$choice" in
          Doux*) echo scheme-tonal-spot ;;
          Sobre*) echo scheme-neutral ;;
          Fid*) echo scheme-content ;;
          Color*) echo scheme-expressive ;;
          Mono*) echo scheme-monochrome ;;
          *) ;; # menu fermé : rien
        esac
      }

      case "''${1:-pick}" in
        pick)
          if [ ! -d "$dir" ]; then
            notify-send "Fond d'écran" "Mets tes images dans $dir"
            exit 0
          fi
          # Aperçu avec imv : Entrée note l'image affichée et ferme la fenêtre.
          picked=$(mktemp)
          # (pas de « ; » dans la commande : imv le prendrait comme séparateur)
          imv -r -c "bind <Return> exec echo \"\$imv_current_file\" > $picked && imv-msg \$imv_pid quit" "$dir" || true
          choice=$(cat "$picked")
          rm -f "$picked"
          [ -z "$choice" ] && exit 0
          scheme=$(pick_scheme)
          [ -z "$scheme" ] && exit 0
          apply "$choice" "$scheme"
          ;;
        style)
          scheme=$(pick_scheme)
          [ -z "$scheme" ] && exit 0
          colors "$(current_image)" "$scheme"
          ;;
        set)
          apply "$2" "''${3:-scheme-tonal-spot}"
          ;;
        restore)
          apply "$(current_image)" "$(current_scheme)"
          ;;
        colors)
          colors "$(current_image)" "$(current_scheme)"
          ;;
        *)
          echo "usage : wallpaper [pick|style|set <image> [style]|restore|colors]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.rice.colorTemplates = lib.mkOption {
    default = { };
    description = ''
      Modèles remplis par matugen à chaque changement de fond d'écran.
      Syntaxe des couleurs : {{colors.primary.default.hex}} (voir le wiki de matugen).
    '';
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          text = lib.mkOption {
            type = lib.types.lines;
            description = "Contenu du modèle.";
          };
          target = lib.mkOption {
            type = lib.types.str;
            example = "waybar/style.css";
            description = "Fichier produit, relatif à ~/.config (ne doit pas être géré par home-manager).";
          };
          reload = lib.mkOption {
            type = lib.types.str;
            default = "true";
            description = "Commande lancée après l'écriture du fichier (recharger l'appli).";
          };
        };
      }
    );
  };

  config = {
    home.packages = [
      pkgs.matugen
      wallpaper
    ];

    xdg.configFile = {
      "matugen/config.toml".source = matugenConfig;
    }
    // lib.mapAttrs' (
      name: t: lib.nameValuePair "matugen/templates/${name}" { inherit (t) text; }
    ) cfg;

    # À chaque rebuild : recalcule les couleurs avec les modèles à jour
    # (après la mise en place des liens de home-manager, pour écrire au bon endroit).
    home.activation.riceColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${wallpaper}/bin/wallpaper colors || true
    '';
  };
}
