{
  lib,
  fetchFromGitHub,
  stdenv,
  wayland-scanner,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "cosmic-protocols";
  version = "0-unstable-2026-08-14";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-protocols";
    rev = "a2da48188362c4ea05d33de2f6c67d8148deba88";
    hash = "sha256-hqsOzu0mlkE2jtgL5HvbT9vtOKiMSniNwV+xk4UzTkc=";
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
