# DÉVELOPPEMENT : compilateurs, SDK, rétro-ingénierie, automatisation.
# (Neovim, git et leurs outils sont dans la base : home/neovim.nix.)
#
#   rice.dev.enable = true;
#   rice.dev.agentsIA = false;   # sur un vieux processeur sans AVX (R400…)
{ config, lib, pkgs, ... }:

let
  cfg = config.rice.dev;
in
{
  options.rice.dev = {
    enable = lib.mkEnableOption "les outils de développement";

    agentsIA = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Agents IA en terminal (Claude Code, opencode). Ils demandent un
        processeur récent (AVX) : à couper sur les vieilles machines.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.asap.home.packages =
      with pkgs;
      [
        # Compilation
        cmake
        gnumake
        pkg-config
        rustc
        cargo
        jdk21
        dotnet-sdk

        # Rétro-ingénierie
        ghidra

        # Automatisation
        ansible
      ]
      ++ lib.optionals cfg.agentsIA [
        claude-code
        opencode
      ];
  };
}
