{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  fontconfig,
  freetype,
  just,
  libinput,
  pkg-config,
  rustPlatform,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-term";
  version = "1.0.0-beta.4-unstable-2025-10-29";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-term";
    rev = "28a9cf3a2dd5b72381eb9067f1cb68ff7257073e";
    hash = "sha256-1c+yU5yLmruim/sOWDPO7Cq+UdIpcSDXPJhP/rMdueU=";
  };

  cargoHash = "sha256-oiZjX53CQA53mMNfmmnyzWGAiZRA+4BxOxEvbEFd8q8=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    libinput
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-term"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-term";
    description = "Terminal for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-term";
  };
}
