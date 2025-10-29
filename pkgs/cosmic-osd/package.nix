{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  pkg-config,
  libinput,
  glibc,
  pulseaudio,
  pipewire,
  udev,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-osd";
  version = "1.0.0-beta.4-unstable-2025-10-29";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    rev = "64cdec754565eb312a666ba76dc8355aa4c38512";
    hash = "sha256-fvMs70Azc86o1Q3bSem7szlrjXUhuz2ZNtcgPczSf58=";
  };

  cargoHash = "sha256-v6/lWqGG3uFSFgw77M0kGM+cK9wSiuaGaciPqz/wFIQ=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    glibc
    libinput
    pipewire
    pulseaudio
    udev
  ];

  env.POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-osd";
    description = "OSD for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-osd";
  };
}
