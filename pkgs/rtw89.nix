# Driver wifi hors noyau pour la clé USB Realtek RTL8852AU (ID 3625:010d).
# C'est l'équivalent du paquet DKMS installé sur Void : même dépôt, même commit.
#
# Pour mettre à jour : changer `rev`, mettre `hash = "";`, rebuild ;
# Nix affiche alors le bon hash dans l'erreur, il n'y a qu'à le recopier.
{ lib, stdenv, fetchFromGitHub, kernel, kernelModuleMakeFlags }:

stdenv.mkDerivation {
  pname = "rtw89-morrownr";
  version = "7.3-unstable-2026-10-13-${kernel.version}";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtw89";
    rev = "3cdbb6b81e00b72cf27bbdd4d4f1b96f9c15be27";
    hash = "sha256-6z4RNg7OIbAc0IUuONuwfAkqjuIKyo+8ZULpX/GKwp4=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  # Le Makefile cherche le noyau dans /lib/modules : on lui donne celui de Nix.
  makeFlags = kernelModuleMakeFlags ++ [
    "KVER=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];
  buildFlags = [ "modules" ];

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/lib/modules/${kernel.modDirVersion}/extra/rtw89 *.ko
    runHook postInstall
  '';

  meta = {
    description = "Drivers rtw89 hors noyau (morrownr), dont rtw89_8852au_git";
    homepage = "https://github.com/morrownr/rtw89";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
