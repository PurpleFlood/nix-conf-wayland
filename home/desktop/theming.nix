# COULEURS DU RICE, À CHAUD : le fond d'écran donne la palette, sans rebuild.
#
# matugen (palettes « Material You », celles d'Android) calcule les couleurs
# depuis l'image, puis remplit des modèles déclarés par chaque brique du rice
# (option rice.colorTemplates : waybar, notifications, lanceur, terminal, niri).
# Chaque brique est ensuite rechargée.
#
# Commande `wallpaper` (aussi Mod+Shift+W) :
#   wallpaper              choisir un fond dans ~/Images/Wallpapers, puis un style.
#                          Petite fenêtre flottante : la liste à gauche, l'aperçu
#                          de l'image sous le curseur à droite. ↑ ↓ ou taper un
#                          bout du nom, Entrée pour choisir, Échap pour annuler.
#   wallpaper style        garder le fond, changer seulement le style de palette
#   wallpaper set <image> [style]   (style par défaut : auto)
#   wallpaper restore      remet le dernier fond (lancé à l'ouverture de session)
#   wallpaper colors       recalcule seulement les couleurs (lancé à chaque rebuild)
#
# Styles de palette (du plus doux au plus coloré) : neutral, tonal-spot,
# content (fidèle à l'image), expressive, monochrome.
# « auto » (par défaut) : monochrome si l'image est en noir et blanc, sinon
# tonal-spot. Sans ça, matugen ne trouve aucune couleur dans une image grise et
# retombe sur son bleu de secours (#adc6ff).
# Seuil réglable avec monoThreshold ci-dessous.
#
# Le reste du système (applis GTK, Firefox, écran de connexion…) garde la
# palette fixe de Stylix : voir modules/profiles/niri/theme.nix.
{
  config,
  osConfig,
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

  # En dessous de ce taux moyen de couleur (0 = gris pur, 100 = très saturé),
  # le style auto considère l'image comme monochrome. Une image sépia ou
  # légèrement teintée (≈ 30) garde une palette colorée.
  monoThreshold = 8;

  # Le menu s'ouvre dans une fenêtre de terminal flottante (règle dans niri.nix,
  # identifiant « rice.wallpaper ») : fzf pour la liste, à côté l'aperçu.
  # Fenêtre opaque, pour que l'aperçu ne se mélange pas avec ce qu'il y a derrière.
  ghostty = osConfig.rice.terminal == "ghostty";
  openMenu =
    if ghostty then
      "ghostty --gtk-single-instance=false --quit-after-last-window-closed=true --background-opacity=1 --class=rice.wallpaper -e"
    else
      "foot --app-id=rice.wallpaper -o colors-dark.alpha=1.0";

  # Aperçu d'une image dans fzf (méthode recommandée par fzf) :
  # - Ghostty : kitten icat, qui efface l'image précédente à chaque changement ;
  # - foot : chafa en Sixel.
  preview = pkgs.writeShellApplication {
    name = "wallpaper-preview";
    runtimeInputs = [
      pkgs.chafa
      pkgs.gnused
    ]
    ++ lib.optional ghostty pkgs.kitty; # fournit `kitten`
    text = ''
      file=$1
      dim="''${FZF_PREVIEW_COLUMNS}x''${FZF_PREVIEW_LINES}"
      case "''${TERM:-}" in
        *ghostty* | *kitty*)
          # La dernière ligne (code de remise à zéro) est recollée à la précédente,
          # sinon fzf affiche une barre de défilement. (« $ » de sed, pas des variables.)
          # shellcheck disable=SC2016
          kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no \
            --place="$dim@0x0" "$file" | sed '$d' | sed $'$s/$/\e[m/'
          ;;
        foot*)
          chafa --format sixels --size "$dim" -- "$file"
          ;;
        *)
          chafa --format symbols --size "$dim" -- "$file"
          ;;
      esac
    '';
  };

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
      fzf
      imagemagick # mesure de la couleur de l'image (style auto)
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
      current_scheme() { cat "$state/scheme" 2>/dev/null || echo auto; }

      # Style auto : taux moyen de couleur (chroma) de l'image, de 0 à 100.
      resolve_scheme() {
        if [ "$2" != auto ]; then echo "$2"; return; fi
        local chroma
        chroma=$(magick "$1" -resize '64x64!' -colorspace HCL -format '%[fx:int(100*mean.g)]' info: 2>/dev/null || echo 100)
        if [ "$chroma" -lt ${toString monoThreshold} ]; then
          echo scheme-monochrome
        else
          echo scheme-tonal-spot
        fi
      }

      # Calcule la palette et remplit les modèles (+ rechargements).
      # On enregistre le style demandé (auto reste auto pour le prochain fond).
      colors() {
        matugen image "$1" --mode dark --type "$(resolve_scheme "$1" "$2")" --source-color-index 0 --quiet
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
          "Auto (monochrome si l'image est en noir et blanc, sinon doux)" \
          "Doux (tonal-spot)" \
          "Sobre (neutral)" \
          "Fidèle à l'image (content)" \
          "Coloré (expressive)" \
          "Monochrome" | fzf --layout=reverse --prompt="Style de palette > ") || true
        case "$choice" in
          Auto*) echo auto ;;
          Doux*) echo scheme-tonal-spot ;;
          Sobre*) echo scheme-neutral ;;
          Fid*) echo scheme-content ;;
          Color*) echo scheme-expressive ;;
          Mono*) echo scheme-monochrome ;;
          *) ;; # menu fermé : rien
        esac
      }

      # Les menus ont besoin d'un terminal : lancé depuis un raccourci, le script
      # se relance lui-même dans la fenêtre flottante.
      in_terminal() {
        if [ ! -t 0 ]; then
          exec ${openMenu} "$0" "$@"
        fi
      }

      case "''${1:-pick}" in
        pick)
          in_terminal "$@"
          if [ ! -d "$dir" ]; then
            notify-send "Fond d'écran" "Mets tes images dans $dir"
            exit 0
          fi
          cd "$dir"
          choice=$(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%P\n' \
            | sort \
            | fzf --layout=reverse --prompt="Fond d'écran > " \
                --preview-window=right,65% \
                --preview "${preview}/bin/wallpaper-preview {}") || true
          [ -z "$choice" ] && exit 0
          scheme=$(pick_scheme)
          [ -z "$scheme" ] && exit 0
          apply "$dir/$choice" "$scheme"
          ;;
        style)
          in_terminal "$@"
          scheme=$(pick_scheme)
          [ -z "$scheme" ] && exit 0
          colors "$(current_image)" "$scheme"
          ;;
        set)
          apply "$2" "''${3:-auto}"
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
