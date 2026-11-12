# IA LOCALE : Ollama (Vulkan), LM Studio, AnythingLLM (en conteneur),
# Heretic (PyTorch CUDA via uv).
#
#   rice.ai.enable = true;
{ config, lib, pkgs, ... }:

let
  # Heretic via uv : le PyTorch de PyPI embarque CUDA (celui de nixpkgs est CPU)
  heretic = pkgs.writeShellScriptBin "heretic" ''
    export LD_LIBRARY_PATH=/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.uv}/bin/uvx --python 3.12 --from heretic-llm heretic "$@"
  '';
in
{
  options.rice.ai.enable = lib.mkEnableOption "l'IA locale (Ollama, LM Studio, AnythingLLM)";

  config = lib.mkIf config.rice.ai.enable {
    # Ollama en Vulkan : pas de compilation CUDA, marche avec toutes les cartes
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
    };

    # AnythingLLM (interface web sur http://localhost:3001), en conteneur podman
    virtualisation.oci-containers = {
      backend = "podman";
      containers.anythingllm = {
        image = "docker.io/mintplexlabs/anythingllm:latest";
        volumes = [
          "/var/lib/anythingllm:/app/server/storage"
          "/var/lib/anythingllm/.env:/app/server/.env" # réglages du serveur
        ];
        environment.STORAGE_DIR = "/app/server/storage";
        extraOptions = [
          "--network=host" # joint LM Studio (1234) et Ollama (11434) en localhost
          "--cap-add=SYS_ADMIN" # requis par le navigateur intégré (lecture de pages web)
        ];
      };
    };
    # Dossier des données + fichier .env vide, propriété de l'utilisateur de l'image
    systemd.tmpfiles.rules = [
      "d /var/lib/anythingllm 0755 1000 1000 -"
      "f /var/lib/anythingllm/.env 0644 1000 1000 -"
    ];

    home-manager.users.${config.rice.user}.home.packages = [
      pkgs.lmstudio
      heretic
    ];
  };
}
