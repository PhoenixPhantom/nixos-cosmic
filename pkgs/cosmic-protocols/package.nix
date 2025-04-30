{
  lib,
  fetchFromGitHub,
  stdenv,
  wayland-scanner,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "cosmic-protocols";
  version = "0-unstable-2025-04-22";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-protocols";
    rev = "bc4af9183e0967802d7fbe91ba811a29ca6a3b67";
    hash = "sha256-zWLzlZZRXqIMZf05172MR0LBj6hHxhPhDz1/92GHrAY=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  nativeBuildInputs = [ wayland-scanner ];

  passthru.updateScript = nix-update-script {
    # add if upstream ever makes a tag
    #extraArgs = [ "--version-regex" "epoch-(.*)" ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-protocols";
    description = "Additional wayland-protocols used by the COSMIC Desktop Environment";
    license = with lib.licenses; [
      mit
      gpl3Only
    ];
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
  };
}
